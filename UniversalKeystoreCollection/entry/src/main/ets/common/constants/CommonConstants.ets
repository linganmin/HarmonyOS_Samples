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

export class CommonConstants {
  /**
   * Encrypt algorithms.
   */
  static readonly ENCRYPT_ALGORITHMS: Resource[] = [
    $r('app.string.AES_CBC_PKCS7_mode_encrypt'),
    $r('app.string.RSA_ECB_PKCS1_V1_5_mode_encrypt'),
    $r('app.string.SM4_CBC_PKCS7_mode_encrypt')
  ];

  /**
   * Decrypt algorithms.
   */
  static readonly DECRYPT_ALGORITHMS: Resource[] = [
    $r('app.string.AES_CBC_PKCS7_mode_decrypt'),
    $r('app.string.RSA_ECB_PKCS1_V1_5_mode_decrypt'),
    $r('app.string.SM4_CBC_PKCS7_mode_decrypt')
  ];

  /**
   * All encrypt mode.
   */
  static readonly ENCRYPT_ALL_MODE: Resource[] = [
    $r('app.string.AES_CBC_PKCS7_mode_encrypt_and_decrypt'),
    $r('app.string.RSA_ECB_PKCS1_V1_5_mode_encrypt_and_decrypt'),
    $r('app.string.SM4_CBC_PKCS7_mode_encrypt_and_decrypt')
  ];

  /**
   * Key negotiation mode.
   */
  static readonly KEY_NEGOTIATION_MODE: Resource[] = [
    $r('app.string.X25519_algorithm_key_negotiation'),
    $r('app.string.DH_algorithm_key_negotiation')
  ];

  /**
   * Signature and verification mode.
   */
  static readonly SIGNATURE_VERIFICATION_MODE: Resource[] = [
    $r('app.string.ECC_KEY_SHA_Signature_Verification'),
    $r('app.string.SM2_KEY_Signature_Verification')
  ];

  /**
   * Router pages.
   */
  static readonly ROUTER_PAGES: string[] = [
    'pages/EncryptionPage',
    'pages/SignatureVerificationPage',
    'pages/KeyNegotiationPage'
  ];

  /**
   * Signature result.
   */
  static readonly SIGNATURE_RESULT: string = 'result: ';

  /**
   * The encrypt page.
   */
  static readonly ENCRYPT_PAGE: string = 'pages/EncryptionDetailPage';

  /**
   * The Key negotiation page.
   */
  static readonly KEY_NEGOTIATION_PAGE: string = 'pages/KeyNegotiationDetailPage';

  /**
   * The signature and verification page.
   */
  static readonly SIGNATURE_VERIFICATION_PAGE: string = 'pages/SignatureVerificationDetailPage';

  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * The font weight of 700.
   */
  static readonly FONT_WEIGHT_700: number = 700;

  /**
   * The duration of toast
   */
  static readonly TOAST_DURATION: number = 2000;
}