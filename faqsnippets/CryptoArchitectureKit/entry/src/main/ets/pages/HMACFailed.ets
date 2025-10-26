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
* FAQ:HMAC加密报错：Error message:convertSymKey key failed!
*/

// [Start HMACFailed]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct HMACFailed {
  // [StartExclude HMACFailed]
  @State message: string = 'Hello World';
  // [EndExclude HMACFailed]
  ConvertKeySync() {
    // The symmetric key length is 28 bytes, 224 bits
    let keyMessage = '87654321abcdefgh87654321abcd'; // Execution successful
    // Execution successful. key encoded data：56,55,54,53,52,51,50,49,97,98,99,100,101,102,103,104,56,55,54,53,52,51,50,49,97,98,99,100
    // The symmetric key length is 26 bytes, 208 bits
    // let keyMessage = '87654321abcdefgh87654321ab'; // Execution failed
    // Execution failed,error message: convertSymKey key failed! 
    let keyBlob: cryptoFramework.DataBlob = {
      data: new Uint8Array(buffer.from(keyMessage, 'utf-8').buffer)
    }
    // Message Authentication Code Algorithm: HMAC, Digest Algorithm: SHA224, Key Length (bits): 224, String Parameter: HMAC|SHA224 
    let symKeyGenerator = cryptoFramework.createSymKeyGenerator('HMAC|SHA224');
    let key = symKeyGenerator.convertKeySync(keyBlob);
    let encodedKey = key.getEncoded();
    console.info('key encoded data：' + encodedKey.data);
  }
  // [StartExclude HMACFailed]
  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
          this.ConvertKeySync();
        })
    }
    .height('100%')
    .width('100%')
  }
  // [EndExclude HMACFailed]
}

// [End HMACFailed]
