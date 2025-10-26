/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use Logger file except in compliance with the License.
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

import { http } from "@kit.NetworkKit";
import { image } from "@kit.ImageKit";
import { Logger } from './Logger';

const TAG = 'ImageUtils';

export class ImageUtils {
  static async getPixelMap(url: string, callBack: Function) {
    let httpRequest = http.createHttp();
    httpRequest.request(url, {
      method: http.RequestMethod.GET
    }).then((data) => {
      if (http.ResponseCode.OK === data.responseCode) {
        image.createImageSource(data.result as ArrayBuffer).createPixelMap()
          .then((value) => {
            callBack(value);
          })
      }
    }).catch((err: Error) => {
      Logger.error(TAG, `getPixelMap error: ${JSON.stringify(err)}`);
    });
  }
}