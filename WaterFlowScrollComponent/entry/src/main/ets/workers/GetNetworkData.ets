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

import { ArkTSUtils, collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

let pageNum = 1;
const pageSize = 100;
// TODO
const url =
  `https://devecostudio-drcn.op.hicloud.com/solution/v1/getSceneMockData?scene=smoothSlide&fileName=waterFlow.json&pageNum=${pageNum}&pageSize=${pageSize}`
/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as collections.Array<sceneMockData>
  FillData().then((value: collections.Array<sceneMockData>) => {
    data.push(...value)
    pageNum++
    if (pageNum > 5) {
      pageNum = 1
    }
    workerPort.postMessage({ type: 'HttpDown' })
  }, () => {
    workerPort.postMessage({ type: 'HttpError', 'err': 'get null data' })
  })
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

@Sendable
export class sceneMockData {
  thumbnails: string = ''
  source: string = ''
  width: number = 0
  height: number = 0
  type: string = ''
  title: string = ''
  title_en: string = ''
  user_image: string = ''
  nick_name: string = ''
  collections_count: number = 0
  url: string = ''
  index: number = 0
}

function FillData(): Promise<collections.Array<sceneMockData>> {
  return new Promise((resolve, reject) => {
    HttpGetUrl(url, (err: BusinessError, response?: string) => {
      if (err || response === undefined) {
        reject()
        return
      }

      let data: ESObject = ArkTSUtils.ASON.parse(response)
      let array: sceneMockData[] = data['data']
      let outPutData = new collections.Array<sceneMockData>()
      outPutData.push(...array)

      resolve(outPutData)
      return
    })
  })
}

export function HttpGetUrl(requestUrl: string, callBack: (err: BusinessError, responseDat?: string) => void) {
  let httpRequest = http.createHttp();
  httpRequest.request(requestUrl, {
    maxLimit: 10 * 1024 * 1024,
    priority: 10000,
  }, (error: BusinessError, data: http.HttpResponse) => {
    if (error) {
      callBack(error)
      httpRequest.destroy();
    } else {
      callBack(error, data.result as string);
      httpRequest.destroy();
    }
  })
}