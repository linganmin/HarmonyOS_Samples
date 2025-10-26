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
* FAQ:如何对公钥和私钥进行加解密
*/

// [Start EncryptionAndDecryption]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

let base = new util.Base64Helper();
let pubKeyStr = uint8ArrayToHexStr(base.decodeSync('公钥'));
let priKeyStr = uint8ArrayToHexStr(base.decodeSync('私钥'));

async function encryptionAndDecryption() {
  // Generate public and private keys based on the key parameters
  let pk = await convertStrToPubKey(pubKeyStr);
  let sk = await convertStrToPriKey(priKeyStr);

  // Encryption 
  let encryptText = await encryptMessagePromise(pk, '加密信息');
  // Decryption
  let res = await decryptMessagePromise(sk, encryptText);
}

// Generate SM2 public key based on key parameters
async function convertStrToPubKey(keyStr: string): Promise<cryptoFramework.PubKey> {
  let pubKeyStr = keyStr.startsWith("04") ? keyStr.slice(2) : keyStr;
  let pkPart1 = pubKeyStr.slice(0, pubKeyStr.length / 2);
  let pkPart2 = pubKeyStr.slice(pubKeyStr.length / 2);
  let pk: cryptoFramework.Point = {
    x: BigInt("0x" + pkPart1),
    y: BigInt("0x" + pkPart2),
  }
  let pubKeySpec: cryptoFramework.ECCPubKeySpec = {
    params: cryptoFramework.ECCKeyUtil.genECCCommonParamsSpec('NID_sm2'),
    pk: pk,
    algName: "SM2",
    specType: cryptoFramework.AsyKeySpecType.PUBLIC_KEY_SPEC
  }
  let keypairGenerator = cryptoFramework.createAsyKeyGeneratorBySpec(pubKeySpec);
  return await keypairGenerator.generatePubKey();
}

// Generate SM2 private key based on key parameters 
async function convertStrToPriKey(keyStr: string): Promise<cryptoFramework.PriKey> {
  let sk = BigInt("0x" + keyStr);
  let priKeySpec: cryptoFramework.ECCPriKeySpec = {
    params: cryptoFramework.ECCKeyUtil.genECCCommonParamsSpec('NID_sm2'),
    sk: sk,
    algName: "SM2",
    specType: cryptoFramework.AsyKeySpecType.PRIVATE_KEY_SPEC
  }
  let keypairGenerator = cryptoFramework.createAsyKeyGeneratorBySpec(priKeySpec);
  return await keypairGenerator.generatePriKey();
}

// Decryption message
async function decryptMessagePromise(privateKey: cryptoFramework.PriKey, cipherText: cryptoFramework.DataBlob) {
  let decoder = cryptoFramework.createCipher('SM2_256|SM3');
  await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, privateKey, null);
  let decryptData = await decoder.doFinal(cipherText);
  return decryptData;
}

// Encrypted message
async function encryptMessagePromise(publicKey: cryptoFramework.PubKey, plainText: string) {
  let cipher = cryptoFramework.createCipher('SM2_256|SM3');
  await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, publicKey, null);
  let encryptData = await cipher.doFinal({ data: stringToUint8Array(plainText) });
  return encryptData;
}

function uint8ArrayToHexStr(data: Uint8Array): string {
  let hexString = '';
  let i: number;
  for (i = 0; i < data.length; i++) {
    let char = ('00' + data[i].toString(16)).slice(-2);
    hexString += char;
  }
  return hexString;
}

function stringToUint8Array(str: string) {
  let arr = new Uint8Array(str.length);
  for (let i = 0, j = str.length; i < j; ++i) {
    arr[i] = str.charCodeAt(i);
  }
  return arr;
}
// [End EncryptionAndDecryption]