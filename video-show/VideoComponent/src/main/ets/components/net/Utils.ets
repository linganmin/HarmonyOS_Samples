/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let httpRequest = http.createHttp();

export async function Live() {
  let response: http.HttpResponse | undefined;
  try {
    response = await httpRequest.request(
      'http://xxx:xxxx/xxx',
      {
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: 60000,
        connectTimeout: 60000
      });
  } catch (err) {
    hilog.error(0x0000, 'EntryAbility', `Http resquest is fail. Cause code: ${err.code}, message: ${err.message}`);
  }
  return response;
}