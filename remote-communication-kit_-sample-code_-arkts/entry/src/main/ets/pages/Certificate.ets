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

import { rcp } from '@kit.RemoteCommunicationKit';

// Replace the URL as needed.
const TEST_URL = 'https://example.com';
/**
 * The content of the certificate.
 * Replace the content of the certificate with that of the corresponding website as needed.
 */
const PEM_CA = '-----BEGIN CERTIFICATE-----\n' +
  'MIICPzCCAcWgAwIBAgIQBVVWvPJepDU1w6QP1atFcjAKBggqhkjOPQQDAzBhMQswCQYDVQQGEwJV\n' +
  'UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSAwHgYD\n' +
  'VQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBHMzAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAw\n' +
  'MDBaMGExCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k\n' +
  'aWdpY2VydC5jb20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEczMHYwEAYHKoZIzj0C\n' +
  'AQYFK4EEACIDYgAE3afZu4q4C/sLfyHS8L6+c/MzXRq8NOrexpu80JX28MzQC7phW1FGfp4tn+6O\n' +
  'YwwX7Adw9c+ELkCDnOg/QW07rdOkFFk2eJ0DQ+4QE2xy3q6Ip6FrtUPOZ9wj/wMco+I+o0IwQDAP\n' +
  'BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUs9tIpPmhxdiuNkHMEWNp\n' +
  'Yim8S8YwCgYIKoZIzj0EAwMDaAAwZQIxAK288mw/EkrRLTnDCgmXc/SINoyIJ7vmiI1Qhadj+Z4y\n' +
  '3maTD/HMsQmP3Wyr+mt/oAIwOWZbwmSNuJ5Q3KjVSaLtx9zRSX8XAbjIho9OjIgrqJqpisXRAL34\n' +
  'VOKa5Vt8sycX\n' +
  '-----END CERTIFICATE-----';

@Entry
@Component
struct Certificate {
  @State message: string = '';

  build() {
    Column() {
      Text('Certificate')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ff100f0f')
        .margin({ top: 32, left: 16 })
        .alignSelf(ItemAlign.Start)

      Divider().color('gray').strokeWidth(1)

      Column() {
        Text('Test Url:')
          .fontColor('#ff100f0f')
          .fontWeight(FontWeight.Bold)
          .fontSize(14)
        Text(TEST_URL)
          .fontColor('#ff100f0f')
          .fontSize(12)
        Text('The content of the certificate:')
          .fontColor('#ff100f0f')
          .fontWeight(FontWeight.Bold)
          .fontSize(14)
        Scroll() {
          Text(PEM_CA)
            .width('100%')
            .fontColor('#ff100f0f')
            .fontSize(10)
        }
        .width('100%')
        .height(180)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        Button('Certificate-Test')
          .height(40)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .margin({ top: 10 })
          .onClick(() => {
            this.requestWithCertificate();
          })
          .alignSelf(ItemAlign.Center)
      }.width('100%')
      .padding(15)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('Result:')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .margin({ bottom: 10 })

        Scroll() {
          Text(this.message)
            .width('100%')
            .fontColor('#ff100f0f')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .padding(8)
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .backgroundColor('#F3F3F3')
        .borderRadius(10)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding(15)
    }.width('100%')
    .height('100%')
  }

  /**
   * Send an HTTP request and verify the server certificate.
   */
  private async requestWithCertificate() {
    try {
      const session = rcp.createSession();
      const request = new rcp.Request(TEST_URL);
      // Configure the certificate content as a string type.
      request.configuration = {
        security: {
          remoteValidation: {
            content: PEM_CA,
          }
        }
      }
      try {
        const response = await session.fetch(request);
        this.message = `Request succeeded, response: ${response.toString()}`;
        console.info(this.message);
      } catch (err) {
        this.message = `Request error: ${JSON.stringify(err)}`;
        console.error(this.message);
      } finally {
        session.close();
      }
    } catch (err) {
      this.message = `createSession error: ${JSON.stringify(err)}`;
      console.error(this.message);
    }
  }
}