/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { resourceManager } from '@kit.LocalizationKit';
import { huks } from '@kit.UniversalKeystoreKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { userAuth } from '@kit.UserAuthenticationKit';
import { trustedAuthentication } from '@kit.DeviceSecurityKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import AssetUtils from '../utils/AssetUtils';

const TUI_PIN_SET = 1
const TUI_PIN_MODIFY = 2
const TUI_PIN_DISABLE = 3
const TUI_CONTENT_FACE_VERIFY = 5
const TUI_CONTENT_FINGERPRINT_VERIFY = 6
const TUI_BIND_FACE = 7
const TUI_BIND_FINGERPRINT = 8
const TUI_PIN_SET_MIX = 9
const TUI_PIN_MODIFY_MIX = 10
const DOMAIN = 0x0000
const KEY_ALIAS = 'test_sign_key_alias';

class throwObject {
  isThrow: boolean = false
}

function generateKeyItem(keyAlias: string, huksOptions: huks.HuksOptions, throwObject: throwObject): Promise<void> {
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
};

function GetEccVerifyProperties(): Array<huks.HuksParam> {
  let properties: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_ECC
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
  }, {
    tag: huks.HuksTag.HUKS_TAG_DIGEST,
    value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
  }, {
    tag: huks.HuksTag.HUKS_TAG_USER_AUTH_TYPE,
    value: huks.HuksUserAuthType.HUKS_USER_AUTH_TYPE_FACE
  }];
  return properties;
}

function GetEccSignProperties(): Array<huks.HuksParam> {
  let properties: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_ECC
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN
  }, {
    tag: huks.HuksTag.HUKS_TAG_DIGEST,
    value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SECURE_SIGN_TYPE,
    value: huks.HuksSecureSignType.HUKS_SECURE_SIGN_WITH_AUTHINFO
  }];
  return properties;
}

async function publicGenKeyFunc(keyAlias: string, huksOptions: huks.HuksOptions): Promise<void> {
  hilog.info(DOMAIN, 'testTag', `enter promise generatekeyItem`);
  let throwObject: throwObject = { isThrow: false };
  try {
    await generateKeyItem(keyAlias, huksOptions, throwObject)
      .then((data) => {
        hilog.info(DOMAIN, 'testTag', `promise: generateKeyItem success, data = ${JSON.stringify(data)}`);
      })
      .catch((error: Error) => {
        if (throwObject.isThrow) {
          throw (error as Error);
        } else {
          hilog.error(DOMAIN, 'testTag', `promise: generateKeyItem failed, ` + JSON.stringify(error));
        }
      });
  } catch (error) {
    hilog.error(DOMAIN, 'testTag', `promise: generateKeyItem input arg invlaid ` + JSON.stringify(error));
  }
};

async function SignFinish(handle: number, authToken: Uint8Array, plaintext: string): Promise<Uint8Array> {
  let signProperties = GetEccSignProperties();
  let options: huks.HuksOptions = {
    properties: signProperties,
    inData: stringToUint8Array(plaintext)
  }
  hilog.info(DOMAIN, 'testTag', '====inData====' + options.inData);
  hilog.info(DOMAIN, 'testTag', 'AAA finish Start' + handle, options, authToken);
  try {
    let data = await huks.finishSession(handle, options, authToken);
    let signature = data.outData as Uint8Array;
    hilog.info(DOMAIN, 'testTag', 'Sign Finish Success! Result: ' + JSON.stringify(data));
    return signature
  } catch (error) {
    hilog.error(DOMAIN, 'testTag', 'Sign Finish Exception ' + JSON.stringify(error));
    throw new Error('Sign Finish Exception ' + (error as BusinessError).message);
  }
}

function encodeUtf8(s: string): number[] {
  const encoder = new util.TextEncoder();
  const dest = new Uint8Array(s.length * 4);
  const result = encoder.encodeIntoUint8Array(s, dest);
  const encodedBytes = dest.subarray(0, result.written);
  return Array.from(encodedBytes);
}

function stringToUint8Array(str: string): Uint8Array {
  const utf8Bytes = new Uint8Array(encodeUtf8(str));
  return utf8Bytes;
}

async function Verify(indata: string, signature: Uint8Array): Promise<void> {
  let indataArray = stringToUint8Array(indata)
  hilog.info(DOMAIN, 'testTag', 'indata size = ' + indataArray.length + ' signature size = ' + signature.length);
  let appendInfo = signature.subarray(0, 41);
  let newSignature = signature.subarray(41);

  let newIndata = new Uint8Array(appendInfo.length + indataArray.length);
  newIndata.set(appendInfo, 0);
  newIndata.set(indataArray, appendInfo.length);
  let verifyProperties = GetEccVerifyProperties();
  let options: huks.HuksOptions = {
    properties: verifyProperties,
    inData: signature
  }
  try{
    let res = await huks.initSession(KEY_ALIAS, options)
    let handle = res.handle
    hilog.info(DOMAIN, 'testTag', 'Verify Update Begin' + JSON.stringify(options) + 'handle' + JSON.stringify(handle));
    options.inData = newIndata;
    await huks.updateSession(handle, options)
    hilog.info(DOMAIN, 'testTag', 'Verify Finish Begin' + JSON.stringify(options));
    hilog.info(DOMAIN, 'testTag', 'Verify Finish SIG' + JSON.stringify(signature));
    options.inData = newSignature;
    await huks.finishSession(handle, options)
  }catch (error) {
    hilog.error(DOMAIN, 'testTag', 'Verify error');
  }
};

class TrustedAuth {
  bigIntToUint8Array(value: bigint): Uint8Array {
    if (value < 0n) {
      throw new Error('only non-negative bigint values are supported');
    }

    if (value === 0n) {
      return new Uint8Array([0]);
    }

    const hex = value.toString(16);
    const len = hex.length % 2 === 0 ? hex.length / 2 : (hex.length + 1) / 2;
    const array = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      const offset = i * 2;
      const byteStr = hex.slice(offset, offset + 2) || '00';
      array[i] = parseInt(byteStr, 16);
    }
    return array;
  }

  uint8ArrayToBigInt(bytes: Uint8Array): bigint {
    let hex = '';
    for (const byte of bytes) {
      hex += byte.toString(16).padStart(2, '0');
    }
    return BigInt('0x' + hex);
  }

  async bindFaceID(handle: number, authToken: Uint8Array, inputdata: string): Promise<void> {
    let signature = await SignFinish(handle, authToken, inputdata);
    await Verify(inputdata, signature);
    let appendInfo = signature.subarray(0, 42);
    let credentialID = appendInfo.subarray(8, 40);
    let checkHash = appendInfo.subarray(40, 41);
    let authType = appendInfo.subarray(4, 8);
    hilog.info(DOMAIN, 'testTag', 'credentialId', credentialID);
    hilog.info(DOMAIN, 'testTag', 'checkHash', checkHash);
    hilog.info(DOMAIN, 'testTag', 'authType', authType);
    AssetUtils.AddDataToAssetStore(credentialID, 'face_credentialID', 'face_credential_label');
  }

  async bindFingerID(handle: number, authToken: Uint8Array, inputdata: string): Promise<void> {
    let signature = await SignFinish(handle, authToken, inputdata);
    await Verify(inputdata, signature);
    let appendInfo = signature.subarray(0, 42);
    let credentialID = appendInfo.subarray(8, 40);
    let checkHash = appendInfo.subarray(40, 41);
    let authType = appendInfo.subarray(4, 8);
    hilog.info(DOMAIN, 'testTag', 'credentialId', credentialID);
    hilog.info(DOMAIN, 'testTag', 'checkHash', checkHash);
    hilog.info(DOMAIN, 'testTag', 'authType', authType);
    AssetUtils.AddDataToAssetStore(credentialID, 'finger_credentialID', 'finger_credential_label');
  }

  async ImportImage(): Promise<ArrayBuffer> {
    try {
      const context = AppStorage.get('context') as Context;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const fileData: Uint8Array = await resourceMgr.getRawFileContent('startIcon.png');

      const firstTenElementsView = fileData.subarray(0, 20);
      hilog.info(DOMAIN, 'testTag', 'image size is ', fileData.buffer.byteLength);
      hilog.info(DOMAIN, 'testTag', 'image subarray is ', firstTenElementsView);
      return fileData.buffer;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to load image:', error);
      throw new Error('Unable to import image:' + (error as BusinessError).message);
    }
  }

  async PwdVerify(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.ShieldPwVerification'))
      }
      const result = await trustedAuthentication.trustedAuthentication(challenge, credentialID, label);
      hilog.info(DOMAIN, 'testTag', 'DigitalShield password verification success：', result.authToken.length,
        result.authToken);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'DigitalShield password verification failed：', error);
      throw new Error('DigitalShield password verification failed：' + (error as BusinessError).message);
    }
  }

  async SetPwdMix(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      const passwordInfo: trustedAuthentication.PasswordInfo = {
        pwdType: trustedAuthentication.PasswordType.PASSWORD_TYPE_MIXED,
        pwdMaxLength: 10,
        pwdMinLength: 6,
        maxAuthFailCount: 6
      };
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.OpenShield'))
      }
      const authInfo = await trustedAuthentication.enableTrustedAuthentication(challenge, passwordInfo, label);
      let assetLabel = assetName + 'label';
      AssetUtils.AddDataToAssetStore(this.bigIntToUint8Array(authInfo.authID), assetName, assetLabel);
      hilog.info(DOMAIN, 'testTag', 'Open Shield Success：', authInfo.authID, authInfo.authToken.length,
        authInfo.authToken);
      return authInfo;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Open Shield Fail：', error);
      throw new Error('Open Shield Fail：' + (error as BusinessError).message);
    }
  }

  async SetPwd(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      const passwordInfo: trustedAuthentication.PasswordInfo = {
        pwdType: trustedAuthentication.PasswordType.PASSWORD_TYPE_DIGITAL,
        pwdMaxLength: 10,
        pwdMinLength: 6,
        maxAuthFailCount: 6
      };
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.OpenShield'))
      }
      const authInfo = await trustedAuthentication.enableTrustedAuthentication(challenge, passwordInfo, label);
      let assetLabel = assetName + 'label';
      AssetUtils.AddDataToAssetStore(this.bigIntToUint8Array(authInfo.authID), assetName, assetLabel);
      hilog.info(DOMAIN, 'testTag', 'Open Shield Success：', authInfo.authID, authInfo.authToken.length,
        authInfo.authToken);
      return authInfo;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Open Shield Fail：', error);
      throw new Error('Open Shield Fail：' + (error as BusinessError).message);
    }
  }

  async ModifyPwdMix(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      const passwordInfo: trustedAuthentication.PasswordInfo = {
        pwdType: trustedAuthentication.PasswordType.PASSWORD_TYPE_MIXED,
        pwdMaxLength: 10,
        pwdMinLength: 6,
        maxAuthFailCount: 6
      };
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.ModifyShield'))
      }
      const authInfo =
        await trustedAuthentication.modifyTrustedAuthenticationPwd(challenge, passwordInfo, credentialID, label);
      hilog.info(DOMAIN, 'testTag', 'Modify Shield Success：', authInfo.authToken);
      return authInfo;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Modify Shield Fail：', error);
      throw new Error('Modify Shield Fail：' + (error as BusinessError).message);
    }
  }

  async ModifyPwd(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      const passwordInfo: trustedAuthentication.PasswordInfo = {
        pwdType: trustedAuthentication.PasswordType.PASSWORD_TYPE_DIGITAL,
        pwdMaxLength: 10,
        pwdMinLength: 6,
        maxAuthFailCount: 6
      };
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.ModifyShield'))
      }
      const authInfo =
        await trustedAuthentication.modifyTrustedAuthenticationPwd(challenge, passwordInfo, credentialID, label);
      hilog.info(DOMAIN, 'testTag', 'Modify Shield Success：', authInfo.authToken);
      return authInfo;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Modify Shield Fail：', error);
      throw new Error('Modify Shield Fail：' + (error as BusinessError).message);
    }
  }

  async DisablePwd(challenge: Uint8Array, assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.CloseShield'))
      }
      const authInfo = await trustedAuthentication.disableTrustedAuthentication(challenge, true, credentialID, label);
      AssetUtils.DeleteDataFromAssetStore('pin_label1');
      AssetUtils.DeleteDataFromAssetStore('credentialID');
      AssetUtils.DeleteDataFromAssetStore('face_credentialID');
      AssetUtils.DeleteDataFromAssetStore('finger_credentialID');
      hilog.info(DOMAIN, 'testTag', 'Close Shield Success：', authInfo.authToken);
      return authInfo;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Close Shield Fail：', error);
      throw new Error('Close Shield Fail：' + (error as BusinessError).message);
    }
  }

  async disablePwdWithoutAuth(challenge: Uint8Array, assetName: string): Promise<ArrayBuffer> {
    try {
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      let emptyBuffer = new ArrayBuffer(0);
      const label: trustedAuthentication.TUILable = {
        image: emptyBuffer,
        title: ''
      }
      const authInfo = await trustedAuthentication.disableTrustedAuthentication(challenge, false, credentialID, label);
      AssetUtils.DeleteDataFromAssetStore('pin_label1');
      AssetUtils.DeleteDataFromAssetStore('credentialID');
      AssetUtils.DeleteDataFromAssetStore('face_credentialID');
      AssetUtils.DeleteDataFromAssetStore('finger_credentialID');
      hilog.info(DOMAIN, 'testTag', 'Close Shield Success：', authInfo.authToken);
      return authInfo.authToken;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Close Shield Fail：', error);
      throw new Error('Close Shield Fail：' + (error as BusinessError).message);
    }
  }

  async FaceAuthContent(indata: string, challenge: Uint8Array,
    assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      let enrolledState = userAuth.getEnrolledState(userAuth.UserAuthType.FACE);
      hilog.info(DOMAIN, 'testTag',
        `get current enrolled state success enrolledState = ${JSON.stringify(enrolledState)}`);
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const reqParams: trustedAuthentication.AuthReqParams = {
        reqType: trustedAuthentication.AuthType.AUTH_TYPE_FACE,
        authContent: indata.split('\n')
      }
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.FaceVerification'))
      }
      const result = await trustedAuthentication.procContentAuthentication(challenge, credentialID, reqParams, label);
      hilog.info(DOMAIN, 'testTag', 'Face Verification Success：', result.authToken);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Face Verification Fail：', error);
      throw new Error('Face Verification Fail：' + (error as BusinessError).message);
    }
  }

  async FingerPrintAuthContent(indata: string, challenge: Uint8Array,
    assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      let enrolledState = userAuth.getEnrolledState(userAuth.UserAuthType.FINGERPRINT);
      hilog.info(DOMAIN, 'testTag',
        `get current enrolled state success enrolledState = ${JSON.stringify(enrolledState)}`);
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const reqParams: trustedAuthentication.AuthReqParams = {
        reqType: trustedAuthentication.AuthType.AUTH_TYPE_FINGERPRINT,
        authContent: indata.split('\n')
      }
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.FingerprintVerification'))
      }
      const result = await trustedAuthentication.procContentAuthentication(challenge, credentialID, reqParams, label);
      hilog.info(DOMAIN, 'testTag', 'Fingerprint Verification Success：', result.authToken);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Fingerprint Verification Fail：', error);
      throw new Error('Fingerprint Verification Fail：' + (error as BusinessError).message);
    }
  }

  async ContentVerifyByPwd(indata: string, challenge: Uint8Array,
    assetName: string): Promise<trustedAuthentication.AuthToken> {
    try {
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      const context = AppStorage.get('context') as Context;
      const buffer: ArrayBuffer = await this.ImportImage();
      const reqParams: trustedAuthentication.AuthReqParams = {
        reqType: trustedAuthentication.AuthType.AUTH_TYPE_TUI_PIN,
        authContent: indata.split('\n')
      }
      const label: trustedAuthentication.TUILable = {
        image: buffer,
        title: context.resourceManager.getStringSync($r('app.string.PINVerification'))
      }
      const result = await trustedAuthentication.procContentAuthentication(challenge, credentialID, reqParams, label);
      hilog.info(DOMAIN, 'testTag', 'Pin Verification Success：', result.authToken);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Pin Verification Fail：', error);
      throw new Error('Pin Verification Fail：' + (error as BusinessError).message);
    }
  }

  async TestGenKeyForTuiPinSign(): Promise<void> {
    let properties: Array<huks.HuksParam> = [{
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_ECC
    }, {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY
    }, {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    }, {
      tag: huks.HuksTag.HUKS_TAG_DIGEST,
      value: huks.HuksKeyDigest.HUKS_DIGEST_SHA256
    }, {
      tag: huks.HuksTag.HUKS_TAG_KEY_AUTH_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN
    }, {
      tag: huks.HuksTag.HUKS_TAG_USER_AUTH_TYPE,
      value: huks.HuksUserAuthType.HUKS_USER_AUTH_TYPE_PIN | huks.HuksUserAuthType.HUKS_USER_AUTH_TYPE_FINGERPRINT |
      huks.HuksUserAuthType.HUKS_USER_AUTH_TYPE_FACE
    }, {
      tag: huks.HuksTag.HUKS_TAG_KEY_AUTH_ACCESS_TYPE,
      value: huks.HuksAuthAccessType.HUKS_AUTH_ACCESS_ALWAYS_VALID
    }, {
      tag: huks.HuksTag.HUKS_TAG_CHALLENGE_TYPE,
      value: huks.HuksChallengeType.HUKS_CHALLENGE_TYPE_NORMAL
    }];
    let huksOptions: huks.HuksOptions = {
      properties: properties,
      inData: new Uint8Array(new Array())
    }
    await publicGenKeyFunc(KEY_ALIAS, huksOptions);
  };

  async SignInit(): Promise<huks.HuksSessionHandle> {
    let signProperties = GetEccSignProperties();
    let options: huks.HuksOptions = {
      properties: signProperties,
      inData: new Uint8Array
    }

    try {
      let result = await huks.initSession(KEY_ALIAS, options);
      let handle = result.handle;
      let challenge = result.challenge as Uint8Array
      hilog.info(DOMAIN, 'testTag', 'initSession complete' + handle + '----' + challenge);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'initSession failed');
      throw new Error('initSession fail' + (error as BusinessError).message);
    }
  }

  async disableTrustedBioAuthentication(assetName: string, authType: number): Promise<void> {
    try {
      let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore(assetName);
      let credentialID: bigint = this.uint8ArrayToBigInt(resArray);
      await trustedAuthentication.disableTrustedBioAuthentication(credentialID, authType);
      hilog.info(DOMAIN, 'testTag', 'unBound success');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'unBound fail', JSON.stringify(error));
      throw new Error('unBound fail' + (error as BusinessError).message);
    }
  }

  async HuksSignAndVerify(indata:string, session: huks.HuksSessionHandle, authToken: Uint8Array): Promise<void> {
    try {
      let signature = await SignFinish(session.handle, authToken, indata);
      hilog.info(DOMAIN, 'testTag', 'IAM auth on success' + signature);
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'IAM auth catch error', JSON.stringify(error));
      throw new Error('pull up IAM Fail' + (error as BusinessError).message);
    }
  }

  async UserAuthTUIPINBeforeSign(indata: string, session: huks.HuksSessionHandle, authType: number,
    label: string): Promise<void> {
    let challenge: Uint8Array = session.challenge as Uint8Array;
    let tempAuthToken: trustedAuthentication.AuthToken;
    if (authType === TUI_PIN_SET) {
      hilog.info(DOMAIN, 'testTag', '============createPW============');
      tempAuthToken = await this.SetPwd(challenge, label);
    } else if (authType === TUI_PIN_MODIFY) {
      hilog.info(DOMAIN, 'testTag', '============modifyPW============');
      tempAuthToken = await this.ModifyPwd(challenge, label);
    } else if (authType === TUI_PIN_DISABLE) {
      hilog.info(DOMAIN, 'testTag', '============closeShield============');
      tempAuthToken = await this.DisablePwd(challenge, label);
    } else if (authType === TUI_PIN_SET_MIX) {
      hilog.info(DOMAIN, 'testTag', '============createPW============');
      tempAuthToken = await this.SetPwdMix(challenge, label);
    } else if (authType === TUI_PIN_MODIFY_MIX) {
      hilog.info(DOMAIN, 'testTag', '============modifyPW============');
      tempAuthToken = await this.ModifyPwdMix(challenge, label);
    } else {
      hilog.info(DOMAIN, 'testTag', '============startPINVerification============');
      tempAuthToken = await this.ContentVerifyByPwd(indata, challenge, label);
    }
    const TuiAuthToken: trustedAuthentication.AuthToken = tempAuthToken;
    let authToken = TuiAuthToken.authToken;
    try {
      SignFinish(session.handle, authToken, indata).then((data) => {
        let signature = data as Uint8Array;
        Verify(indata, signature);
      });
      hilog.info(DOMAIN, 'testTag', 'HUKS -> IAM auth on success');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'HUKS -> IAM auth error', JSON.stringify(error));
      throw new Error('pull up IAM Fail' + (error as BusinessError).message);
    }
  }

  async UserAuthBeforeSign(session: huks.HuksSessionHandle, authType: number): Promise<Uint8Array> {
    let authTypeList: number[] = new Array();
    if (authType === TUI_BIND_FACE || authType === TUI_CONTENT_FACE_VERIFY) {
      authTypeList[0] = userAuth.UserAuthType.FACE;
    } else {
      authTypeList[0] = userAuth.UserAuthType.FINGERPRINT;
    }
    const authParam: userAuth.AuthParam = {
      challenge: session.challenge as Uint8Array,
      authType: authTypeList,
      authTrustLevel: userAuth.AuthTrustLevel.ATL4
    };
    const widgetParam: userAuth.WidgetParam = {
      title: ' '
    };
    try {
      hilog.info(DOMAIN, 'testTag', 'auth start');
      const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam);
      hilog.info(DOMAIN, 'testTag', 'auth success');

      return new Promise((resolve) => {
        userAuthInstance.on('result', {
          onResult(result) {
            let authTokenData = result.token;
            hilog.info(DOMAIN, 'testTag', 'auth result authTokenData', authTokenData);
            resolve(authTokenData);
          }
        });
        userAuthInstance.start();
      });
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'HUKS -> IAM auth error', JSON.stringify(error));
      throw new Error('pull up IAM Fail' + (error as BusinessError).message);
    }
  }

  async GetTUIAuthTokenBeforeBioVerify(indata: string, session: huks.HuksSessionHandle, authType: number,
    assetName: string): Promise<Uint8Array> {
    let challenge: Uint8Array = session.challenge as Uint8Array;
    let tempAuthToken: trustedAuthentication.AuthToken;

    try {
      if (authType === TUI_BIND_FACE) {
        try {
          let enrolledState = userAuth.getEnrolledState(userAuth.UserAuthType.FACE);
          hilog.info(DOMAIN, 'testTag',
            `get current face enrolled state success enrolledState = ${JSON.stringify(enrolledState)}`);
        } catch (error) {
          hilog.error(DOMAIN, 'testTag', `get current face enrolled state failed, error = ${JSON.stringify(error)}`);
          throw new Error('bind' + (error as BusinessError).message);
        }
        tempAuthToken = await this.PwdVerify(challenge, assetName);
      } else if (authType === TUI_BIND_FINGERPRINT) {
        try {
          let enrolledState = userAuth.getEnrolledState(userAuth.UserAuthType.FINGERPRINT);
          hilog.info(DOMAIN, 'testTag',
            `get current fingerprint enrolled state success enrolledState = ${JSON.stringify(enrolledState)}`);
        } catch (error) {
          hilog.error(DOMAIN, 'testTag',
            `get current fingerprint enrolled state failed, error = ${JSON.stringify(error)}`);
          throw new Error('bind' + (error as BusinessError).message);
        }
        tempAuthToken = await this.PwdVerify(challenge, assetName);
      } else if (authType === TUI_CONTENT_FACE_VERIFY) {
        tempAuthToken = await this.FaceAuthContent(indata, challenge, assetName);
      } else if (authType === TUI_CONTENT_FINGERPRINT_VERIFY) {
        tempAuthToken = await this.FingerPrintAuthContent(indata, challenge, assetName);
      } else {
        throw new Error(`invalid auth type; ${JSON.stringify(authType)}`);
      }
      return tempAuthToken.authToken;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `get TUI Authtoken failed. Code is ${err?.code}, message is ${err?.message}`);
      throw new Error((err as BusinessError).message);
    }
  }
}

export default new TrustedAuth();

