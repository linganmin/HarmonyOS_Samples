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
* FAQ:ArkTS实现多Worker实例
*/

// [Start MultipleWorkerInstances2]
import { MessageEvents, worker } from '@kit.ArkTS';

const mainThreadTag: string = 'mainthread';

// Initialize 2 workers, if closed or terminated, it cannot be used
let worker1: worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/worker1.ets', { name: 'worker1' });
let worker2: worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/worker2.ets', { name: 'worker2' });

// Custom Single Example
class TestObj {
  private message: string = 'this is a message from TestObj';

  public getMessage(): string {
    console.log(mainThreadTag, 'worker call obj func: getMessage()');
    return this.message;
  }

  public getMessageWithInput(str: string): string {
    return this.message + 'with input:' + str;
  }

  public setSharedArrayBuffer() {
    let num = new Int16Array(this.sharedBuffer);
    num[0] = 20;
  }

  public getSharedArrayBuffer(): SharedArrayBuffer {
    return this.sharedBuffer;
  }

  static registerObj: TestObj = new TestObj();
  private sharedBuffer: SharedArrayBuffer = new SharedArrayBuffer(1024);
}

// Worker's otnMessage monitoring
function onMessage(e: MessageEvents): void {
  switch (e.data.type as number) {
    case 0:
      console.log(mainThreadTag, 'received message type: 0, value is: %{public}s, next to post msg to worker2',
        e.data.value);
      worker2.postMessage('This is msg from mainthread switch');
      break;
    case 1:
      console.log(mainThreadTag, 'received message value %{public}d, next to post msg to worker1',
        e.data.value as number);
      worker1.postMessage({ 'type': 0 });
      break;
    default:
      console.log(mainThreadTag, 'invalid type, next to return');
    // Add a timer to reflect worker operation
      setTimeout(() => {
        console.log(mainThreadTag, 'invalid type, next to return');
      }, 5000);
      break;
  }
}

// Export function
export function testMultyWorker() {
  TestObj.registerObj.setSharedArrayBuffer();
  // Register registrant Obj on ThreadWorker instance
  worker2.registerGlobalCallObject('myObj', TestObj.registerObj);
  worker1.registerGlobalCallObject('myObj', TestObj.registerObj);

  console.log(mainThreadTag, 'this is a msg to start worker');
  worker1.postMessage('this is a msg to start worker1');

  worker1.onmessage = onMessage;
  worker2.onmessage = onMessage;

  console.log(mainThreadTag, 'end');
  worker1.onexit = () => {
    console.log('main thread terminate worker1');
  }
  worker2.onexit = () => {
    console.log('main thread terminate worker2');
  }
}
// [End MultipleWorkerInstances2]