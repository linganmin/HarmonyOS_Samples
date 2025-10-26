/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * FAQ: 如何利用worker子线程调用napi实现loop改写变量
 */
// [Start worker_call_ets]
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import testNapi from 'libentry.so';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (e: MessageEvents) => {
  testNapi.mainThread((data: ESObject) => {
    console.log("==worker func:data is :" + data);
    workerPort.postMessage({ 'type': 1, "data": data });
  });
}
// [End worker_call_ets]

workerPort.onmessageerror = (e: MessageEvents) => {
}

workerPort.onerror = (e: ErrorEvent) => {
}