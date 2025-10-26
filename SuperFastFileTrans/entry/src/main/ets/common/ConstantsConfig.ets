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

import { SecurityConfig } from '@hadss/super_fast_file_trans';

interface Urls {
  /**
   * Ordinary download path, example: http://xxx.xxx.xxx/download/target1.mp4
   */
  ordinaryDownloadUrlExampleOne: string,

  /**
   * Ordinary download path, example: http://xxx.xxx.xxx/download/target2.mp4
   */
  ordinaryDownloadUrlExampleTwo: string,

  /**
   * Ordinary download path, example: http://xxx.xxx.xxx/download/target3.mp4
   */
  multiDownloadUrlExampleOne: string,

  /**
   * Ordinary download path, example: http://xxx.xxx.xxx/download/target4.mp4
   */
  multiDownloadUrlExampleTwo: string,

  /**
   * Ordinary upload path, example: 'http://xxx.xxx.xxx/upload'
   */
  ordinaryUploadUrl: string;

  /**
   * Chunk upload path, example: 'http://xxx.xxx.xxx/chunkUpload'
   */
  chunkUploadUrl: string;
}

interface CertificateConfig {
  /**
   * Server certificate, example: 'server.pem'
   */
  serverCertificateName: string,

  /**
   * client certificate, example: 'client.pem'
   */
  clientCertificateName: string,

  /**
   * Certificate authority(server) file path, example: '/data/storage/el2/base/haps/entry/files/server.pem'
   */
  serverCertificatePath: string,

  /**
   * Certificate(client) file path, example: '/data/storage/el2/base/haps/entry/files/client.pem'
   */

  clientCertificatePath: string,

  /**
   * security certificate config, example:
   * securityConfig: SecurityConfig = {
   *   remoteValidation: {
   *     filePath: `${YOUR_SERVER_CERTIFICATE_PATH}`,
   *   },
   *   certificate: {
   *     filePath: `${YOUR_CLIENT_CERTIFICATE_PATH}`,
   *     type: 'PEM',
   *     keyPassword: `${YOUR_CLIENT_CERTIFICATE_PASSWORD}`
   *   },
   *   tlsOptions: {
   *     tlsVersion: 'TlsV1.3'
   *   }
   * }
   */
  securityConfig: SecurityConfig
}

interface ConstantsConfig {
  urls: Urls,
  certificate: CertificateConfig
}

export const CONSTANTS_CONFIG: ConstantsConfig = {
  urls: {
    ordinaryDownloadUrlExampleOne: '',
    ordinaryDownloadUrlExampleTwo: '',
    multiDownloadUrlExampleOne: '',
    multiDownloadUrlExampleTwo: '',
    ordinaryUploadUrl: '',
    chunkUploadUrl: '',
  },
  certificate: {
    serverCertificateName: '',
    clientCertificateName: '',
    serverCertificatePath: '',
    clientCertificatePath: '',
    securityConfig: {}
  }
}