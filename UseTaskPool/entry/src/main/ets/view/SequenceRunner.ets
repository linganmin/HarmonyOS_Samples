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

const TAG: string = '[SequenceRunner]';

@Concurrent
function sequenceRunnerFunc(num: number): void {
  let exeMsg: string = threadExecuteInfo(ThreadType.taskPool, Const.RUNNER_EXE_INFO + num.toString());
  try {
    taskpool.Task.sendData(exeMsg);
  } catch (error) {
    hilog.error(0x0000, Const.TASKPOOL_TAG, `sendData catch error, code: ${error.code}, message: ${error.message}`);
  }
  timeConsumingTask(Const.RUNNER_EXE_TIMES);
}

@Component
struct SequenceRunner {
  @State isExecutable: boolean = false;
  @State isCancelable: boolean = false;
  @State executeContents: string = '';
  @State threadInfos: ThreadInfos = new ThreadInfos();
  @State threadContents: string = this.threadInfos.showInfos();
  private intervalID: number = 0;
  private taskArray: Array<taskpool.Task> = [];
  private runner: taskpool.SequenceRunner = new taskpool.SequenceRunner();
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
            for (let i = 0; i < 10; i++) {
              this.taskArray.push(new taskpool.Task(sequenceRunnerFunc, i));
              this.taskArray[i].onReceiveData((value: string) => {
                this.refreshInfo(value);
              })
            }
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
              this.runner.execute(this.taskArray[i]).then(async () => {
                if (i === this.taskArray.length - 1) {
                  this.isCancelable = false;
                }
              });
            }
            this.isCancelable = true;
            this.isExecutable = false;
          })
          .enabled(this.isExecutable)

        Button($r('app.string.ButtonCancel'))
          .attributeModifier(this.customButton)
          .onClick(async () => {
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
    .title(getResourceString(this.getUIContext(), Const.PAGE_TITLES[6]))
    .backgroundColor(0XF1F3F5)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAppear(() => {
      this.intervalID = setInterval(() => {
        this.threadInfos.refreshInfos(taskpool.getTaskPoolInfo());
        this.threadContents = this.threadInfos.showInfos();
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
function getSequenceRunner(name: string): void {
  if (name === Const.PAGE_NAMES[6]) {
    SequenceRunner()
  }
}

export const wrapperBuilderSequenceRunner: WrappedBuilder<[string]> = wrapBuilder(getSequenceRunner);