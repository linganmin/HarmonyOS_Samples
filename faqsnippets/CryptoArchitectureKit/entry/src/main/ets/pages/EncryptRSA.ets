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
* FAQ:如何使用服务端下发的RSA公钥（字符串）对明文数据进行加密
*/

// [Start EncryptRSA]
import { buffer, util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
/**
 * Encrypt using RSA asymmetric key (PKCS1 mode)
 * @param message Clear text data to be encrypted
 * @returns Encrypted string, encoded in base64 format
 */
export async function encryptRSA(message: string) {
  // Server issues RSA public key string (base64 encoding)
  let pubKeyStr = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFQArGDm5BXM4jHHuZGIb/kUoqrSjXkjqPLgrDmqBFxNyYsyxvyFRO10nStQwdRkQkh5lZ5sqC1G/z6lyDPpEySTBo9S5GLZ2Tj4yinNjcMXmOwiHfyQAQo9LwdlyTedwRchg0fYewWBVTVhGcWPowT1aA+GnQhYwNmaS/iKQsNQIDAQAB";
  // Initialize Base64 tool instance
  let base64Helper = new util.Base64Helper();
  // Convert the public key to Uint8Array and package it as a DataBlob type
  let pubKeyBlob: cryptoFramework.DataBlob = { data: base64Helper.decodeSync(pubKeyStr) };
  // Create RSA key generator
  let rsaGenerator = cryptoFramework.createAsyKeyGenerator('RSA1024');
  // Convert the public key wrapper data pubKeyBlob into a key pair type KeyPair
  let keyPair = await rsaGenerator.convertKey(pubKeyBlob, null);
  // Create a Cipher object
  let cipher = cryptoFramework.createCipher('RSA1024|PKCS1');
  // Initialize encryption mode and specify the key keyPair. pubKey
  await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyPair.pubKey, null);
  // Packaging requires encrypted plaintext
  let plainTextBlob: cryptoFramework.DataBlob = { data: new Uint8Array(buffer.from(message, 'utf-8').buffer) };
  // Pass in plaintext and retrieve encrypted data
  let encryptBlob = await cipher.doFinal(plainTextBlob);
  // Return encrypted string
  return base64Helper.encodeToStringSync(encryptBlob.data);
}
// [End EncryptRSA]