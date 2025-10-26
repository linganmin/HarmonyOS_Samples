/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { ErrorEvent, HashMap, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { rcp } from '@kit.RemoteCommunicationKit';
import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/util/Logger';


const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

let fetchToRequest: HashMap<number, rcp.Request> = new HashMap();
let session: rcp.Session = rcp.createSession({
  requestConfiguration: {
    security: {
      remoteValidation: 'system',
      tlsOptions: { tlsVersion: 'TlsV1.3', cipherSuite: ['TLS_AES_128_GCM_SHA256'] }
    }
  }
});

async function caches(cachePath: string, fetchId: number, data: ArrayBuffer): Promise<string> {
  const path = `file://${cachePath}/${fetchId}.jpg`;
  let file: fs.File | null = null;
  try {
    file = await fs.open(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    await fs.write(file.fd, data);
  } catch (error) {
    Logger.error('File action failed. Cause %s', error);
  } finally {
    if (file) {
      try {
        await fs.close(file);
      } catch (closeError) {
        const error = closeError as BusinessError
        Logger.error(`Failed to close file. code = ${error.code}, message = ${error.message}`);
      }
    }
  }
  return path;
}

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (e: MessageEvents) => {
  switch (e.data.type) {
    case 'fetch':
      const request = new rcp.Request(e.data.url, 'GET')
      session.fetch(request).then(async (response: rcp.Response) => {
        if (response.statusCode == 200) {
          const imgData: ArrayBuffer = response.body as ArrayBuffer;
          let fetchUrl = await caches(e.data.cachePath, e.data.fetchId, imgData)
          fetchToRequest.remove(e.data.fetchId)
          workerPort.postMessageWithSharedSendable({ type: 'SUCCESS', fetchId: e.data.fetchId, fetchUrl: fetchUrl })
        } else {
          workerPort.postMessageWithSharedSendable({ type: 'FAIL', fetchId: e.data.fetchId })
        }
      }).catch((err: BusinessError) => {
        workerPort.postMessageWithSharedSendable({ type: 'FAIL', fetchId: e.data.fetchId })
      })
      break;
    case 'cancel':
      if (fetchToRequest.hasKey(e.data.fetchId)) {
        session.cancel(fetchToRequest.get(e.data.fetchId as number))
        workerPort.postMessageWithSharedSendable({ type: 'FAIL', fetchId: e.data.fetchId })
      }
      break;

  }
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessageerror = (event: MessageEvents) => {
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param event error message
 */
workerPort.onerror = (event: ErrorEvent) => {
};