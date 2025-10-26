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

import { huks } from '@kit.UniversalKeystoreKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON, util } from '@kit.ArkTS';
import { EncodingUtils } from './EncodingUtils';
import { CommonConstants } from '../constants/CommonConstants';
import Logger from './Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let keyAlias: string = 'KeyAlias';
let handle: number;
let cipherData: Uint8Array;
let IV: string = '001122334455';

export function getGenerateProperties(mode: number) {
  let properties: Array<huks.HuksParam> = new Array();
  let index: number = 0;
  switch (mode) {
    case 0:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_AES
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      break;
    case 1:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_RSA
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_RSA_KEY_SIZE_2048
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      break;
    case 2:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_SM4
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_SM4_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      break;
    default:
      break;
  }
  return properties;
}

export function getEncryptProperties(mode: number) {
  let properties: Array<huks.HuksParam> = new Array();
  let index: number = 0;
  switch (mode) {
    case 0:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_AES
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: EncodingUtils.stringToUnit8Array(IV)
      };
      break;
    case 1:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_RSA
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_RSA_KEY_SIZE_2048
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS1_V1_5
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_DIGEST,
        value: huks.HuksKeyDigest.HUKS_DIGEST_NONE
      };
      break;
    case 2:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_SM4
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_SM4_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: EncodingUtils.stringToUnit8Array(IV)
      };
      break;
    default:
      break;
  }
  return properties;
}

export function getDecryptProperties(mode: number) {
  let properties: Array<huks.HuksParam> = new Array();
  let index: number = 0;
  switch (mode) {
    case 0:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_AES
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: EncodingUtils.stringToUnit8Array(IV)
      };
      break;
    case 1:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_RSA
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_RSA_KEY_SIZE_2048
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS1_V1_5
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_DIGEST,
        value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
      };
      break;
    case 2:
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_SM4
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_SM4_KEY_SIZE_128
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
      };
      properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: EncodingUtils.stringToUnit8Array(IV)
      };
      break;
    default:
      break;
  }
  return properties;
}

export async function generateKey(mode: number) {
  let properties: Array<huks.HuksParam> = getGenerateProperties(mode);
  let options: huks.HuksOptions = {
    properties: properties
  };
  try {
    await huks.generateKeyItem(keyAlias, options);
  } catch (error) {
    Logger.error('generate key item failed,message is' + JSON.stringify(error));
  }
}

export async function encryptData(plainText: string, mode: number): Promise<string> {
  let encryptResult: string = '';
  let properties: Array<huks.HuksParam> = getEncryptProperties(mode);
  let options: huks.HuksOptions = {
    properties: properties,
    inData: EncodingUtils.stringToUnit8Array(plainText)
  };

  await huks.initSession(keyAlias, options).then((data) => {
    handle = data.handle;
  }).catch((error: BusinessError) => {
    Logger.error('init session failed,message is' + JSON.stringify(error));
  });

  await huks.finishSession(handle, options).then((data) => {
    uiContext?.getPromptAction().showToast({
      message: $r('app.string.encrypt_success'),
      duration: CommonConstants.TOAST_DURATION
    });
    encryptResult = new util.Base64Helper().encodeToStringSync(data.outData);
    cipherData = data.outData as Uint8Array;
  }).catch((error: BusinessError) => {
    Logger.error('encrypt data failed,message is' + JSON.stringify(error));
  });
  return encryptResult;
}

export async function decryptData(mode: number): Promise<string> {
  let decryptResult: string = '';
  let properties: Array<huks.HuksParam> = getDecryptProperties(mode);
  let options: huks.HuksOptions = {
    properties: properties,
    inData: cipherData
  };

  await huks.initSession(keyAlias, options).then((data) => {
    handle = data.handle;
  }).catch((error: BusinessError) => {
    Logger.error('init session failed,message is' + JSON.stringify(error));
  });

  await huks.finishSession(handle, options).then((data) => {
    decryptResult = EncodingUtils.unit8ArrayToString(data.outData as Uint8Array);
    try {
      uiContext?.getPromptAction().showToast({
        message: $r('app.string.decrypt_success'),
        duration: CommonConstants.TOAST_DURATION
      });
    } catch (error) {
      Logger.error('show toast failed, message is' + JSON.stringify(error));
    }
  }).catch((error: BusinessError) => {
    Logger.error('decrypt data failed, message is' + JSON.stringify(error));
  });
  return decryptResult;
}

export async function deleteKey() {
  let emptyOptions: huks.HuksOptions = {
    properties: []
  };
  try {
    await huks.deleteKeyItem(keyAlias, emptyOptions);
  } catch (error) {
    Logger.error(`delete ket item failed, message is ${JSON.stringify(error)}`);
  }
}