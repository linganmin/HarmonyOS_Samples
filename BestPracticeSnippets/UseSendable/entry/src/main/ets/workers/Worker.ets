/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
* 最佳实践: 应用并发设计 线程间通信 线程间不可变数据共享
*/
// [Start workerport]
// The worker file path is: entry/ets/workers/Worker.ets
// Worker.ets
import { MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { GlobalConfig } from '../pages/InterThreadCommunication4';
import { hilog } from '@kit.PerformanceAnalysisKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
workerPort.onmessage = (e: MessageEvents) => {
  let globalConfig: GlobalConfig = e.data;
  hilog.info(0x0000, 'TAG', '%{public}s', `globalConfig: ${globalConfig}`);
  // use the globalConfig object
}
// [End workerport]