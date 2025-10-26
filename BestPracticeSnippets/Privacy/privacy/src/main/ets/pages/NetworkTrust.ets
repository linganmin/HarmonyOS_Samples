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

import { BusinessError } from '@kit.BasicServicesKit'
import { http } from '@kit.NetworkKit'
import { rcp } from '@kit.RemoteCommunicationKit';

let httpRequest = http.createHttp();
/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景四：配置信任应用管理的CA证书-Network Kit
 */
// [Start cybersecurity_network_trusting_ca]
httpRequest.request( 'EXAMPLE_URL',  {
  method: http.RequestMethod.POST,
  header: {
    'Content-Type': 'application/json'
  },
  extraData: 'data to send',
  expectDataType: http.HttpDataType.STRING,
  connectTimeout: 60000,
  caPath:'/data/storage/el1/bundle/entry/resources/resfile/domainCaCert', // Specifies the trusted CA certificate path
}, (err: BusinessError, data: http.HttpResponse) => {
  // ...
})
// [End cybersecurity_network_trusting_ca]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景五：配置信任应用管理的CA证书-Remote Communication Kit
 */

// [Start cybersecurity_rcp_trusting_ca]
const caPath: rcp.CertificateAuthority = {
  folderPath: '/data/storage/el1/bundle/entry/resources/resfile/appCaCert', // Specify trusted CA certificate path
}
const securityConfig: rcp.SecurityConfiguration = {
  remoteValidation: caPath
};
// Use the security configuration in the session creation
const sessionWithSecurityConfig = rcp.createSession({ requestConfiguration: { security: securityConfig } });
// [End cybersecurity_rcp_trusting_ca]

let HTTP_SERVER = '1'
const RemoteCommunicationKit = async  () => {
  /**
   * 最佳实践：网络连接安全配置开发实践
   * 场景九：配置SSL Pinning证书锁定-Remote Communication Kit配置动态SSL Pinning
   */
  // [Start rcp_ssl_pinning]
  const keyHash: string = 'g8CsdcpyAKxmLoWFvMd2hC7ZDUy7L4E2NYOi1i8qEtE='; // Public key of the server certificate
  const session = rcp.createSession();
  const request = new rcp.Request(HTTP_SERVER);
  const pin: rcp.CertificatePinning = {
    kind: 'public-key',
    publicKeyHash: keyHash,
    hashAlgorithm: 'SHA-256'
  };
  request.configuration = {
    security: {
      certificatePinning: pin,
    }
  };
  const resp = await session.fetch(request);
  // [End rcp_ssl_pinning]
}

