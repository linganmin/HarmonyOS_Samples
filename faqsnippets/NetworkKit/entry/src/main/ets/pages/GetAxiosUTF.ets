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
* FAQ:如何将Axios获取GBK格式的网络数据转换UTF-8格式
*/

// [Start GetAxiosUTF]
import { util } from '@kit.ArkTS';
import axios, { AxiosResponse } from '@ohos/axios';

const URL: string = 'xxx';

@Entry
@Component
struct FriendsBook {

  build() {
  }

  aboutToAppear() {
    axios<string, AxiosResponse<string>, null>({
      method: 'get',
      url: URL,
      // When using the til.TextDecoder method, the encoding and decoding formats must be consistent,
      // so the data type needs to be set to ARRAY_BUFFER when retrieving, otherwise garbled characters will appear.
      responseType: 'ARRAY_BUFFER'
    })
      .then((res: AxiosResponse) => {
        // First, use create to construct a TextDecoder instance and set the encoding format to gbk.
        const textDecoder = util.TextDecoder.create('gbk', { ignoreBOM: true });
        // Next, use the decodeWithStream method to decode the input parameters and output the corresponding UTF-8 formatted text string.
        // The parameters passed in must be in Uint8Array format, so the obtained data needs to be converted to an array type using the Uint8Array method.
        const result = new Uint8Array(res.data);
        const resultString = textDecoder.decodeToString(result, { stream: false });
        // Parse JSON strings.
        const jsonResult = JSON.parse(resultString) as string;
      })
  }
}
// [End GetAxiosUTF]

