/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer, util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[CipherModel]';
const AES_ENCRYPT_KEY: string = '5QXzAbJj0TJN9OQNvxFhhw==';
const RSA_ENCRYPT_KEY: string =
  'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALXJZEloyLbBB6UbUQzUtM3WGTkcd4dn4HgCxL5wHcdICoLbv6EiUjcaQq8c906hqv6/J7Bv9Owj59XMauKweJUCAwEAAQ==';
const RSA_DECRYPT_KEY: string =
  'MIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEAtclkSWjItsEHpRtRDNS0zdYZORx3h2fgeALEvnAdx0gKgtu/oSJSNxpCrxz3TqGq/r8nsG/07CPn1cxq4rB4lQIDAQABAkA3boG2IM2TbKj4H6xHTVUUrwRh9dw83eAEuFNl/qoV6c4zRUAx+efZ29rDz6CVWuAhxaVBDUOmOHvyxOL8m8IBAiEA3EcTP1jngtiJ8lffvIVbehM6p7437+9UScKMXZSy/PkCIQDTRFj00GbAW9oKqEWTrUCWNxNFCSR82Mlw1sZvQh5LfQIgBApBrh3BUUMLdKhr8Bc6EEkeAEma2Qm4sAmjbWv2xHECIF81ux1BWj0wZ9hLs2d1Odk4ot+G2kHFdSr8L9tuIbcFAiEA2rEXmzyQTxZM1N4QDkaLJiCwSfMTYu48DxfUcevbfhA=';
const RSA512_PRIMES_2: string = 'RSA512|PRIMES_2';
const RSA512_PKCS1: string = 'RSA512|PKCS1';
const AES128: string = 'AES128';
const AES128_PKCS7: string = 'AES128|PKCS7';

export class CipherModel {
  stringToUint8Array(str) {
    return new Uint8Array(buffer.from(str, 'utf-8').buffer);
  }

  uint8ArrayToString(array: Uint8Array) {
    let out: string = '';
    let index: number = 0;
    let len: number = array.length;
    while (index < len) {
      let character = array[index++];
      switch (character >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          out += String.fromCharCode(character);
          break;
        case 12:
        case 13:
          out += String.fromCharCode(((character & 0x1F) << 6) | (array[index++] & 0x3F));
          break;
        case 14:
          out += String.fromCharCode(((character & 0x0F) << 12) | ((array[index++] & 0x3F) << 6) |
            ((array[index++] & 0x3F) << 0));
          break;
        default:
          break;
      }
    }
    return out;
  }

  rsaEncrypt(message: string, callback) {
    try {
      let rsaGenerator = cryptoFramework.createAsyKeyGenerator(RSA512_PRIMES_2);
      let cipher = cryptoFramework.createCipher(RSA512_PKCS1);
      let that = new util.Base64Helper();
      let pubKey = that.decodeSync(RSA_ENCRYPT_KEY);
      let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKey };
      rsaGenerator.convertKey(pubKeyBlob, null, (err, keyPair) => {
        if (err) {
          hilog.error(0x0000, TAG, 'convertKey: error.' + (err as BusinessError).code);
          return;
        }
        cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyPair.pubKey, null, (_err) => {
          let input: cryptoFramework.DataBlob = { data: this.stringToUint8Array(message) };
          cipher.doFinal(input, (_err, data) => {
            hilog.info(0x0000, TAG, 'EncryptOutPut is ' + data.data);
            let result = that.encodeToStringSync(data.data);
            hilog.info(0x0000, TAG, 'result is ' + result);
            callback(result);
          })
        })
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Error in rsaEncrypt. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  rsaDecrypt(message: string, callback) {
    try {
      let rsaGenerator = cryptoFramework.createAsyKeyGenerator(RSA512_PRIMES_2);
      let cipher = cryptoFramework.createCipher(RSA512_PKCS1);
      let that = new util.Base64Helper();
      let priKey = that.decodeSync(RSA_DECRYPT_KEY);
      let priKeyBlob: cryptoFramework.DataBlob = { data: priKey };
      rsaGenerator.convertKey(null, priKeyBlob, (err, keyPair) => {
        if (err) {
          hilog.error(0x0000, TAG, 'convertKey: error.' + (err as BusinessError).code);
          return;
        }
        cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, keyPair.priKey, null, (_err) => {
          try {
            let newMessage = that.decodeSync(message);
            let input: cryptoFramework.DataBlob = { data: newMessage };
            cipher.doFinal(input, (err, data) => {
              if (err) {
                hilog.error(0x0000, TAG, 'cipher doFinal.' + (err as BusinessError).code);
                return;
              }
              hilog.info(0x0000, TAG, 'DecryptOutPut is ' + data.data);
              let result = this.uint8ArrayToString(data.data);
              hilog.info(0x0000, TAG, 'result is ' + result);
              callback(result);
            })
          } catch (err) {
            hilog.error(0x0000, TAG, 'cipher init error: ' + (err as BusinessError).code);
            return err;
          }
        })
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Error in rsaDecrypt. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  aesEncrypt(message: string, callback) {
    try {
      let aesGenerator = cryptoFramework.createSymKeyGenerator(AES128);
      let cipher = cryptoFramework.createCipher(AES128_PKCS7);
      let that = new util.Base64Helper();
      let pubKey = that.decodeSync(AES_ENCRYPT_KEY);
      let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKey };
      aesGenerator.convertKey(pubKeyBlob, (err, symKey) => {
        if (err) {
          console.error('convertKey: error.' + (err as BusinessError).code);
          return;
        }
        cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, null, (_err) => {
          let input: cryptoFramework.DataBlob = { data: this.stringToUint8Array(message) };
          cipher.doFinal(input, (_err, data) => {
            hilog.info(0x0000, TAG, 'EncryptOutPut is ' + data.data);
            let result = that.encodeToStringSync(data.data);
            hilog.info(0x0000, TAG, 'result is ' + result);
            callback(result);
          })
        })
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Error in aesEncrypt. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  aesDecrypt(message: string, callback) {
    try {
      let aesGenerator = cryptoFramework.createSymKeyGenerator(AES128);
      let cipher = cryptoFramework.createCipher(AES128_PKCS7);
      let that = new util.Base64Helper();
      let pubKey = that.decodeSync(AES_ENCRYPT_KEY);
      let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKey };
      aesGenerator.convertKey(pubKeyBlob, (err, symKey) => {
        if (err) {
          console.error('convertKey: error.' + (err as BusinessError).code);
          return;
        }
        cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, null, (_err) => {
          try {
            let newMessage = that.decodeSync(message);
            let input: cryptoFramework.DataBlob = { data: newMessage };
            cipher.doFinal(input, (err, data) => {
              if (err) {
                hilog.error(0x0000, TAG, 'cipher doFinal.' + (err as BusinessError).code);
                return;
              }
              hilog.info(0x0000, TAG, 'DecryptOutPut is ' + data?.data);
              let result = this.uint8ArrayToString(data?.data)
              hilog.info(0x0000, TAG, 'result is ' + result);
              callback(result);
            })
          } catch (err) {
            hilog.error(0x0000, TAG, 'cipher init error: ' + (err as BusinessError).code);
            return err;
          }
        })
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Error in aesDecrypt. Cause code: ${err.code}, message: ${err.message}`);
    }
  }
}