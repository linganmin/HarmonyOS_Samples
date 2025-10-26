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
import { EncodingUtils } from './EncodingUtils';
import { HuksPropertiesConstants } from '../constants/HuksPropertiesConstants';
import { CommonConstants } from '../constants/CommonConstants';
import Logger from './Logger';

let finishOutData: Uint8Array;
let handle: number;
let exportKey: Uint8Array;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

class throwObject {
  isThrow: boolean = false;
}

export async function huksDhAgreeInHuks(pubKeyA: huks.HuksReturnResult, pubKeyB: huks.HuksReturnResult) {
  const dhAgreeInit: huks.HuksOptions = {
    properties: [
      ...HuksPropertiesConstants.DH_AGREE,
      {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
      },
      {
        tag: huks.HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
        value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
      },
      {
        tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
        value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
      }
    ],
    inData: new Uint8Array([])
  };
  const dhAgreeFinishParams: Array<huks.HuksParam> = [
    {
      tag: huks.HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
      value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
    },
    {
      tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
      value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
    },
    {
      tag: huks.HuksTag.HUKS_TAG_IS_KEY_ALIAS,
      value: true
    },
    {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_AES
    },
    {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    },
    {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
    }
  ];
  try {
    const handleA = await huks.initSession(HuksPropertiesConstants.ALISA_A, dhAgreeInit);
    const dhAgreeUpdatePubKeyB: huks.HuksOptions = {
      properties: [
        ...HuksPropertiesConstants.DH_AGREE,
        {
          tag: huks.HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
          value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
        },
        {
          tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
          value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
        }
      ],
      inData: pubKeyB.outData
    };
    await huks.updateSession(handleA.handle, dhAgreeUpdatePubKeyB);
    const aliasAgreeKeyFromA = 'agreeKeyFromA';
    const dhAgreeAFinish: huks.HuksOptions = {
      properties: [
        ...dhAgreeFinishParams, {
        tag: huks.HuksTag.HUKS_TAG_KEY_ALIAS,
        value: EncodingUtils.stringToUnit8Array(aliasAgreeKeyFromA)
      }],
      inData: new Uint8Array([])
    };
    const agreeKeyFromA = await huks.finishSession(handleA.handle, dhAgreeAFinish);
    if (agreeKeyFromA.outData !== undefined) {
      Logger.info('finish session ok! agreeKeyA in huks is 0x' +
      EncodingUtils.unit8ArrayToBigInt(agreeKeyFromA.outData).toString(16));
    } else {
      return;
    }
    const keyAAgreeExist = await huks.isKeyItemExist(aliasAgreeKeyFromA, HuksPropertiesConstants.EMPTY_OPTION);
    Logger.info('isKeyItemExist aliasAgreeKeyFromA in huks is ' + keyAAgreeExist);

    const handleB = await huks.initSession(HuksPropertiesConstants.ALISA_B, dhAgreeInit);
    const dhAgreeUpdatePubKeyA: huks.HuksOptions = {
      properties: [
        ...HuksPropertiesConstants.DH_AGREE,
        {
          tag: huks.HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
          value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
        },
        {
          tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
          value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
        }
      ],
      inData: pubKeyA.outData
    };
    await huks.updateSession(handleB.handle, dhAgreeUpdatePubKeyA);
    const aliasAgreeKeyFromB = 'agreeKeyFromB';
    const dhAgreeBFinish: huks.HuksOptions = {
      properties: [
        ...dhAgreeFinishParams, {
        tag: huks.HuksTag.HUKS_TAG_KEY_ALIAS,
        value: EncodingUtils.stringToUnit8Array(aliasAgreeKeyFromB)
      }],
      inData: new Uint8Array([])
    };
    const agreeKeyFromB = await huks.finishSession(handleB.handle, dhAgreeBFinish);
    if (agreeKeyFromB.outData !== undefined) {
      Logger.info('finish session ok! agreeKeyB in huks is 0x' +
      EncodingUtils.unit8ArrayToBigInt(agreeKeyFromB.outData).toString(16));
    } else {
      return;
    }

    const keyBAgreeExist = await huks.isKeyItemExist(aliasAgreeKeyFromB, HuksPropertiesConstants.EMPTY_OPTION);
    Logger.info('isKeyItemExist aliasAgreeKeyFromA in huks is ' + keyBAgreeExist);
    uiContext?.getPromptAction().showToast({
      message: $r('app.string.KeyNegotiationSuccess'),
      duration: CommonConstants.TOAST_DURATION
    });

    await huks.deleteKeyItem(aliasAgreeKeyFromA, HuksPropertiesConstants.EMPTY_OPTION);
    await huks.deleteKeyItem(aliasAgreeKeyFromB, HuksPropertiesConstants.EMPTY_OPTION);
  } catch (error) {
    Logger.error(`huks failed, ${JSON.stringify(error)}`);
  }

}

function generateKeyItem(keyAlias: string, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<void>((resolve, reject) => {
    try {
      huks.generateKeyItem(keyAlias, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicGenKeyFunc(keyAlias: string, huksOptions: huks.HuksOptions) {
  Logger.info(`enter promise generateKeyItem`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await generateKeyItem(keyAlias, huksOptions, throwObject)
      .then((data) => {
        Logger.info(`promise: generateKeyItem success, data = ${JSON.stringify(data)}`);
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          Logger.error(`promise: generateKeyItem failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: generateKeyItem input arg invalid, ${JSON.stringify(error)}`);
  }
}

function initSession(keyAlias: string, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<huks.HuksSessionHandle>((resolve, reject) => {
    try {
      huks.initSession(keyAlias, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicInitFunc(keyAlias: string, huksOptions: huks.HuksOptions): Promise<number> {
  Logger.info(`enter promise doInit`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await initSession(keyAlias, huksOptions, throwObject)
      .then((data) => {
        Logger.info(`promise: doInit success, data = ${JSON.stringify(data)}`);
        handle = data.handle;
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          Logger.error(`promise: doInit failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: doInit input arg invalid, ${JSON.stringify(error)}`);
  }
  return handle;
}

function updateSession(handle: number, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<huks.HuksReturnResult>((resolve, reject) => {
    try {
      huks.updateSession(handle, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicUpdateFunc(handle: number, huksOptions: huks.HuksOptions) {
  Logger.info(`enter promise doUpdate`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await updateSession(handle, huksOptions, throwObject)
      .then((data) => {
        Logger.info(`promise: doUpdate success, data = ${JSON.stringify(data)}`);
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          Logger.error(`promise: doUpdate failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: doUpdate input arg invalid, ${JSON.stringify(error)}`);
  }
}

function finishSession(handle: number, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<huks.HuksReturnResult>((resolve, reject) => {
    try {
      huks.finishSession(handle, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicFinishFunc(handle: number, huksOptions: huks.HuksOptions) {
  Logger.info(`enter promise doFinish`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await finishSession(handle, huksOptions, throwObject)
      .then((data) => {
        finishOutData = data.outData as Uint8Array;
        Logger.info(`promise: doFinish success, data = ${JSON.stringify(data)}`);
        uiContext?.getPromptAction().showToast({
          message: $r('app.string.KeyNegotiationSuccess'),
          duration: CommonConstants.TOAST_DURATION
        });
        publicExportKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_FIRST, huksOptions);
        publicExportKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_SECOND, huksOptions);
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          uiContext?.getPromptAction().showToast({
            message: $r('app.string.key_missing'),
            duration: CommonConstants.TOAST_DURATION
          });
          Logger.error(`promise: doFinish failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: doFinish input arg invalid, ${JSON.stringify(error)}`);
  }
}

function exportKeyItem(keyAlias: string, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<huks.HuksReturnResult>((resolve, reject) => {
    try {
      huks.exportKeyItem(keyAlias, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicExportKeyFunc(keyAlias: string, huksOptions: huks.HuksOptions): Promise<Uint8Array> {
  Logger.info(`enter promise export`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await exportKeyItem(keyAlias, huksOptions, throwObject)
      .then((data) => {
        Logger.info(`promise: exportKeyItem success, data = ${JSON.stringify(data)}`);
        exportKey = data.outData as Uint8Array;
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          Logger.error(`promise: exportKeyItem failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: exportKeyItem input arg invalid, ${JSON.stringify(error)}`);
  }
  return exportKey;
}

function deleteKeyItem(keyAlias: string, huksOptions: huks.HuksOptions, throwObject: throwObject) {
  return new Promise<void>((resolve, reject) => {
    try {
      huks.deleteKeyItem(keyAlias, huksOptions, (error, data) => {
        if (error) {
          reject(error);
        } else {
          resolve(data);
        }
      });
    } catch (error) {
      throwObject.isThrow = true;
      throw (error as Error);
    }
  });
}

export async function publicDeleteKeyFunc(keyAlias: string, huksOptions: huks.HuksOptions) {
  Logger.info(`enter promise deleteKeyItem`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await deleteKeyItem(keyAlias, huksOptions, throwObject)
      .then((data) => {
        Logger.info(`promise: deleteKeyItem key success, data = ${JSON.stringify(data)}`);
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          Logger.error(`promise: deleteKeyItem failed, ${JSON.stringify(error)}`);
        }
      });
  } catch (error) {
    Logger.error(`promise: deleteKeyItem input arg invalid, ${JSON.stringify(error)}`);
  }
}