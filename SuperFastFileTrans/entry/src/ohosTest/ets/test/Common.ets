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

export interface XtsConfig {
  // url example: 'http://xxx.xxx.xxx/download/demo.zip'
  baseUrl: string
  downloadUrl: string
  uploadUrl: string
  chunkUploadUrl: string
  downloadHttpsUrl: string
  uploadHttpsUrl: string
  chunkUploadHttpsUrl: string
  // sfft_download.db
  sfftDownloadDBName: string
  // sfft_upload.db
  sfftUploadDBName: string
  // demo.zip
  defaultDownloadFileName: string
  // demo.zip
  defaultUploadFileName: string
  // server.pem
  serverCertificateName: string
  // client.pem
  clientCertificateName: string
}

export const XTS_CONFIG: XtsConfig = {
  baseUrl: '',
  downloadUrl: '',
  uploadUrl: '',
  chunkUploadUrl: '',
  downloadHttpsUrl: '',
  uploadHttpsUrl: '',
  chunkUploadHttpsUrl: '',
  sfftDownloadDBName: 'sfft_download.db',
  sfftUploadDBName: 'sfft_upload.db',
  defaultDownloadFileName: '',
  // 以下文件存于entry/src/main/resources/rawfile中，验证XTS前需要自行构造和创建
  defaultUploadFileName: '',
  serverCertificateName: '',
  clientCertificateName: ''
}

