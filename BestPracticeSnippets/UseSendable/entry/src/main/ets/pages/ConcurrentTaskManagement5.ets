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
* 最佳实践: 应用并发设计 并发任务管理 任务延时调度
*/
// [Start quick_start]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { taskpool } from '@kit.ArkTS';

// [StartExclude quick_start]
const DOMAIN = 0x0000;
const TAG = 'ConcurrentTaskManagement5';
const FORMAT = '%{public}s';
// [EndExclude quick_start]
@Concurrent
function concurrentTask(num: number): number {
  hilog.info(0x0000, 'TAG', '%{public}s', 'Add the task that needs to be executed with delay');
  return num;
}

function executeTaskPool() {
  // create a task
  let task: taskpool.Task = new taskpool.Task(concurrentTask, 100);
  // Delayed execution of task
  taskpool.executeDelayed(3000, task, taskpool.Priority.HIGH).then((value: Object) => {
    // Processing delayed task results
    hilog.info(DOMAIN, TAG, FORMAT, 'taskpool result: ' + value);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });
}
// [End quick_start]

@Component
export struct ConcurrentTaskManagement5 {
  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.task_delay_scheduling_title'))
          .buttonStyles()
          .margin({
            bottom: 16
          })
          .onClick(() => {
            executeTaskPool();
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
    .title($r('app.string.task_delay_scheduling_title'))
  }
}