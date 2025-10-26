/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { taskpool, ArkTSUtils } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ThreadInfos } from '../viewmodel/ThreadInfos';
import { ShowInfoComponent } from '../view/ShowInfoComponent';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CustomButtonModifier, CustomColumnModifier } from '../viewmodel/ComponentModifier';
import { ThreadType, threadExecuteInfo, timeConsumingTask, getResourceString } from '../common/utils/ThreadMethods';

const TAG: string = '[DependentTasks]';

@Concurrent
function dependentFunc(num: number): void {
  let exeMsg: string = threadExecuteInfo(ThreadType.taskPool, Const.DEPENDENT_EXE_INFO + num.toString());
  try {
    taskpool.Task.sendData(exeMsg);
  } catch (error) {
    hilog.error(0x0000, Const.TASKPOOL_TAG, `sendData catch error, code: ${error.code}, message: ${error.message}`);
  }
  timeConsumingTask(Const.DEPENDENT_TASK_EXE_TIMES);
}

@Component
struct DependentTasks {
  @State isExecutable: boolean = false;
  @State isCancelable: boolean = false;
  @State executeContents: string = '';
  @State threadInfos: ThreadInfos = new ThreadInfos();
  @State threadContents: string = this.threadInfos.showInfos() + Const.DEPENDENT_INFO;
  private intervalID: number = 0;
  private taskArray: Array<taskpool.Task> = [];
  private customButton: CustomButtonModifier = new CustomButtonModifier();
  private customColumn: CustomColumnModifier = new CustomColumnModifier();

  async refreshInfo(value: string) {
    let lock: ArkTSUtils.locks.AsyncLock = ArkTSUtils.locks.AsyncLock.request(Const.LOCK_NAME);
    try {
      lock.lockAsync(() => {
        this.executeContents += value;
      }, ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE);
    } catch (error) {
      hilog.error(0x0000, TAG, `lockAsync catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        ShowInfoComponent({
          executeContents: this.executeContents,
          threadContents: this.threadContents
        })

        Button($r('app.string.ButtonCreate'))
          .attributeModifier(this.customButton)
          .onClick(async () => {
            this.taskArray.length = 0;
            for (let i = 0; i < 2; i++) {
              this.taskArray.push(new taskpool.Task(dependentFunc, i));
              this.taskArray[i].onReceiveData((value: string) => {
                this.refreshInfo(value);
              })
            }
            this.taskArray[0].addDependency(this.taskArray[1]);
            this.isExecutable = true;
          })
          .enabled(!this.isExecutable && !this.isCancelable)

        Button($r('app.string.ButtonExe'))
          .attributeModifier(this.customButton)
          .onClick(async () => {
            if (this.taskArray.length <= 0) {
              return;
            }
            for (let i = 0; i < this.taskArray.length; i++) {
              taskpool.execute(this.taskArray[i], taskpool.Priority.HIGH).then(async () => {
                this.isCancelable = false;
              });
              let submitMsg: string = threadExecuteInfo(ThreadType.main, Const.DEPENDENT_SUBMIT_INFO + i.toString());
              this.refreshInfo(submitMsg);
            }
            this.isCancelable = true;
            this.isExecutable = false;
          })
          .enabled(this.isExecutable)

        Button($r('app.string.ButtonCancel'))
          .attributeModifier(this.customButton)
          .onClick(() => {
            try {
              this.isCancelable = false;
              for (let i = 0; i < this.taskArray.length; i++) {
                if (!this.taskArray[i].isDone()) {
                  taskpool.cancel(this.taskArray[i]);
                }
              }
            } catch (error) {
              hilog.error(0x0000, TAG, JSON.stringify(error));
            }
          })
          .enabled(this.isCancelable)
      }
      .attributeModifier(this.customColumn)
    }
    .width('100%')
    .height('100%')
    .title(getResourceString(this.getUIContext(), Const.PAGE_TITLES[4]))
    .backgroundColor(0XF1F3F5)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAppear(() => {
      this.intervalID = setInterval(() => {
        this.threadInfos.refreshInfos(taskpool.getTaskPoolInfo());
        this.threadContents = this.threadInfos.showInfos() + Const.DEPENDENT_INFO;
      }, 200);
    })
    .onDisAppear(() => {
      clearInterval(this.intervalID);
      try {
        if (this.isCancelable) {
          taskpool.cancel(this.taskArray[0]);
        }
      } catch (error) {
        hilog.error(0x0000, TAG, JSON.stringify(error));
      }
    })
  }
}

@Builder
function getDependentTasks(name:string):void {
  if(name === Const.PAGE_NAMES[4]) {
    DependentTasks()
  }
}

export const wrapperBuilderDependentTasks:WrappedBuilder<[string]> = wrapBuilder(getDependentTasks);