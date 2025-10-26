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
* FAQ:如何使用TaskPool在子线程调用对象成员函数
*/

// [Start EnableSubThreadInTaskPool2]
// xxx.ets:
import { taskpool } from '@kit.ArkTS';
import { TestClass } from './TestClass'; // Return static handle

// Step 1: Define concurrent functions and internally call synchronization methods
@Concurrent
function func(num: number): number {
  // Call synchronous wait call implemented in static class objects
  let testClass = new TestClass();
  let sum = testClass.GetValue() + num;
  return sum;
}

// Step 2: Create a task and execute it
function asyncGet(): void {
  // Create a task and pass it in the function func
  let task: taskpool.Task = new taskpool.Task(func, 1);
  // Execute task tasks and operate on the synchronized logic results
  taskpool.execute(task).then((result: object) => {
    console.info('testTag result:' + result);
  });
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // Step 3: Perform concurrent operations
            asyncGet();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End EnableSubThreadInTaskPool2]