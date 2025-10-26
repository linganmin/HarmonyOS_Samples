/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
* FAQ：如何在TaskPool和Woker获取上下文Context
 */

// [Start task_pool_get_context]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { taskpool } from '@kit.ArkTS';

// Support for ordinary functions and passing of reference parameters as input.
@Concurrent
function printArgs(args: string): string {
  console.info('func: ' + args);
  return args;
}

@Entry
@Component
struct TaskPoolGetContext {
  @State message: string = 'Hello World';
  // Obtain the context.
  uiContext = this.getUIContext();

  async taskpoolExecute(): Promise<void> {
    let task: taskpool.Task = new taskpool.Task(printArgs, 'create task, then execute');
    hilog.info(0x0000, 'TaskPoolGetContext', 'taskpool.execute(task) result: ' + await taskpool.execute(task));
    hilog.info(0x0000, 'TaskPoolGetContext',
      'taskpool.execute(function) result: ' + await taskpool.execute(printArgs, 'execute task by func'));
  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.taskpoolExecute();
        })
    }
    .width('100%')
    .height('100%')
  }
}
// [End task_pool_get_context]