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

import { taskpool } from '@kit.ArkTS';

export class ThreadInfos {
  threadCnt: number = 0;
  waitingNum: number = 0;
  runningNum: number = 0;
  canceledNum: number = 0;
  isEmpty: boolean = false;

  refreshInfos(taskpoolInfo: taskpool.TaskPoolInfo) {
    let runNum = 0, waitNum = 0, cancelNum = 0;
    this.threadCnt = taskpoolInfo.threadInfos.length;
    taskpoolInfo.taskInfos.forEach((taskInfo) => {
      if (taskInfo.state === taskpool.State.WAITING) {
        waitNum++;
      } else if (taskInfo.state === taskpool.State.RUNNING) {
        runNum++;
      } else if (taskInfo.state === taskpool.State.CANCELED) {
        cancelNum++;
      }
    })
    if (runNum + waitNum === 0) {
      this.isEmpty = true;
    } else {
      this.isEmpty = false;
    }
    this.runningNum = runNum;
    this.waitingNum = waitNum;
    this.canceledNum = cancelNum;
  }

  showInfos(): string {
    return 'TaskPool Threads: ' + this.threadCnt + '\n' +
      'Waiting Tasks: ' + this.waitingNum + '\n' +
      'Running Tasks: ' + this.runningNum + '\n' +
      'Canceled Tasks: ' + this.canceledNum + '\n';
  }
}