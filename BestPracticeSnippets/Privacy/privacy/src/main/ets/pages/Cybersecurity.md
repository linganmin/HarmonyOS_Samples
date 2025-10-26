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

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景一：配置信任系统预置的CA证书
 */
// [Start cybersecurity_ca]
curl_easy_setopt(curl, CURLOPT_CATH, "/etc/security/certificates");
// [End cybersecurity_ca]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景二：配置不信任用户安装的CA证书
 */

// [Start cybersecurity_not_trusting_ca]
{
  "network-security-config": {
    ... ...
  },
  "trust-global-user-ca": false,  //Configure whether to trust the CA certificate manually installed by the enterprise MDM system or device administrator. The default value is true
  "trust-current-user-ca": false  // Configure whether to trust the CA certificate installed by the current user. The default value is true
}
// [End cybersecurity_not_trusting_ca]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景三：配置信任应用管理的CA证书
 */

// [Start cybersecurity_trusting_ca]
{
  "network-security-config": {
    "base-config": {
      "trust-anchors": [
        {
          "certificates": "/data/storage/el1/bundle/entry/resources/resfile/appCaCert"
        }
      ]
    },
    "domain-config": [
      {
        "domains": [
          {
            "include-subdomains": true,
            "name": "example.com"
          }
        ],
        "trust-anchors": [
          {
            "certificates": "/data/storage/el1/bundle/entry/resources/resfile/domainCaCert"
          }
        ]
      }
    ]
  }
}
// [End cybersecurity_trusting_ca]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景六：配置信任应用管理的CA证书-应用使用三方库进行网络连接
 */
// [Start cybersecurity_trusting_ca_others]
curl_easy_setopt(curl, CURLOPT_CATH, "/data/storage/el1/bundle/entry/resources/resfile/domainCaCert");
// [End cybersecurity_trusting_ca_others]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景七：配置SSL Pinning证书锁定-通过network_config.json文件进行静态SSL Pinning配置
 */

// [Start ssl_pining_json]
{
  "network-security-config": {
    "domain-config": [
      {
        "domains": [
          {
            "include-subdomains": true,
            "name": "server.com"
          }
        ],
        "pin-set": {
          "expiration": "2024-11-08",
          "pin": [
            {
              "digest-algorithm": "sha256",
              "digest": "g8CsdcpyAKxmLoWFvMd2hC7ZDUy7L4E2NYOi1i8qEtE=" // Hash of the server certificate public key
            }
          ]
        }
      }
    ]
  }
}
// [End ssl_pining_json]

/**
 * 最佳实践：网络连接安全配置开发实践
 * 场景八：配置SSL Pinning证书锁定-代码中动态设置进行动态SSL Pinning配置
 */

// [Start certificate_pinning]
 certificatePinning: [ //Optional, supports dynamic setting of certificate lock configuration information. This property is supported since API 12
    {
      publicKeyHash: 'g8CsdcpyAKxmLoWFvMd2hC7ZDUy7L4E2NYOi1i8qEtE=', // Hash of the server certificate public key
      hashAlgorithm: 'SHA-256' 
    }, {
      publicKeyHash: 'MGFiY2UyMDk5ZjEyMzI3MWQ4MDMyY2E4ODEzMmY3EtE=', // Hash of the secondary public key of the server certificate
      hashAlgorithm: 'SHA-256' 
    }
  ]
// [End certificate_pinning]
