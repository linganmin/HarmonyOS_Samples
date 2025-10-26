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

import { huks } from '@kit.UniversalKeystoreKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON, util } from '@kit.ArkTS';
import { HuksPropertiesConstants } from '../constants/HuksPropertiesConstants';
import { EncodingUtils } from './EncodingUtils';
import Logger from './Logger';
import { CommonConstants } from '../constants/CommonConstants';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

function getGenerateProperties(mode: number) {
  let properties: Array<huks.HuksParam> = [];
  let index: number = 0;
  if (mode === 0) {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_SM2
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
    };
  } else {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_ECC
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN |
      huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
    };
  }
  return properties;
}

function getSignProperties(mode: number) {
  let properties: Array<huks.HuksParam> = new Array();
  let index: number = 0;
  if (mode === 0) {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_SM2
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PADDING,
      value: huks.HuksKeyPadding.HUKS_PADDING_NONE
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SM3
    };
  } else {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_ECC
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
    };
  }
  return properties;
}

function getVerifyProperties(mode: number) {
  let properties: Array<huks.HuksParam> = new Array();
  let index: number = 0;
  if (mode === 0) {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_SM2
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_SM2_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PADDING,
      value: huks.HuksKeyPadding.HUKS_PADDING_NONE
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SM3
    };
  } else {
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_ECC
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
    };
    properties[index++] = {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
    };
  }
  return properties;
}

export async function generateSignKey(mode: number) {
  let properties: Array<huks.HuksParam> = getGenerateProperties(mode);
  let options: huks.HuksOptions = {
    properties: properties
  };
  try {
    await huks.generateKeyItem(HuksPropertiesConstants.KEY_ALIAS, options);
  } catch (error) {
    Logger.error('generateSignKey failed,message is' + JSON.stringify(error));
  }
}

export async function sign(mode: number): Promise<Uint8Array> {
  let signature: Uint8Array = new Uint8Array();
  let properties: Array<huks.HuksParam> = getSignProperties(mode);
  let option: huks.HuksOptions = {
    properties: properties,
    inData: EncodingUtils.stringToUnit8Array(HuksPropertiesConstants.PLAINTEXT)
  };
  let handle: number = 0;

  await huks.initSession(HuksPropertiesConstants.KEY_ALIAS, option).then((data) => {
    handle = data.handle;
  }).catch((error: BusinessError) => {
    Logger.error('密钥初始化失败，错误信息为:' + JSON.stringify(error));
  });

  await huks.finishSession(handle, option).then((data) => {
    let res: string = new util.Base64Helper().encodeToStringSync(data.outData);
    try {
      uiContext?.getPromptAction().showToast({
        message: CommonConstants.SIGNATURE_RESULT + res,
        duration: CommonConstants.TOAST_DURATION
      });
    } catch (error) {
      Logger.error('show toast failed,message is' + JSON.stringify(error));
    }
    signature = data.outData as Uint8Array;
  }).catch((error: BusinessError) => {
    Logger.error('验签finish阶段捕获异常，信息为' + JSON.stringify(error));
  });
  return signature;
}

export async function verify(signature: Uint8Array, mode: number) {
  if (signature === null) {
    try {
      uiContext?.getPromptAction().showToast({
        message: $r('app.string.signature_message_is_null'),
        duration: CommonConstants.TOAST_DURATION
      });
    } catch (error) {
      Logger.error('show toast failed,message is' + JSON.stringify(error));
    }
    return;
  }
  let properties: Array<huks.HuksParam> = getVerifyProperties(mode);
  let option: huks.HuksOptions = {
    properties: properties,
    inData: EncodingUtils.stringToUnit8Array(HuksPropertiesConstants.PLAINTEXT)
  };
  let handle: number = 0;

  await huks.initSession(HuksPropertiesConstants.KEY_ALIAS, option).then((data) => {
    handle = data.handle;
  }).catch((error: BusinessError) => {
    Logger.error('密钥初始化失败，错误信息为:' + JSON.stringify(error));
  });
  try {
    await huks.updateSession(handle, option);
  } catch (error) {
    Logger.error('update session failed,message is' + JSON.stringify(error));
  }
  option.inData = signature;

  await huks.finishSession(handle, option).then((data) => {
    try {
      uiContext?.getPromptAction().showToast({
        message: $r('app.string.Verification_success'),
        duration: CommonConstants.TOAST_DURATION
      });
    } catch (error) {
      Logger.error('get prompt action failed,message is' + JSON.stringify(error));
    }
  }).catch((error: BusinessError) => {
    Logger.error('验签finish阶段捕获异常，信息为' + JSON.stringify(error));
  });
}

export async function deleteSignKey(keyAlias: string) {
  try {
    await huks.deleteKeyItem(keyAlias, HuksPropertiesConstants.EMPTY_OPTION);
  } catch (error) {
    Logger.error('deleteSignKey failed,message is' + JSON.stringify(error));
  }
}