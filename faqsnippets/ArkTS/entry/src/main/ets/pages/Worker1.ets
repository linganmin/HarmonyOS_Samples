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

// [Start MultipleWorkerInstances3]
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker, process } from '@kit.ArkTS';

const worker1: string = 'worker1';
const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (e: MessageEvents) => {
  console.log(worker1,'enter worker1, process uid:%{public}d, pid:%{public}d, tid:%{public}d',
    process.uid,process.pid,process.tid);

  if (e.data.type === 0) {
    workerPort.postMessage({ 'type': 2 });
    console.log(worker1,'begin to end worker1');
    // workerPort.close()  // Do not allow reuse after closing, otherwise it may cause a crash
    return;
  }

  try {
    let str1: string = workerPort.callGlobalCallObjectMethod('myObj','getMessage',0) as string;
    console.log(worker1,'call shared class to get func: getMessage(), return is: %{public}s',str1);
  } catch (e) {
    console.log(worker1,'call shared class getMessage get this %{public}s ,errcode %{public}d',e.message,e.code);
  }

  try {
    let res: SharedArrayBuffer =
      workerPort.callGlobalCallObjectMethod('myObj','getSharedArrayBuffer',0) as SharedArrayBuffer;
    let typedArr = new Int16Array(res);
    console.log(worker1,'call shared class func: getSharedArrayBuffer(), return is: %{public}d',typedArr[0]);
    typedArr[0] = 25;
    console.log(worker1,'work1 change the value to： %{public}d',typedArr[0]);
  } catch (e) {
    console.log(worker1,'call shared class getSharedArrayBuffer get this %{public}s',e.message);
  }

  workerPort.postMessage({ 'type': 0,'value': 'this is a msg from worker1 to main' });


  workerPort.onmessageerror = (e: MessageEvents) => {
    console.log(worker1,'received a message error');
  }

  workerPort.onerror = (e: ErrorEvent) => {
    console.log(worker1,'worker1 error');
  }
}
// [End MultipleWorkerInstances3]