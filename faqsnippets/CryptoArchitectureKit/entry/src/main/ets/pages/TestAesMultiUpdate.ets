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
* FAQ:如何对大文件进行SM4加密
*/

// [Start TestAesMultiUpdate]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

function genIvParamsSpec() {
  let arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let dataIv = new Uint8Array(arr);
  // The production environment should use randomly generated IVs. All zeros here are only for display purposes.
  let ivBlob: cryptoFramework.DataBlob = { data: dataIv };
  let ivParamsSpec: cryptoFramework.IvParamsSpec = {
    algName: 'IvParamsSpec',
    iv: ivBlob
  };
  return ivParamsSpec;
}

function stringToUint8Array(str: string): Uint8Array {
  let arr: Array<number> = [];
  for (let i = 0, j = str.length; i < j; i++) {
    arr.push(str.charCodeAt(i));
  }
  return new Uint8Array(arr);
}

async function testAesMultiUpdate(plainText: string) {
  let symAlgName = 'SM4_128';
  let length = 1024;
  let symKeyGenerator = cryptoFramework.createSymKeyGenerator(symAlgName);
  let cipherAlgName = 'SM4_128|CBC|PKCS7';
  let globalCipher = cryptoFramework.createCipher(cipherAlgName);
  let result = new Uint8Array();
  let data: cryptoFramework.DataBlob;
  let startEncrypt = 0;
  let endEncrypt = 0;
  let promiseSymKey = await symKeyGenerator.generateSymKey();
  await globalCipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, promiseSymKey, genIvParamsSpec());
  let updateOutput: cryptoFramework.DataBlob;
  while (plainText.length > 0) {
    const contentCurr = plainText.substring(0, length);
    plainText = plainText.substring(length, plainText.length);
    let messageBlob: cryptoFramework.DataBlob = { data: stringToUint8Array(contentCurr) };
    updateOutput = await globalCipher.update(messageBlob);
    if (updateOutput !== null) {
      let mergeText = new Uint8Array(result.length + updateOutput.data.length);
      mergeText.set(result);
      mergeText.set(updateOutput.data, result.length);
      result = mergeText;
    }
  }
  startEncrypt = new Date().getTime();
  data = await globalCipher.doFinal(null);
  endEncrypt = new Date().getTime();
  console.info('TEST加密' + (endEncrypt - startEncrypt));
  let mergeText = new Uint8Array(result.length + data.data.length);
  mergeText.set(result);
  mergeText.set(data.data, result.length);
  result = mergeText;
  let contentTemp = result;
  console.info('TEST加密成功', contentTemp);
  await globalCipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, promiseSymKey, genIvParamsSpec());
  console.info('TEST == 长度' + contentTemp.length);
}

@Entry
@Component
struct SM4Encryption {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    testAesMultiUpdate('123456789102345566478416518498454151689546549849');
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('SM4EncryptionHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}
// [End TestAesMultiUpdate]
