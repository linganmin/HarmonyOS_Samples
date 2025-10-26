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

// [Start EnableSubThreadInWorker2]
// Work.ets & Worker.ets
import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS';

// Create an object in the worker thread that communicates with the main thread
const workerPort = worker.workerPort;

// The worker thread receives information from the main thread
workerPort.onmessage = (e: MessageEvents): void => {
  // Data: Information sent by the main thread
  let data: string = e.data;
  console.info(`Work.ets onmessage: data ${data}`);

  // Worker thread sends information to main thread
  workerPort.postMessage('123');
}

// Callback for worker thread error
workerPort.onerror = (err: ErrorEvent) => {
  console.info('worker.ets onerror' + err.message);
}
// [End EnableSubThreadInWorker2]