/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* 最佳实践: 应用并发设计 并发任务管理 多任务同步等待结果（任务组）
*/
// [Start image_processing]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { taskpool } from '@kit.ArkTS';

// [StartExclude image_processing]
const DOMAIN = 0x0000;
const TAG = 'ConcurrentTaskManagement3';
const FORMAT = '%{public}s';
// [EndExclude image_processing]
// Define asynchronous tasks
@Concurrent
function imageProcessing(arrayBuffer: ArrayBuffer): ArrayBuffer {
  // Here add business logic, the input is ArrayBuffer, and the output is an ArrayBuffer storing the parsed results.
  let message: ArrayBuffer = arrayBuffer;
  return message;
}

let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
let TASK_POOL_CAPACITY: number = 10;

function histogramStatistic(pixelBuffer: ArrayBuffer): void {
  // Add tasks to the task group
  let byteLengthOfTask: number = pixelBuffer.byteLength / TASK_POOL_CAPACITY;
  for (let i = 0; i < TASK_POOL_CAPACITY; i++) {
    let dataSlice: ArrayBuffer = (i === TASK_POOL_CAPACITY - 1) ? pixelBuffer.slice(i * byteLengthOfTask) :
    pixelBuffer.slice(i * byteLengthOfTask, (i + 1) * byteLengthOfTask);
    let task: taskpool.Task = new taskpool.Task(imageProcessing, dataSlice);
    try {
      taskGroup.addTask(task);
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, `addTask failed. Cause code: ${err.code},message: ${err.message}`);
    }
  }
  try {
    taskpool.execute(taskGroup, taskpool.Priority.HIGH).then((res: Object[]): void | Promise<void> => {
      // Result data processing
      hilog.info(DOMAIN, TAG, FORMAT, `res:${res}`);
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, FORMAT, `taskpool excute error: ${error}`);
    });
  } catch (error) {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool excute error: ${error}`);
  }
}
// [End image_processing]

@Component
export struct ConcurrentTaskManagement3 {
  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.task_set_title'))
          .buttonStyles()
          .margin({
            bottom: 16
          })
          .onClick(() => {
            histogramStatistic(new ArrayBuffer(32));
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        right: 24,
        bottom: 16,
        left: 24
      })
    }
    .title($r('app.string.task_set_title'))
  }
}