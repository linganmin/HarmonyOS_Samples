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
import { common, contextConstant } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { buffer, util } from '@kit.ArkTS';
import { huks } from '@kit.UniversalKeystoreKit';

@Entry
@Component
struct Index {
  @State message: string = '';

  build() {
    Column() {
      Column({ space: 12 }) {
        Text($r('app.string.file_path'))
          .fontSize(20)
          .fontWeight(700)
        Text(this.message)
          .fontSize(16)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      Column({ space: 12 }) {
        Button($r('app.string.get_file_path'))
          .width('100%')
          .onClick(() => {
            this.getEl2Path();
          })
        Button($r('app.string.get_el1_file_path'))
          .width('100%')
          .onClick(() => {
            this.getEl1Path();
          })
        Button($r('app.string.encrypted'))
          .width('100%')
          .onClick(async () => {
            await GenerateAesKey();
            await EncryptData();
          })
        Button($r('app.string.decrypted'))
          .width('100%')
          .onClick(() => {
            DecryptData();
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(16)
  }

  // [Start get_el2_path]
  getEl2Path(): void {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.area = contextConstant.AreaMode.EL2;
    let filePath = context.filesDir + '/health_data.txt';
    this.message = filePath;
  }
  // [End get_el2_path]

  // [Start get_el1_path]
  getEl1Path(): void {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.area = contextConstant.AreaMode.EL1;
    let filePath = context.filesDir + '/health_data.txt';
    this.message = filePath;
  }
  // [End get_el1_path]
}

let aesKeyAlias: string = 'test_aesKeyAlias';
let handle: number;
let plainText: string = '123456';
let IV: string = '001122334455';
let cipherData: Uint8Array;

// [Start write_file]
function writeFile(filePath: string, data: string): void {
  try {
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let writeLen = fileIo.writeSync(file.fd, data);
    hilog.info(0x0000, 'AppDataSecurity', 'The length of str is: ' + writeLen);
    fileIo.closeSync(file);
  } catch (error) {
    hilog.error(0x0000, 'AppDataSecurity', `writeFile error ${JSON.stringify(error)}`);
  }
}

function readFile(filePath: string): string {
  try {
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let arrayBuffer = new ArrayBuffer(1024);

    class Option {
      public offset: number = 0;
      public length: number = 0;
    }

    let option = new Option();
    option.length = arrayBuffer.byteLength;
    let readLen = fileIo.readSync(file.fd, arrayBuffer, option);
    let buf = buffer.from(arrayBuffer, 0, readLen);
    hilog.info(0x0000, 'AppDataSecurity', `The length of of file: ${readLen}`);
    fileIo.closeSync(file);
    return buf.toString();
  } catch (error) {
    hilog.error(0x0000, 'AppDataSecurity', `readFile error ${JSON.stringify(error)}`);
  }
  return '';
}
// [End write_file]

function StringToUint8Array(str: string): Uint8Array {
  let textEncoder = util.TextEncoder.create('utf-8');
  return textEncoder.encodeInto(str);
}

function Uint8ArrayToString(fileData: Uint8Array): string {
  let textDecoder = util.TextDecoder.create('utf-8');
  return textDecoder.decodeToString(fileData);
}

// [Start get_aes_generate_properties]
function GetAesGenerateProperties(): Array<huks.HuksParam> {
  let properties: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_AES
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
    huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
  }];
  return properties;
}
// [End get_aes_generate_properties]

// [Start get_aes_encrypt_properties]
function GetAesEncryptProperties(): Array<huks.HuksParam> {
  let properties: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_AES
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
  }, {
    tag: huks.HuksTag.HUKS_TAG_PADDING,
    value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
  }, {
    tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
    value: huks.HuksCipherMode.HUKS_MODE_CBC
  }, {
    tag: huks.HuksTag.HUKS_TAG_IV,
    value: StringToUint8Array(IV)
  }];
  return properties;
}
// [End get_aes_encrypt_properties]

// [Start get_aes_decrypt_properties]
function GetAesDecryptProperties(): Array<huks.HuksParam> {
  let properties: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_AES
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
  }, {
    tag: huks.HuksTag.HUKS_TAG_PADDING,
    value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
  }, {
    tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
    value: huks.HuksCipherMode.HUKS_MODE_CBC
  }, {
    tag: huks.HuksTag.HUKS_TAG_IV,
    value: StringToUint8Array(IV)
  }];
  return properties;
}
// [End get_aes_decrypt_properties]

// [Start generate_aes_key]
async function GenerateAesKey(): Promise<void> {
  let genProperties = GetAesGenerateProperties();
  let options: huks.HuksOptions = {
    properties: genProperties
  };

  await huks.generateKeyItem(aesKeyAlias, options)
    .then((data) => {
      hilog.info(0x0000, 'AppDataSecurity', `promise: generate AES Key success, data = ${JSON.stringify(data)}`);
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: generate AES Key failed, ${JSON.stringify(error)}`);
    })
}
// [End generate_aes_key]

// [Start encrypt_data]
async function EncryptData(): Promise<void> {
  let encryptProperties = GetAesEncryptProperties();
  let options: huks.HuksOptions = {
    properties: encryptProperties,
    inData: StringToUint8Array(plainText)
  };

  await huks.initSession(aesKeyAlias, options)
    .then((data) => {
      handle = data.handle;
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: init EncryptData failed, ${JSON.stringify(error)}`);
    })

  await huks.finishSession(handle, options)
    .then((data) => {
      hilog.info(0x0000, 'AppDataSecurity',
        `promise: encrypt data success, data is ` + Uint8ArrayToString(data.outData as Uint8Array));
      cipherData = data.outData as Uint8Array;
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: encrypt data failed, ${JSON.stringify(error)}`);
    })
}

async function DecryptData(): Promise<void> {
  let decryptOptions = GetAesDecryptProperties()
  let options: huks.HuksOptions = {
    properties: decryptOptions,
    inData: cipherData
  };

  await huks.initSession(aesKeyAlias, options)
    .then((data) => {
      handle = data.handle;
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: init DecryptData failed, ${JSON.stringify(error)}`);
    })

  await huks.finishSession(handle, options)
    .then((data) => {
      hilog.info(0x0000, 'AppDataSecurity',
        `promise: decrypt data success, data is ` + Uint8ArrayToString(data.outData as Uint8Array));
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: decrypt data failed, ${JSON.stringify(error)}`);
    })
}
// [End encrypt_data]

async function DeleteKey(): Promise<void> {
  let emptyOptions: huks.HuksOptions = {
    properties: []
  };

  await huks.deleteKeyItem(aesKeyAlias, emptyOptions)
    .then((data) => {
      hilog.info(0x0000, 'AppDataSecurity', `promise: delete data success`);
    }).catch((error: Error) => {
      hilog.error(0x0000, 'AppDataSecurity', `promise: delete data failed, ${JSON.stringify(error)}`);
    })
}