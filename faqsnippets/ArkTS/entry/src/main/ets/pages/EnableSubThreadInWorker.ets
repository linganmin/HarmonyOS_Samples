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
* FAQ:如何在Worker中开启多级子线程
*/

// [Start EnableSubThreadInWorker]
import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS';

const workerInstance = new worker.ThreadWorker('entry/ets/pages/Worker.ets');

// The main thread passes information to the worker thread
workerInstance.postMessage('123');

// The main thread receives worker thread information
workerInstance.onmessage = (e: MessageEvents): void => {
  // Data: Information sent by the Worker thread
  let data: string = e.data;
  console.info(`main thread onmessage, data:${data}`);
  const workerInstance1 = new worker.ThreadWorker('entry/ets/pages/Work.ets');
  workerInstance1.postMessage('123');
  workerInstance1.onmessage = (e: MessageEvents): void => {
    // data：Information sent by worker threads
    let data1: string = e.data;
    console.info(`main thread onmessage1, data:${data1}`);
    // Destroy Worker object
    workerInstance1.terminate();
  }
  // After calling terminate, execute onexit
  workerInstance1.onexit = (code) => {
    console.info(`main thread terminate, code:${code}`);
  }
  // Destroy Worker object
  workerInstance.terminate();

}
// After calling terminate, execute onexit
workerInstance.onexit = (code) => {
  console.info(`main thread terminate, code:${code}`);
}

workerInstance.onerror = (err: ErrorEvent) => {
  console.error('main error message ' + err.message);
}
// [End EnableSubThreadInWorker]