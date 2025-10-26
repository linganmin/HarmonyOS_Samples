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

import { emitter } from '@kit.BasicServicesKit';
import { taskpool, ArkTSUtils, worker, MessageEvents } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ThreadInfos } from '../viewmodel/ThreadInfos';
import { ShowInfoComponent } from '../view/ShowInfoComponent';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CustomButtonModifier, CustomColumnModifier } from '../viewmodel/ComponentModifier';
import { ThreadType, threadExecuteInfo, timeConsumingTask, getResourceString } from '../common/utils/ThreadMethods';

const TAG: string = '[ThreadCommunication]';

@Concurrent
function taskPoolFunc(): void {
  let sendMsg: string = threadExecuteInfo(ThreadType.taskPool, Const.SEND_MESSAGES);
  try {
    taskpool.Task.sendData(sendMsg);
  } catch (error) {
    hilog.error(0x0000, Const.TASKPOOL_TAG, `sendData catch error, code: ${error.code}, message: ${error.message}`);
  }
  timeConsumingTask(Const.Communication_EXE_TIMES);
}

@Concurrent
async function taskPoolToWorkerFunc(): Promise<void> {
  let event: emitter.InnerEvent = {
    eventId: 1,
    priority: emitter.EventPriority.HIGH
  };
  let sendMsg: string = threadExecuteInfo(ThreadType.taskPool, Const.SEND_MESSAGES);
  let eventData: emitter.EventData = {
    data: {
      content: sendMsg
    }
  };
  emitter.emit(event, eventData);
  timeConsumingTask(Const.Communication_EXE_TIMES);
}

@Component
struct ThreadCommunication {
  @State executeContents: string = '';
  @State threadInfos: ThreadInfos = new ThreadInfos();
  @State threadContents: string = this.threadInfos.showInfos();
  private workerInstance: worker.ThreadWorker = new worker.ThreadWorker(Const.WORKER_ADDR);
  private intervalID: number = 0;
  private customButton:CustomButtonModifier = new CustomButtonModifier();
  private customColumn:CustomColumnModifier = new CustomColumnModifier();

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

        Button($r('app.string.TaskPoolToMain'))
          .attributeModifier(this.customButton)
          .onClick(() => {
            let task = new taskpool.Task(taskPoolFunc);
            task.onReceiveData((recvMsg: string) => {
              let recvInfo: string = threadExecuteInfo(ThreadType.main, Const.RECV_MESSAGES);
              this.refreshInfo(recvMsg + recvInfo);
            })
            taskpool.execute(task);
          })

        Button($r('app.string.WorkerToMain'))
          .attributeModifier(this.customButton)
          .onClick(() => {
            this.workerInstance.postMessage({ 'type': 0 });
            this.workerInstance.onmessage = (msg: MessageEvents) => {
              let recvInfo: string = threadExecuteInfo(ThreadType.main, Const.RECV_MESSAGES);
              this.refreshInfo(msg.data + recvInfo);
            };
          })

        Button($r('app.string.TaskPoolToWorker'))
          .attributeModifier(this.customButton)
          .onClick(() => {
            this.workerInstance.postMessage({ 'type': 1 });
            this.workerInstance.onmessage = (msg: MessageEvents) => {
              this.refreshInfo(msg.data);
            };
            let task = new taskpool.Task(taskPoolToWorkerFunc);
            taskpool.execute(task);
          })
      }
      .attributeModifier(this.customColumn)
    }
    .width('100%')
    .height('100%')
    .title(getResourceString(this.getUIContext(), Const.PAGE_TITLES[7]))
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
      this.workerInstance.postMessage({ 'type': 3 });
    })
  }
}

@Builder
function getThreadCommunication(name:string):void {
  if(name === Const.PAGE_NAMES[7]) {
    ThreadCommunication()
  }
}

export const wrapperBuilderThreadCommunication:WrappedBuilder<[string]> = wrapBuilder(getThreadCommunication);