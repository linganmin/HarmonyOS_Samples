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

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'CryptoUtil';

export class CryptoUtil {
  /**
   * GCM parameters generated in AES GCM mode.
   *
   * @returns cryptoFramework.GcmParamsSpec.
   */
  public static genGcmParamsSpec(): cryptoFramework.GcmParamsSpec {
    let arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let dataIv = new Uint8Array(arr);
    let ivBlob: cryptoFramework.DataBlob = { data: dataIv };
    arr = [0, 0, 0, 0, 0, 0, 0, 0];
    let dataAad = new Uint8Array(arr);
    let aadBlob: cryptoFramework.DataBlob = { data: dataAad };
    arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let dataTag = new Uint8Array(arr);
    let tagBlob: cryptoFramework.DataBlob = {
      data: dataTag
    };
    // The value of authTag of the GCM is obtained from the doFinal result during encryption
    // and is set to the value of params of the init function during decryption.
    let gcmParamsSpec: cryptoFramework.GcmParamsSpec = {
      iv: ivBlob,
      aad: aadBlob,
      authTag: tagBlob,
      algName: 'GcmParamsSpec'
    };
    return gcmParamsSpec;
  }

  /**
   * AES GCM encryption mode.
   *
   * @param cipherParam Algorithm name.
   * @param gcmParams cryptoFramework.GcmParamsSpec.
   * @param symKey cryptoFramework.SymKey.
   * @param plainText Character string to be encrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>.
   */
  public static async encryptAESGCMMessagePromise(cipherParam: string, gcmParams: cryptoFramework.GcmParamsSpec,
    symKey: cryptoFramework.SymKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, gcmParams);
      let encryptUpdate = await cipher.update(plainText);
      gcmParams.authTag = await cipher.doFinal(null);
      return encryptUpdate;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `encryptAESGCMMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * AES GCM decryption mode.
   *
   * @param cipherParam algorithm name.
   * @param gcmParams cryptoFramework.GcmParamsSpec.
   * @param symKey cryptoFramework.SymKey.
   * @param cipherText character string to be decrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>.
   */
  public static async decryptAESGCMMessagePromise(cipherParam: string, gcmParams: cryptoFramework.GcmParamsSpec,
    symKey: cryptoFramework.SymKey,
    cipherText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, gcmParams);
      let decryptUpdate = await decoder.update(cipherText);
      // When doFinal is decrypted in GCM mode, no data is transferred.
      // The tag data transferred during initialization is verified. If the verification fails, an exception is thrown.
      let decryptData = await decoder.doFinal(null);
      if (decryptData === null) {
        logger.info('GCM decrypt success, decryptData is null');
      }
      return decryptUpdate;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `decryptAESGCMMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Create a symmetric key generator according to the given algorithm name.
   *
   * @param symKeyData the key data blob.
   * @param algName algorithm name.
   * @returns cryptoFramework.SymKey | undefined
   */
  public static genSymKeyByData(symKeyData: Uint8Array, algName: string): cryptoFramework.SymKey | undefined {
    try {
      let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
      let aesGenerator = cryptoFramework.createSymKeyGenerator(algName);
      let symKey = aesGenerator.convertKeySync(symKeyBlob);
      logger.info('convertKey success');
      return symKey;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `genSymKeyByData failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Provides the IvParamsSpec type, including the parameter iv.
   *
   * @returns cryptoFramework.IvParamsSpec.
   */
  public static genIvParamsSpec(): cryptoFramework.IvParamsSpec {
    let arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let dataIv = new Uint8Array(arr);
    let ivBlob: cryptoFramework.DataBlob = { data: dataIv };
    let ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: 'IvParamsSpec',
      iv: ivBlob
    };
    return ivParamsSpec;
  }

  /**
   * CBC encryption mode.
   *
   * @param cipherParam algorithm name.
   * @param ivParams cryptoFramework.IvParamsSpec.
   * @param symKey cryptoFramework.SymKey.
   * @param plainText character string to be encrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>.
   */
  public static async encryptCBCMessagePromise(cipherParam: string, ivParams: cryptoFramework.IvParamsSpec,
    symKey: cryptoFramework.SymKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, ivParams);
      let cipherData = await cipher.doFinal(plainText);
      return cipherData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `encryptCBCMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * CBC decryption mode.
   *
   * @param cipherParam algorithm name.
   * @param ivParams cryptoFramework.IvParamsSpec.
   * @param symKey cryptoFramework.SymKey.
   * @param cipherText character string to be encrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>.
   */
  public static async decryptCBCMessagePromise(cipherParam: string, ivParams: cryptoFramework.IvParamsSpec,
    symKey: cryptoFramework.SymKey,
    cipherText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, ivParams);
      let decryptData = await decoder.doFinal(cipherText);
      return decryptData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `decryptCBCMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Encryption mode.
   *
   * @param cipherParam algorithm name.
   * @param symKey cryptoFramework.SymKey.
   * @param plainText character string to be encrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>
   */
  public static async encryptMessagePromise(cipherParam: string, symKey: cryptoFramework.SymKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, null);
      let cipherData = await cipher.doFinal(plainText);
      return cipherData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `encryptMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Decryption mode.
   *
   * @param cipherParam algorithm name.
   * @param symKey cryptoFramework.SymKey.
   * @param cipherText character string to be decrypted.
   * @returns Promise<cryptoFramework.DataBlob | undefined>.
   */
  public static async decryptMessagePromise(cipherParam: string, symKey: cryptoFramework.SymKey,
    cipherText: cryptoFramework.DataBlob) {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, null);
      let decryptData = await decoder.doFinal(cipherText);
      return decryptData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `decryptMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Create the asymmetric key generator instance according to the given algorithm name.
   *
   * @param algName algorithm name.
   * @param pubKeyData the key data blob.
   * @param priKeyData the key data blob.
   * @returns cryptoFramework.KeyPair | undefined.
   */
  public static genKeyPairByData(algName: string, pubKeyData: Uint8Array,
    priKeyData: Uint8Array): cryptoFramework.KeyPair | undefined {
    try {
      let pubKeyBlob: cryptoFramework.DataBlob = { data: pubKeyData };
      let priKeyBlob: cryptoFramework.DataBlob = { data: priKeyData };
      let rsaGenerator = cryptoFramework.createAsyKeyGenerator(algName);
      let keyPair = rsaGenerator.convertKeySync(pubKeyBlob, priKeyBlob);
      return keyPair;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `genKeyPairByData failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Encrypted by public key.
   *
   * @param cipherParam algorithm name.
   * @param publicKey Provides the public key interface for asymmetric keys.
   * @param plainText character string to be encrypted.
   * @returns Promise<DataBlob | undefined>.
   */
  public static async encryptPublicKeyMessagePromise(cipherParam: string, publicKey: cryptoFramework.PubKey,
    plainText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, publicKey, null);
      let cipherData = await cipher.doFinal(plainText);
      return cipherData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `encryptPublicKeyMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Decrypted by private key.
   *
   * @param cipherParam algorithm name.
   * @param privateKey provides the private key type.
   * @param cipherText character string to be decrypted.
   * @returns Promise<DataBlob | undefined>.
   */
  public static async decryptPrivateKeyMessagePromise(cipherParam: string, privateKey: cryptoFramework.PriKey,
    cipherText: cryptoFramework.DataBlob): Promise<cryptoFramework.DataBlob | undefined> {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, privateKey, null);
      let decryptData = await decoder.doFinal(cipherText);
      return decryptData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `decryptPrivateKeyMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Generating an RSA stack key.
   *
   * @param nIn Indicates the modulus n.
   * @param eIn Indicates the public exponent e.
   * @param dIn Indicates the private exponent d.
   * @returns cryptoFramework.RSAKeyPairSpec.
   */
  public static genRsaKeyPairSpec(nIn: bigint, eIn: bigint, dIn: bigint): cryptoFramework.RSAKeyPairSpec {
    let rsaCommSpec: cryptoFramework.RSACommonParamsSpec = {
      n: nIn,
      algName: 'RSA',
      specType: cryptoFramework.AsyKeySpecType.COMMON_PARAMS_SPEC
    };
    let rsaKeyPairSpec: cryptoFramework.RSAKeyPairSpec = {
      params: rsaCommSpec,
      sk: dIn,
      pk: eIn,
      algName: 'RSA',
      specType: cryptoFramework.AsyKeySpecType.KEY_PAIR_SPEC
    };
    return rsaKeyPairSpec;
  }

  /**
   * RSA PKCS1_OAEP mode encryption.
   *
   * @param cipherParam algorithm name.
   * @param publicKey Provides the public key interface for asymmetric keys.
   * @param itemValue the value of the specified parameter.
   * @param plainText character string to be encrypted.
   * @returns cryptoFramework.DataBlob | undefined.
   */
  public static encryptOAEPPublicKeyMessagePromise(cipherParam: string, publicKey: cryptoFramework.PubKey,
    itemValue: Uint8Array, plainText: cryptoFramework.DataBlob): cryptoFramework.DataBlob | undefined {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      cipher.initSync(cryptoFramework.CryptoMode.ENCRYPT_MODE, publicKey, null);
      cipher.setCipherSpec(cryptoFramework.CipherSpecItem.OAEP_MGF1_PSRC_UINT8ARR, itemValue)
      let cipherData = cipher.doFinalSync(plainText);
      return cipherData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `encryptOAEPPublicKeyMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * RSA PKCS1_OAEP mode decryption.
   *
   * @param cipherParam algorithm name.
   * @param privateKey Provides the public key interface for asymmetric keys.
   * @param itemValue the value of the specified parameter.
   * @param cipherText character string to be decrypted.
   * @returns cryptoFramework.DataBlob | undefined.
   */
  public static decryptOAEPPrivateKeyMessagePromise(cipherParam: string, privateKey: cryptoFramework.PriKey,
    itemValue: Uint8Array, cipherText: cryptoFramework.DataBlob): cryptoFramework.DataBlob | undefined {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      decoder.initSync(cryptoFramework.CryptoMode.DECRYPT_MODE, privateKey, null);
      decoder.setCipherSpec(cryptoFramework.CipherSpecItem.OAEP_MGF1_PSRC_UINT8ARR, itemValue);
      let decryptData = decoder.doFinalSync(cipherText);
      return decryptData;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `decryptOAEPPrivateKeyMessagePromise failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * RSA segment encryption.
   *
   * @param cipherParam algorithm name.
   * @param pubKey Provides the public key interface for asymmetric keys.
   * @param plainText character string to be encrypted.
   * @returns cryptoFramework.DataBlob | undefined.
   */
  public static rsaEncryptBySegment(cipherParam: string, pubKey: cryptoFramework.PubKey,
    plainText: cryptoFramework.DataBlob): cryptoFramework.DataBlob | undefined {
    try {
      let cipher = cryptoFramework.createCipher(cipherParam);
      cipher.initSync(cryptoFramework.CryptoMode.ENCRYPT_MODE, pubKey, null);
      let plainTextSplitLen = 64;
      let cipherText = new Uint8Array();
      for (let i = 0; i < plainText.data.length; i += plainTextSplitLen) {
        let updateMessage = plainText.data.subarray(i, i + plainTextSplitLen);
        let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
        // Split the original text by 64 characters and call doFinal to encrypt the text.
        // When the 1024-bit key is used, a 128-byte ciphertext is generated each time.
        let updateOutput = cipher.doFinalSync(updateMessageBlob);
        let mergeText = new Uint8Array(cipherText.length + updateOutput.data.length);
        mergeText.set(cipherText);
        mergeText.set(updateOutput.data, cipherText.length);
        cipherText = mergeText;
      }
      let cipherBlob: cryptoFramework.DataBlob = { data: cipherText };
      return cipherBlob;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `rsaEncryptBySegment failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * RSA segment decryption.
   *
   * @param cipherParam algorithm name.
   * @param priKey Provides the public key interface for asymmetric keys.
   * @param cipherText character string to be decrypted.
   * @returns cryptoFramework.DataBlob | undefined.
   */
  public static rsaDecryptBySegment(cipherParam: string, priKey: cryptoFramework.PriKey,
    cipherText: cryptoFramework.DataBlob): cryptoFramework.DataBlob | undefined {
    try {
      let decoder = cryptoFramework.createCipher(cipherParam);
      decoder.initSync(cryptoFramework.CryptoMode.DECRYPT_MODE, priKey, null);
      // Length of ciphertext bytes generated by the RSA key during each encryption, which is calculated as follows:\
      // Length of ciphertext bytes generated by the RSA key during each encryption = Number of key bits/8
      let cipherTextSplitLen = 128;
      let decryptText = new Uint8Array();
      for (let i = 0; i < cipherText.data.length; i += cipherTextSplitLen) {
        let updateMessage = cipherText.data.subarray(i, i + cipherTextSplitLen);
        let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
        // Split the ciphertext by 128 bytes, decrypt the ciphertext, obtain the original text,
        // and concatenate the original text.
        let updateOutput = decoder.doFinalSync(updateMessageBlob);
        let mergeText = new Uint8Array(decryptText.length + updateOutput.data.length);
        mergeText.set(decryptText);
        mergeText.set(updateOutput.data, decryptText.length);
        decryptText = mergeText;
      }
      let decryptBlob: cryptoFramework.DataBlob = { data: decryptText };
      return decryptBlob;
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `rsaEncryptBySegment failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }
}