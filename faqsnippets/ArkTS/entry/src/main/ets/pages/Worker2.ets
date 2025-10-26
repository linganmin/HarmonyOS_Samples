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

// [Start MultipleWorkerInstances4]
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker, process } from '@kit.ArkTS';

const worker2: string = 'worker2';
const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (e: MessageEvents) => {
  console.log(worker2, 'enter worker2, process update %{public}d,%{public}d,%{public}d', process.uid, process.pid,
    process.tid);
  let str: string = workerPort.callGlobalCallObjectMethod('myObj', 'getMessage', 0) as string;
  console.log(worker2, 'call shared class func get value: %{public}s', str);

  let res: SharedArrayBuffer =
    workerPort.callGlobalCallObjectMethod('myObj', 'getSharedArrayBuffer', 0) as SharedArrayBuffer;
  let typedArr = new Int16Array(res);
  console.log(worker2, 'call shared class func get value: %{public}d', typedArr[0]);
  workerPort.postMessage({ 'type': 1, 'value': typedArr[0] });
}

workerPort.onmessageerror = (e: MessageEvents) => {
  console.log(worker2, 'received a message error');
}

workerPort.onerror = (e: ErrorEvent) => {
  console.log(worker2, 'worker2 error');
}
// [End MultipleWorkerInstances4]