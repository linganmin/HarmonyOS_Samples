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
* FAQ:如何实现RSA的公钥PK加密一段文字
*/

// [Start RsaDecrypt]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, util } from '@kit.ArkTS';

// Convert string to byte stream 
function stringToUint8Array(str: string) {
  return new Uint8Array(buffer.from(str, 'utf-8').buffer);
}

// Convert byte stream into an understandable string
function uint8ArrayToString(array: Uint8Array) {
  // Convert UTF-8 encoding to Unicode encoding
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

export class KeyPair {
  publicKey: string = '';
  privateKey: string = '';
}

export class RSA {
  private ASY_KEY_NAME_RSA_3072: string = 'RSA1024';
  private ALG_NAME_RSA_3072: string = 'RSA|PKCS1';
  static priKey: Uint8Array = new Uint8Array(); // For temporary storage
  static pubKey: Uint8Array = new Uint8Array(); // For temporary storage
  private base: util.Base64Helper = new util.Base64Helper();

  public async generateRsaKeyPair(): Promise<KeyPair> {
    let keyPair: KeyPair = new KeyPair();
    try {
      let asyKeyGenerator = cryptoFramework.createAsyKeyGenerator(this.ASY_KEY_NAME_RSA_3072);
      const tempKeyPair = await asyKeyGenerator.generateKeyPair();
      keyPair = {
        publicKey: this.base.encodeToStringSync(tempKeyPair.pubKey.getEncoded().data),
        privateKey: this.base.encodeToStringSync(tempKeyPair.priKey.getEncoded().data)
      }
    } catch (err) {
      console.error(err);
    }
    return keyPair;
  }

  public async add(str: string, publicKey: string): Promise<string> {
    let result = '';
    try {
      let asyKeyGenerator = cryptoFramework.createAsyKeyGenerator(this.ASY_KEY_NAME_RSA_3072);
      // Create a Cipher (decryption) object 
      let cipher = cryptoFramework.createCipher(this.ALG_NAME_RSA_3072);
      // Introduce external public key encryption
      let keyGenPromise: cryptoFramework.KeyPair =
        await asyKeyGenerator.convertKey({ data: this.base.decodeSync(publicKey) }, null);
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyGenPromise.pubKey, null);
      let put: cryptoFramework.DataBlob = { data: stringToUint8Array(str) };
      const finalRes = await cipher.doFinal(put);
      result = this.base.encodeToStringSync(finalRes.data);
      console.info(result);
    } catch (err) {
      console.log(err.message);
    }
    return result;
  }

  public async rsaDecrypt(message: string | Uint8Array, privateKey: string): Promise<string> {
    let result = '';
    try {
      let asyKeyGenerator = cryptoFramework.createAsyKeyGenerator(this.ASY_KEY_NAME_RSA_3072);
      const keyPair = await asyKeyGenerator.convertKey(null, { data: this.base.decodeSync(privateKey) });
      let cipher = cryptoFramework.createCipher(this.ALG_NAME_RSA_3072); // Create a Cipher (decryption) object
      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, keyPair.priKey, null);
      let bytes: Uint8Array | string = message;
      if (typeof message === 'string') {
        bytes = this.base.decodeSync(message);
      } else {
        bytes = message;
      }
      const finalRes = await cipher.doFinal({ data: bytes });
      result = uint8ArrayToString(finalRes.data);
      console.info(result);
    } catch (err) {
      console.error(err.code);
    }
    return result;
  }
}

@Entry
@Component
struct EncryptedText {
  @State word: string = '加解密文字';
  private EncryptionAndDecryption = new RSA();

  async aboutToAppear(): Promise<void> {
    let key = await this.EncryptionAndDecryption.generateRsaKeyPair();
    let result = await this.EncryptionAndDecryption.add(this.word, key.publicKey);
    this.EncryptionAndDecryption.rsaDecrypt(result, key.privateKey);
  }

  build() {
  }
}
// [End RsaDecrypt]