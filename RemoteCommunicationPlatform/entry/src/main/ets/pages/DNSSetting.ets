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

import { BusinessError } from '@kit.BasicServicesKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import Logger from '../common/Logger';
import { CommonConstants } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function DNSSettingBuilder() {
  DNSSetting()
}

@Component
export struct DNSSetting {
  @State customizingDNS: string = '';
  @State staticDNS: string = '';
  @State dnsOverHttp: string = '';
  @State text: string = '';
  @State textArea: string = '';
  @StorageLink('CustomizingDNS') storageLinkCustomizingDNS: string = '';
  @StorageLink('StaticDNS') storageLinkStaticDNS: string = '';
  @StorageLink('DnsOverHttp') storageLinkDnsOverHttp: string = '';

  setDnsServers() {
    // [Start session_with_custom_dns]
    // Configure a User-Defined DNS Server
    const customDnsServers: rcp.DnsServers = [
      { ip: '8.8.8.8' },
      { ip: '8.8.4.4', port: 53 }
    ];
    // Creating a Communication Session Object
    try {
      const sessionWithCustomDns = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsRules: customDnsServers
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });
      // Initiate a request
      sessionWithCustomDns.get('http://www.example.com').then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End session_with_custom_dns]
      this.customizingDNS = JSON.stringify(customDnsServers, null, 2);
      this.textArea = this.customizingDNS;
      AppStorage.setOrCreate('CustomizingDNS', this.customizingDNS);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DNSSetting', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  setStaticDnsRules() {
    // [Start custom_static_dns]
    // When hostname is matched, the specified address is used preferentially
    const staticDnsRules: rcp.StaticDnsRules = [
      {
        host: 'example.com',
        port: 80,
        ipAddresses: ['192.168.1.1', '192.168.1.2']
      }
    ];
    // Creating a Communication Session Object
    try {
      const sessionWithCustomDns = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsRules: staticDnsRules
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });
      // Initiate a request
      sessionWithCustomDns.get('http://www.example.com').then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End custom_static_dns]
      this.staticDNS = JSON.stringify(staticDnsRules, null, 2);
      this.textArea = this.staticDNS;
      AppStorage.setOrCreate('StaticDNS', this.staticDNS);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DNSSetting', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  setDnsOverHttps() {
    // [Start config_dns_on_https]
    // DNS over HTTPS Configuration
    const dohConfig: rcp.DnsOverHttpsConfiguration = {
      url: 'https://dns.example.com/dns-query',
      skipCertificatesValidation: true
    };
    // Creating a Communication Session Object
    try {
      const sessionWithCustomDns = rcp.createSession({
        requestConfiguration: {
          dns: {
            dnsOverHttps: dohConfig
          },
          security: {
            tlsOptions: {
              tlsVersion: 'TlsV1.3'
            }
          }
        }
      });
      // Initiate a request
      sessionWithCustomDns.get('http://www.example.com').then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End config_dns_on_https]
      this.dnsOverHttp = JSON.stringify(dohConfig, null, 2);
      this.textArea = this.dnsOverHttp;
      AppStorage.setOrCreate('DnsOverHttp', this.dnsOverHttp);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DNSSetting', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r(this.text))
            .margin({ bottom: $r('app.float.text_margin_bottom') })
            .textAlign(TextAlign.Start)
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.text_height'))
          TextArea({ text: this.textArea })
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.TEXTAREA_HEIGHT)
            .focusable(false)
        }

        Column({ space: CommonConstants.COLUMN_SPACE }) {
          Button($r('app.string.custom_dns'))
            .onClick(() => {
              this.text = 'app.string.set_custom_dns';
              this.textArea = this.storageLinkCustomizingDNS;
              if (!this.storageLinkCustomizingDNS) {
                this.setDnsServers();
              }
            })
            .width(CommonConstants.FULL_PERCENT)
          Button($r('app.string.static_dns'))
            .onClick(() => {
              this.text = 'app.string.set_static_dns';
              this.textArea = this.storageLinkStaticDNS;
              if (!this.storageLinkStaticDNS) {
                this.setStaticDnsRules();
              }
            })
            .width(CommonConstants.FULL_PERCENT)
          Button($r('app.string.dns_over_http'))
            .onClick(() => {
              this.text = 'app.string.set_dns_over_http';
              this.textArea = this.storageLinkDnsOverHttp;
              if (!this.storageLinkDnsOverHttp) {
                this.setDnsOverHttps();
              }
            })
            .width(CommonConstants.FULL_PERCENT)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding($r('app.float.padding'))
    }
  }
}