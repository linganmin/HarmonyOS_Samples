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

import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { CommonConstants as Const } from '../common/CommonConstants';
import { ThreadType, threadExecuteInfo } from '../common/utils/ThreadMethods';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

let isEmitterOn: boolean = false;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = (msg: MessageEvents) => {
  if (msg.data.type as number === 0) {
    let sendMsg: string = threadExecuteInfo(ThreadType.worker, Const.SEND_MESSAGES);
    workerPort.postMessage(sendMsg);
  } else if (msg.data.type as number === 1 && !isEmitterOn) {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    let callback = (eventData: emitter.EventData) => {
      if (eventData.data) {
        let sendMsg: string = threadExecuteInfo(ThreadType.worker, Const.RECV_MESSAGES);
        workerPort.postMessage(eventData.data.content + sendMsg);
      }
    };
    emitter.on(event, callback);
    isEmitterOn = true;
  } else if (msg.data.type as number === 2) {
    emitter.off(1);
  }
}

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = (msg: MessageEvents) => {
  hilog.error(0x0000, 'worker', 'onmessage error: ' + JSON.stringify(msg.data));
}

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = (msg: ErrorEvent) => {
  hilog.error(0x0000, 'worker', 'Worker error: ' + JSON.stringify(msg));
}