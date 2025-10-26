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

import { cert } from '@kit.DeviceCertificateKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class CertChain {
  private certs: Array<string>;
  private beginString: string = '-----BEGIN CERTIFICATE-----';
  private pemRootCert = '-----BEGIN CERTIFICATE-----\r\n' +
    'MIICCTCCAY6gAwIBAgIDVxAsMAoGCCqGSM49BAMDMEsxEzARBgNVBAoTCkh1YXdl\r\n' +
    'aSBDQkcxNDAyBgNVBAMTK0h1YXdlaSBDQkcgRUNDIERldmljZSBBdHRlc3RhdGlv\r\n' +
    'biBSb290IENBIDEwIBcNMjMxMTMwMDIwNjU1WhgPMjA3MzExMzAwMjA2NTVaMEsx\r\n' +
    'EzARBgNVBAoTCkh1YXdlaSBDQkcxNDAyBgNVBAMTK0h1YXdlaSBDQkcgRUNDIERl\r\n' +
    'dmljZSBBdHRlc3RhdGlvbiBSb290IENBIDEwdjAQBgcqhkjOPQIBBgUrgQQAIgNi\r\n' +
    'AATDJzRdruaBeMoQBbdqCe51ezvkQn3OPYBoRmpL5KPktdFtD0b97FRp8jGLiUhP\r\n' +
    'Kyo8M15fxW5Ams4s80E8I1BSXoovDnkKllFfUadD8URgwEfOk5qttYNKzJcULavO\r\n' +
    'hbijQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW\r\n' +
    'BBTaRGLD5yvof1E6XEuPQ3w5JMPOrDAKBggqhkjOPQQDAwNpADBmAjEA2zDQREvO\r\n' +
    'RPqcZyjwKDltu0T9zN8Cd3/hi4DQZvuRJdJOY57yIIO/LKxezzEcGiMMAjEAkX7r\r\n' +
    '0U4Mcaw4uURMh+7tLMyvyxnlW8yJqBEOnZfqS8I8t0bQIY2r/5TQAPC0JhBm\r\n' +
    '-----END CERTIFICATE-----\r\n';

  constructor(certChain: string) {
    const certArray = certChain.split(this.beginString);
    if (certArray.length !== 4) {
      throw new Error('no enough certs');
    }
    this.certs = [
      this.beginString + certArray[1], this.beginString + certArray[2], this.beginString + certArray[3]
    ];
  }

  private getEncodingCertChain(certs: Array<string>): cert.CertChainData {
    const textEncoder = new util.TextEncoder();
    const thirdCert = textEncoder.encodeInto(certs[0]);
    const thirdCertLength = new Uint8Array(new Uint16Array([thirdCert.byteLength]).buffer);
    const secondCert = textEncoder.encodeInto(certs[1]);
    const secondCertLength = new Uint8Array(new Uint16Array([secondCert.byteLength]).buffer);
    const rootCert = textEncoder.encodeInto(certs[2]);
    const rootCertLength = new Uint8Array(new Uint16Array([rootCert.byteLength]).buffer);
    // Format: Length + Value
    let encodingData =
      new Uint8Array(thirdCertLength.length + thirdCert.length + secondCertLength.length + secondCert.length +
      rootCertLength.length + rootCert.length);
    let offset = 0;
    encodingData.set(thirdCertLength, offset);
    offset += thirdCertLength.length;
    encodingData.set(thirdCert, offset);
    offset += thirdCert.length;
    encodingData.set(secondCertLength, offset);
    offset += secondCertLength.length;
    encodingData.set(secondCert, offset);
    offset += secondCert.length;
    encodingData.set(rootCertLength, offset);
    offset += rootCertLength.length;
    encodingData.set(rootCert, offset);
    return {
      data: encodingData,
      count: 3,
      encodingFormat: cert.EncodingFormat.FORMAT_PEM
    };
  }

  public async validate(): Promise<void> {
    if (this.certs[2] !== this.pemRootCert) {
      throw new Error('no enough cert');
    }
    const encodingData = this.getEncodingCertChain(this.certs);
    try {
      const validator = cert.createCertChainValidator('PKIX');
      await validator.validate(encodingData);
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  public async getPubKey(): Promise<cryptoFramework.PubKey> {
    try {
      const textEncoder = new util.TextEncoder();
      const encodingBlob: cert.EncodingBlob = {
        data: textEncoder.encodeInto(this.certs[0]),
        encodingFormat: cert.EncodingFormat.FORMAT_PEM
      };
      const x509Cert = await cert.createX509Cert(encodingBlob);
      const asyKeyGenerator = cryptoFramework.createAsyKeyGenerator('ECC256');
      const keyPair = asyKeyGenerator.convertKeySync(x509Cert.getPublicKey().getEncoded(), null);
      return keyPair.pubKey;
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }
}