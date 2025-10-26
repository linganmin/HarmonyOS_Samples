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
import { buffer, util } from '@kit.ArkTS';
import { CryptoUtil } from '../utils/CryptoUtil';
import { CryptoItem } from '../viewmodel/CryptoItem';
import CommonConstants from '../constants/CommonConstants';
import { logger } from '../utils/Logger';
import { CryptoViewModel } from '../viewmodel/CryptoViewModel';
import { getResourceString } from '../utils/ResourceString';
import { DataConversion } from '../utils/DataConversion';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function CryptoDetailBuilder() {
  CryptoDetail();
}

@Component
export struct CryptoDetail {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State cryptoItem: CryptoItem =
    new CryptoItem($r('app.string.empty'), $r('app.string.empty'), $r('app.string.empty'), '');
  @State original: string = '';
  @State encrypt: string = getResourceString($r('app.string.encrypted_text'), this.getUIContext());
  @State isCrypto: boolean = false;
  @State decrypt: string | Resource = getResourceString($r('app.string.decrypted_text'), this.getUIContext());
  @State pk: string =
    '04F848A2FC3CAAEE6976100EA9C33D3AC91CACC33B68D03C2EFDB99CDDC203AAFE977071F34339A9CB8C0E0CD3A93D18E839D4E6469581B6F5A666A34C0B8EFD1B';
  @State sk: string = '0575D0ECB625C99672FE860B777CC1DD547057B903C2D4033D21DC016D3838AF';
  @State encryptTextJava: string = getResourceString($r('app.string.encrypted_text'), this.getUIContext());
  private cipherParam: string = '';
  private gcmParamsSpec?: cryptoFramework.GcmParamsSpec;
  private ivParamsSpec?: cryptoFramework.IvParamsSpec;
  private symKey?: cryptoFramework.SymKey;
  private keyPair?: cryptoFramework.KeyPair;
  private pSource?: Uint8Array;

  aboutToAppear(): void {
    this.cryptoItem = this.pageInfos.getParamByName('CryptoDetail')[0] as CryptoItem;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (getResourceString(this.cryptoItem.name, this.getUIContext()) ===
          getResourceString($r('app.string.format_conversion'), this.getUIContext())) {
            Row() {
              Text($r('app.string.private_key'))
                .fontSize($r('app.float.count_size'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                .lineHeight($r('app.float.common_line_height'))
                .margin({ bottom: $r('app.float.small_padding') })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)

            TextArea({ text: this.sk })
              .backgroundColor(Color.White)
              .enabled(false)
              .margin({ bottom: $r('app.float.small_padding') })

            Row() {
              Text($r('app.string.public_key'))
                .fontSize($r('app.float.count_size'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                .lineHeight($r('app.float.common_line_height'))
                .margin({ bottom: $r('app.float.small_padding') })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)

            TextArea({ text: this.pk })
              .backgroundColor(Color.White)
              .enabled(false)
          }

          TextArea({ placeholder: $r('app.string.text_encrypted') })
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.original = value;
            })
            .margin({ top: $r('app.float.small_padding') })
          Button(this.cryptoItem.encrypted)
            .width(CommonConstants.FULL_PERCENT)
            .fontSize($r('app.float.common_font'))
            .enabled(this.original === '' ? false : true)
            .margin({
              top: $r('app.float.small_padding'),
              bottom: $r('app.float.small_padding')
            })
            .onClick(async () => {
              if (this.cryptoItem.type === 'AES_GCM') {
                this.gcmParamsSpec = CryptoUtil.genGcmParamsSpec();
                this.cipherParam = 'AES128|GCM|PKCS7';
                let keyData = new Uint8Array([83, 217, 231, 76, 28, 113, 23, 219, 250, 71, 209, 210, 205, 97, 32, 159]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, 'AES128');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptAESGCMMessagePromise(this.cipherParam, this.gcmParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'AES_CBC') {
                this.ivParamsSpec = CryptoUtil.genIvParamsSpec();
                this.cipherParam = 'AES128|CBC|PKCS7';
                let keyData = new Uint8Array([83, 217, 231, 76, 28, 113, 23, 219, 250, 71, 209, 210, 205, 97, 32, 159]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, 'AES128');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptCBCMessagePromise(this.cipherParam, this.ivParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'AES_ECB') {
                this.cipherParam = 'AES128|ECB|PKCS7';
                let keyData = new Uint8Array([83, 217, 231, 76, 28, 113, 23, 219, 250, 71, 209, 210, 205, 97, 32, 159]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, 'AES128');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === '3DES_ECB') {
                this.cipherParam = '3DES192|ECB|PKCS7';
                let keyData = new Uint8Array([238, 249, 61, 55, 128, 220, 183, 224, 139, 253, 248, 239, 239, 41, 71, 25,
                  235, 206, 230, 162, 249, 27, 234, 114]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, '3DES192');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'SM4_ECB') {
                this.cipherParam = 'SM4_128|ECB|PKCS7';
                let keyData = new Uint8Array([7, 154, 52, 176, 4, 236, 150, 43, 237, 9, 145, 166, 141, 174, 224, 131]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, 'SM4_128');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'SM4_CBC') {
                this.ivParamsSpec = CryptoUtil.genIvParamsSpec();
                this.cipherParam = 'SM4_128|CBC|PKCS7';
                let keyData = new Uint8Array([7, 154, 52, 176, 4, 236, 150, 43, 237, 9, 145, 166, 141, 174, 224, 131]);
                this.symKey = CryptoUtil.genSymKeyByData(keyData, 'SM4_128');
                if (!this.symKey) {
                  return;
                }
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptCBCMessagePromise(this.cipherParam, this.ivParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'RSA_PKCS1') {
                let pkData = CryptoViewModel.pkData;
                let skData = CryptoViewModel.skData;
                this.keyPair = CryptoUtil.genKeyPairByData('RSA1024', pkData, skData);
                if (!this.keyPair) {
                  return;
                }
                this.cipherParam = 'RSA1024|PKCS1';
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = await CryptoUtil.encryptPublicKeyMessagePromise(this.cipherParam, this.keyPair.pubKey,
                  plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'RSA_PKCS1_OAEP') {
                let rsaKeyPair = CryptoUtil.genRsaKeyPairSpec(CryptoViewModel.rsaKeyNin, BigInt('0x010001'),
                  CryptoViewModel.rsaKeyDIn);
                try {
                  let rsaGeneratorSpec = cryptoFramework.createAsyKeyGeneratorBySpec(rsaKeyPair);
                  this.keyPair = await rsaGeneratorSpec.generateKeyPair();
                } catch (error) {
                  let err = error as BusinessError;
                  logger.error('CryptoDetail',
                    `createAsyKeyGeneratorBySpec failed, error code=${err.code}, message=${err.message}`);
                  return;
                }
                this.pSource = new Uint8Array([1, 2, 3, 4]);
                this.cipherParam = 'RSA2048|PKCS1_OAEP|SHA256|MGF1_SHA1';
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = CryptoUtil.encryptOAEPPublicKeyMessagePromise(this.cipherParam, this.keyPair.pubKey,
                  this.pSource, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'SM2') {
                let pkData =
                  new Uint8Array([48, 89, 48, 19, 6, 7, 42, 134, 72, 206, 61, 2, 1, 6, 8, 42, 129, 28, 207, 85,
                    1, 130, 45, 3, 66, 0, 4, 90, 3, 58, 157, 190, 248, 76, 7, 132, 200, 151, 208, 112, 230, 96, 140, 90,
                    238, 211, 155, 128, 109, 248, 40, 83, 214, 78, 42, 104, 106, 55, 148, 249, 35, 61, 32, 221, 135,
                    143,
                    100, 45, 97, 194, 176, 52, 73, 136, 174, 40, 70, 70, 34, 103, 103, 161, 99, 27, 187, 13, 187, 109,
                    244,
                    13, 7]);
                let skData: Uint8Array =
                  new Uint8Array([48, 49, 2, 1, 1, 4, 32, 54, 41, 239, 240, 63, 188, 134, 113, 31, 102, 149,
                    203, 245, 89, 15, 15, 47, 202, 170, 60, 38, 154, 28, 169, 189, 100, 251, 76, 112, 223, 156, 159,
                    160,
                    10, 6, 8, 42, 129, 28, 207, 85, 1, 130, 45]);
                // Public key, private key u8 type
                if (getResourceString(this.cryptoItem.name, this.getUIContext()) ===
                getResourceString($r('app.string.format_conversion'), this.getUIContext())) {
                  // Public key conversion to SM2 key.
                  let pksData = await DataConversion.convertStrToPubKey(this.pk);
                  if (!pksData) {
                    return;
                  }
                  // Private key conversion to SM2 key.
                  let sksData = await DataConversion.convertStrToPriKey(this.sk);
                  if (!sksData) {
                    return;
                  }
                  // Generate SM2 key.
                  try {
                    this.keyPair =
                      CryptoUtil.genKeyPairByData('SM2_256', pksData.getEncoded().data, sksData.getEncoded().data);
                  } catch (error) {
                    let err = error as BusinessError;
                    logger.error('CryptoDetail',
                      `decryptMessagePromise failed, error code=${err.code}, message=${err.message}`);
                  }
                  if (!this.keyPair) {
                    return;
                  }
                } else {
                  this.keyPair = CryptoUtil.genKeyPairByData('SM2_256', pkData, skData);
                  if (!this.keyPair) {
                    return;
                  }
                }
                this.cipherParam = 'SM2_256|SM3';
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                // Encrypt messages.
                let encryptText = await CryptoUtil.encryptPublicKeyMessagePromise(this.cipherParam, this.keyPair.pubKey,
                  plainText);
                if (!encryptText) {
                  return;
                }
                try {
                  this.encryptTextJava =
                    new DataConversion(this.getUIContext()).d2i_SM2_Ciphertext(buffer.from(encryptText.data)
                      .toString('hex'))
                } catch (error) {
                  let err = error as BusinessError;
                  logger.error('CryptoDetail',
                    `DataConversion failed, error code=${err.code}, message=${err.message}`);
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else if (this.cryptoItem.type === 'RSA_PKCS1_BIG') {
                let pkData = CryptoViewModel.pkData;
                let skData = CryptoViewModel.skData;
                this.keyPair = CryptoUtil.genKeyPairByData('RSA1024', pkData, skData);
                if (!this.keyPair) {
                  return;
                }
                this.cipherParam = 'RSA1024|PKCS1';
                let plainText: cryptoFramework.DataBlob = {
                  data: new Uint8Array(buffer.from(this.original, 'utf-8').buffer)
                };
                let encryptText = CryptoUtil.rsaEncryptBySegment(this.cipherParam, this.keyPair.pubKey, plainText);
                if (!encryptText) {
                  return;
                }
                let base = new util.Base64Helper();
                let encodeString = base.encodeToStringSync(encryptText.data);
                this.encrypt = encodeString;
                logger.info(encodeString);
                this.isCrypto = true;
              } else {
                logger.error('this.cryptoItem.type error' + this.cryptoItem.type)
              }
            })

          Row() {
            Text($r('app.string.after_encryption'))
              .fontSize($r('app.float.count_size'))
              .fontWeight(CommonConstants.FONT_WIGHT_500)
              .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
              .lineHeight($r('app.float.common_line_height'))
          }
          .margin({ bottom: $r('app.float.small_padding') })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          if (getResourceString(this.cryptoItem.name, this.getUIContext()) ===
          getResourceString($r('app.string.format_conversion'), this.getUIContext())) {
            Row() {
              Text($r('app.string.ASN_1'))
                .fontSize($r('app.float.count_size'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                .lineHeight($r('app.float.common_line_height'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: $r('app.float.small_padding')
            })
          }

          Row() {
            Text(this.encrypt)
              .fontSize($r('app.float.common_font'))
              .fontWeight(CommonConstants.FONT_WIGHT_400)
              .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .borderRadius($r('sys.float.corner_radius_level8'))
          .backgroundColor(Color.White)
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .padding({
            left: $r('app.float.encrypted_padding_lr'),
            right: $r('app.float.encrypted_padding_lr'),
            top: $r('app.float.encrypted_padding_tb'),
            bottom: $r('app.float.encrypted_padding_tb')
          })
          .margin({
            bottom: $r('app.float.small_padding')
          })

          if (getResourceString(this.cryptoItem.name, this.getUIContext()) ===
          getResourceString($r('app.string.format_conversion'), this.getUIContext())) {
            Row() {
              Text($r('app.string.naked_ciphertext'))
                .fontSize($r('app.float.count_size'))
                .fontWeight(CommonConstants.FONT_WIGHT_500)
                .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                .lineHeight($r('app.float.common_line_height'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: $r('app.float.small_padding')
            })

            Row() {
              Text(this.encryptTextJava)
                .fontSize($r('app.float.common_font'))
                .fontWeight(CommonConstants.FONT_WIGHT_400)
                .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                .fontColor($r('sys.color.mask_secondary'))
            }
            .borderRadius($r('sys.float.corner_radius_level8'))
            .backgroundColor(Color.White)
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .padding({
              left: $r('app.float.encrypted_padding_lr'),
              right: $r('app.float.encrypted_padding_lr'),
              top: $r('app.float.encrypted_padding_tb'),
              bottom: $r('app.float.encrypted_padding_tb')
            })
            .margin({
              bottom: $r('app.float.small_padding')
            })
          }

          Button(this.cryptoItem.decrypted)
            .width(CommonConstants.FULL_PERCENT)
            .fontSize($r('app.float.common_font'))
            .enabled(this.isCrypto ? true : false)
            .onClick(async () => {
              if (this.cryptoItem.type === 'AES_GCM') {
                if (!this.gcmParamsSpec || !this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptAESGCMMessagePromise(this.cipherParam, this.gcmParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'AES_CBC') {
                if (!this.ivParamsSpec || !this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptCBCMessagePromise(this.cipherParam, this.ivParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'AES_ECB') {
                if (!this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === '3DES_ECB') {
                if (!this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'SM4_ECB') {
                if (!this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptMessagePromise(this.cipherParam, this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'SM4_CBC') {
                if (!this.ivParamsSpec || !this.symKey) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = await CryptoUtil.decryptCBCMessagePromise(this.cipherParam, this.ivParamsSpec,
                  this.symKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'RSA_PKCS1') {
                if (!this.keyPair) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText =
                  await CryptoUtil.decryptPrivateKeyMessagePromise(this.cipherParam, this.keyPair.priKey,
                    plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'RSA_PKCS1_OAEP') {
                if (!this.keyPair || !this.pSource) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = CryptoUtil.decryptOAEPPrivateKeyMessagePromise(this.cipherParam, this.keyPair.priKey,
                  this.pSource, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'SM2') {
                if (!this.keyPair) {
                  return;
                }
                let base = new util.Base64Helper();
                // Encrypted data
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText =
                  await CryptoUtil.decryptPrivateKeyMessagePromise(this.cipherParam, this.keyPair.priKey,
                    plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else if (this.cryptoItem.type === 'RSA_PKCS1_BIG') {
                if (!this.keyPair) {
                  return;
                }
                let base = new util.Base64Helper();
                let plainText: cryptoFramework.DataBlob = { data: base.decodeSync(this.encrypt) };
                let encryptText = CryptoUtil.rsaDecryptBySegment(this.cipherParam, this.keyPair.priKey, plainText);
                if (!encryptText) {
                  return;
                }
                let textDecoder = util.TextDecoder.create('utf-8');
                this.decrypt = textDecoder.decodeToString(encryptText.data);
              } else {
                logger.error('this.cryptoItem.type error' + this.cryptoItem.type)
              }
            })
          Row() {
            Text(this.decrypt)
              .fontSize($r('app.float.common_font'))
              .fontWeight(CommonConstants.FONT_WIGHT_400)
              .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .borderRadius($r('sys.float.corner_radius_level8'))
          .backgroundColor(Color.White)
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .padding({
            left: $r('app.float.encrypted_padding_lr'),
            right: $r('app.float.encrypted_padding_lr'),
            top: $r('app.float.encrypted_padding_tb'),
            bottom: $r('app.float.encrypted_padding_tb')
          })
          .margin({
            top: $r('app.float.small_padding')
          })
        }
        .padding({
          left: $r('app.float.medium_padding'),
          right: $r('app.float.medium_padding')
        })
      }
      .align(getResourceString(this.cryptoItem.name, this.getUIContext()) ===
      getResourceString($r('app.string.format_conversion'), this.getUIContext()) ? Alignment.TopStart :
        Alignment.Center)
      .height(getResourceString(this.cryptoItem.name, this.getUIContext()) ===
      getResourceString($r('app.string.format_conversion'), this.getUIContext()) ? '100%' : '90%')
    }
    .padding({ bottom: 16 })
    .title(getResourceString(this.cryptoItem.name, this.getUIContext()))
    .backgroundColor($r('app.color.background_page'))
  }
}