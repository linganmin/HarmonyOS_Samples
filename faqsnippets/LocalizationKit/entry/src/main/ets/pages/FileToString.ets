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
* FAQ:如何将文件转换成字符串
*/

// [Start FileToString]
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct FileToString {
  build() {
    Row() {
      Column() {
        Button('file to string')
          .onClick(() => {
            getContext().resourceManager.getRawFileContent('test.txt').then((value: Uint8Array) => {
              let textDecoder: util.TextDecoder = util.TextDecoder.create(); // Call the TextDecoder class of the til module
              let decodedString: string = textDecoder.decodeToString(value); // 对Uint8Array解码
              let strBase64 = new util.Base64Helper().encodeToStringSync(value); // Convert a Uint8Array to a Base64 string
              console.info('retStr:', decodedString);
              console.info('strBase64:', strBase64);
            }).catch((error: BusinessError) => {
              console.error(`callback getRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
            });
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End FileToString]