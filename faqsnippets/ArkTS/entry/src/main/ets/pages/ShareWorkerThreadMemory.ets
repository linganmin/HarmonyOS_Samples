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
* FAQ:Worker线程内存如何共享
*/

// [Start ShareWorkerThreadMemory]
import { worker } from '@kit.ArkTS';

@Component
export struct ThreadWorkerView {
  build() {
    Column() {
      Button('测试Worker线程内存共享')
        .width(200)
        .onClick(() => {
          let sab = new SharedArrayBuffer(32);
          let i32a = new Int32Array(sab);
          i32a[0] = 0;
          let producer = new worker.ThreadWorker("entry/ets/pages/ThreadWorkerSharedArrayBuffer/WorkerProducer.ets");
          producer.postMessage(sab);
          let consumer = new worker.ThreadWorker("entry/ets/pages/ThreadWorkerSharedArrayBuffer/WorkerConsumer.ets");
          consumer.postMessage(sab);
        })
    }
  }
}
// [End ShareWorkerThreadMemory]