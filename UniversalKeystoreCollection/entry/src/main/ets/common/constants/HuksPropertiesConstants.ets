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
import { EncodingUtils } from '../utils/EncodingUtils';

export class HuksPropertiesConstants {
  /**
   * Src key alisa first.
   */
  static SRC_KEY_ALISA_FIRST = 'AgreeX25519KeyFirstAlias';

  /**
   * Src key alisa second.
   */
  static SRC_KEY_ALISA_SECOND = 'AgreeX25519KeySecondAlias';

  /**
   * X25519 key negotiation properties.
   */
  static PROPERTIES: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_X25519
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256
  }, {
    tag: huks.HuksTag.HUKS_TAG_DIGEST,
    value: huks.HuksKeyDigest.HUKS_DIGEST_NONE
  }, {
    tag: huks.HuksTag.HUKS_TAG_PADDING,
    value: huks.HuksKeyPadding.HUKS_PADDING_NONE
  }, {
    tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
    value: huks.HuksCipherMode.HUKS_MODE_CBC
  }, {
    tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
    value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
  }];

  /**
   * X25519 key negotiation options.
   */
  static HUKS_OPTIONS: huks.HuksOptions = {
    properties: HuksPropertiesConstants.PROPERTIES,
    inData: new Uint8Array(new Array())
  };

  /**
   * The alisa key of A.
   */
  static ALISA_A: string = 'aliasA';

  /**
   * The alisa key of B.
   */
  static ALISA_B: string = 'aliasB';

  /**
   * DH key negotiation properties.
   */
  static DH_AGREE: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_DH
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE
  }];

  /**
   * DH all key negotiation properties.
   */
  static DHF_2048_AGREE: Array<huks.HuksParam> = [
    ...HuksPropertiesConstants.DH_AGREE, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_DH_KEY_SIZE_2048
  }];

  /**
   * DH key negotiation options.
   */
  static DH_GEN_OPTIONS: huks.HuksOptions = {
    properties: HuksPropertiesConstants.DHF_2048_AGREE,
    inData: new Uint8Array([])
  };

  /**
   * Empty options.
   */
  static EMPTY_OPTION: huks.HuksOptions = {
    properties: [],
    inData: new Uint8Array([])
  };

  /**
   * X25519 key negotiation finish properties.
   */
  static FINISH_PROPERTIES: Array<huks.HuksParam> = [{
    tag: huks.HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
    value: huks.HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS
  }, {
    tag: huks.HuksTag.HUKS_TAG_IS_KEY_ALIAS,
    value: true
  }, {
    tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
    value: huks.HuksKeyAlg.HUKS_ALG_AES
  }, {
    tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
    value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
  }, {
    tag: huks.HuksTag.HUKS_TAG_PURPOSE,
    value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
  }, {
    tag: huks.HuksTag.HUKS_TAG_DIGEST,
    value: huks.HuksKeyDigest.HUKS_DIGEST_NONE
  }, {
    tag: huks.HuksTag.HUKS_TAG_PADDING,
    value: huks.HuksKeyPadding.HUKS_PADDING_NONE
  }, {
    tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
    value: huks.HuksCipherMode.HUKS_MODE_ECB
  }];

  /**
   * X25519 key negotiation in data.
   */
  static agreeX25519InData = 'AgreeX25519TestIndata';

  /**
   * X25519 key negotiation first finish options.
   */
  static finishOptionsFirst: huks.HuksOptions = {
    properties: [
      ...HuksPropertiesConstants.FINISH_PROPERTIES, {
      tag: huks.HuksTag.HUKS_TAG_KEY_ALIAS,
      value: EncodingUtils.stringToUnit8Array(HuksPropertiesConstants.SRC_KEY_ALISA_FIRST + 'final')
    }],
    inData: EncodingUtils.stringToUnit8Array(HuksPropertiesConstants.agreeX25519InData)
  };

  /**
   * Key alisa.
   */
  static KEY_ALIAS: string = 'keyAlias';

  /**
   * Plaintext.
   */
  static PLAINTEXT: string = 'sign_text';
}