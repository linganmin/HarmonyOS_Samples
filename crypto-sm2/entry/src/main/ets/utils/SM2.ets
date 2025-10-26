/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { buffer, util } from '@kit.ArkTS';
import { SM2CipherText } from './SM2CipherText';

const DOMAIN = 0x0000;
const TAG = 'SM2';
const FORMAT = '%{public}s';

async function genECCPubKey(key: string) {
  let mode: number = 1;
  let pk: cryptoFramework.Point = {
    x: BigInt(''),
    y: BigInt(''),
  };
  if ((mode & 0x01) != 0 && key != null) {
    pk = {
      x: BigInt('0x' + key.substring(0, 64)),
      y: BigInt('0x' + key.substring(64, 128)),
    }
  }
  let keyPairGenerator: cryptoFramework.AsyKeyGeneratorBySpec;
  let pubKeySpec: cryptoFramework.ECCPubKeySpec = {
    params: genSM2CommonSpec(),
    pk: pk,
    algName: 'ECC',
    specType: cryptoFramework.AsyKeySpecType.PUBLIC_KEY_SPEC
  };
  try {
    keyPairGenerator = cryptoFramework.createAsyKeyGeneratorBySpec(pubKeySpec);
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `CreateAsyKeyGeneratorBySpec failed. Cause code: ${err.code}, message: ${err.message}`);
  }
  try {
    return await keyPairGenerator!.generatePubKey();
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT, `GeneratePubKey failed. Cause code: ${err.code}, message: ${err.message}`);
    return;
  }
}

async function genECCPriKey(key: string) {
  let mode: number = 2;
  let sk: bigint = BigInt('');
  if ((mode & 0x02) != 0) {
    sk = BigInt('0x' + key);
  }
  let keyPairGenerator: cryptoFramework.AsyKeyGeneratorBySpec;
  let priKey: cryptoFramework.ECCPriKeySpec = {
    params: genSM2CommonSpec(),
    sk: sk,
    algName: 'ECC',
    specType: cryptoFramework.AsyKeySpecType.PRIVATE_KEY_SPEC
  };
  try {
    keyPairGenerator = cryptoFramework.createAsyKeyGeneratorBySpec(priKey);
    return await keyPairGenerator.generatePriKey();
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `CreateAsyKeyGeneratorBySpec or generatePriKey failed. Cause code: ${err.code}, message: ${err.message}`);
    return;
  }
}

export function genSM2CommonSpec(): cryptoFramework.ECCCommonParamsSpec {
  let fieldFp: cryptoFramework.ECFieldFp = {
    fieldType: 'Fp',
    p: BigInt('0xFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF')
  }

  let G: cryptoFramework.Point = {
    x: BigInt('0x32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7'),
    y: BigInt('0xBC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0')
  }

  let SM2CommonSpec: cryptoFramework.ECCCommonParamsSpec = {
    algName: 'ECC',
    specType: cryptoFramework.AsyKeySpecType.COMMON_PARAMS_SPEC,
    field: fieldFp,
    a: BigInt('0xFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC'),
    b: BigInt('0x28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93'),
    g: G,
    n: BigInt('0xFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123'),
    h: 1
  }
  return SM2CommonSpec;
}

export async function genSM2Key(pubKey: cryptoFramework.DataBlob | null,
  priKey: cryptoFramework.DataBlob | null): Promise<cryptoFramework.KeyPair | undefined> {
  try {
    let generator = cryptoFramework.createAsyKeyGenerator('SM2_256');
    return await generator.convertKey(pubKey, priKey);
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `CreateAsyKeyGenerator or convertKey failed. Cause code: ${err.code}, message: ${err.message}`);
    return;
  }
}

async function encryptByPrimalKey(message: string, key: string): Promise<string> {
  try {
    let base64Helper = new util.Base64Helper();
    console.log(`key len: ${key.length}`);
    let pubKey = await genECCPubKey(key);
    let keyPair = await genSM2Key(pubKey!.getEncoded(), null);
    let cipher = cryptoFramework.createCipher('SM2_256|SM3');
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyPair!.pubKey, null);
    let plainTextBlob: cryptoFramework.DataBlob = { data: new Uint8Array(buffer.from(message, 'utf-8').buffer) };
    let encryptBlob = await cipher.doFinal(plainTextBlob);
    return base64Helper.encodeToStringSync(encryptBlob.data);
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `getEncoded or createCipher or init or doFinal failed. Cause code: ${err.code}, message: ${err.message}`);
    return '';
  }
}

export async function encryptSM2(message: string) {
  let pubKey: string = '5A033A9DBEF84C0784C897D070E6608C5AEED39B806DF82853D64E2A686A3794' +
    'F9233D20DD878F642D61C2B0344988AE284646226767A1631BBB0DBB6DF40D07';
  return encryptByPrimalKey(message, pubKey);
}

async function decryptByPrimalKeyArray(messageArray: Uint8Array, key: string): Promise<string> {
  try {
    let priKey = await genECCPriKey(key);
    let keyPair = await genSM2Key(null, priKey!.getEncoded());
    let cipher = cryptoFramework.createCipher('SM2_256|SM3');
    await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, keyPair!.priKey, null);
    let plainTextBlob: cryptoFramework.DataBlob = { data: messageArray };
    let decryptBlob = await cipher.doFinal(plainTextBlob);
    return buffer.from(decryptBlob.data).toString('utf-8');
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `GetEncoded or createCipher or init or doFinal or buffer.from failed. Cause code: ${err.code}, message: ${err.message}`);
    return '';
  }
}

export async function decryptSM2(encryptedStr: string, isc1c3c2: Boolean = false): Promise<string> {
  let priKey: string = '3629EFF03FBC86711F6695CBF5590F0F2FCAAA3C269A1CA9BD64FB4C70DF9C9F';
  if (isc1c3c2) {
    let hexStr = new SM2CipherText().i2dSM2CipherText(encryptedStr);
    let encryptedArray = new Uint8Array(buffer.from(hexStr, 'hex').buffer);
    return decryptByPrimalKeyArray(encryptedArray, priKey);
  } else {
    let base64Helper = new util.Base64Helper;
    let message = base64Helper.decodeSync(encryptedStr);
    return decryptByPrimalKeyArray(message, priKey);
  }
}