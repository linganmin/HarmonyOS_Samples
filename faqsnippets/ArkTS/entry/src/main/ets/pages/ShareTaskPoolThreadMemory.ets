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
* FAQ:TaskPool线程内存如何共享
*/

// [Start ShareTaskPoolThreadMemory]
import { taskpool } from '@kit.ArkTS';

@Concurrent
function producer(ArrayBuffer: Int32Array): void {
  let i32a = ArrayBuffer;
  console.info("Producer: received sab");
  setInterval(() => {
    let length = i32a.length;
    for (let i = 1; i < length; i++) {
      i32a[i] = Math.random() * length;
    }
    Atomics.notify(i32a, 0, 1); // notify customer
  }, 2000);
}

@Concurrent
function consumer(ArrayBuffer: Int32Array): void {
  let i32a = ArrayBuffer;
  console.info("Customer: received sab");
  while (true) {
    Atomics.wait(i32a, 0, 0);
    let length = i32a.length;
    for (let i = length - 1; i > 0; i--) {
      console.info("arraybuffer " + i + " value is " + i32a[i]);
      i32a[i] = i;
    }
  }
}

function ArrayBufferShared(ArrayBuffer: Int32Array): void {
  let group: taskpool.TaskGroup = new taskpool.TaskGroup();
  group.addTask(consumer, ArrayBuffer);
  group.addTask(producer, ArrayBuffer);
  taskpool.execute(group, taskpool.Priority.HIGH).then((res: Object) => {
    // Result array summary processing
  })
}

@Component
export struct TestArrayBufferSharedView {
  build() {
    Row() {
      Column() {
        Text('Click')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let sab = new SharedArrayBuffer(32);
            let i32a = new Int32Array(sab);
            ArrayBufferShared(i32a);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End ShareTaskPoolThreadMemory]