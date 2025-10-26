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

import { trustedAppService } from '@kit.DeviceSecurityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { CertChain } from '../Common/CertChain';

class LocationService {
  private timeout: number;
  private challenge: string;
  private certChainObj: CertChain | undefined;

  constructor(timeout: number, userData: string) {
    this.challenge = userData;
    this.timeout = timeout;
  }

  private async initSecureLocationAttestContext(): Promise<void> {
    try {
      const seqId = 0;
      const initProperties: Array<trustedAppService.AttestParam> = [
        {
          tag: trustedAppService.AttestTag.ATTEST_TAG_DEVICE_TYPE,
          value: trustedAppService.AttestType.ATTEST_TYPE_LOCATION
        },
        {
          tag: trustedAppService.AttestTag.ATTEST_TAG_DEVICE_ID,
          value: BigInt(seqId)
        }
      ];
      const initOptions: trustedAppService.AttestOptions = {
        properties: initProperties
      };
      const certChainResult = await trustedAppService.initializeAttestContext(this.challenge, initOptions);
      if (certChainResult.certChains.length < 1) {
        throw new Error('empty returned cert chain');
      }
      this.certChainObj = new CertChain(certChainResult.certChains[0]);
      await this.certChainObj.validate();
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  private async verifySecureLocation(secureLocation: trustedAppService.SecureLocation): Promise<void> {
    try {
      // Concatenate the original character string
      const originString = secureLocation.originalLocation.latitude.toFixed(15) + ',' +
      secureLocation.originalLocation.longitude.toFixed(15) + ',' +
      secureLocation.originalLocation.altitude.toFixed(15) + ',' +
      secureLocation.originalLocation.accuracy.toFixed(6) + ',' +
      secureLocation.originalLocation.timestamp + ',' + secureLocation.userData.toString();
      // Obtain the signature result
      const base64Helper = new util.Base64Helper();
      const signature = base64Helper.decodeSync(secureLocation.signature.toString());
      // Verify the signature.
      const textEncoder = new util.TextEncoder();
      const inputData: cryptoFramework.DataBlob = {
        data: new Uint8Array(textEncoder.encodeInto(originString))
      };
      const signatureData: cryptoFramework.DataBlob = {
        data: new Uint8Array(signature)
      }
      const pubKey = await this.certChainObj?.getPubKey();
      const verifier = cryptoFramework.createVerify('ECC256|SHA256');
      verifier.initSync(pubKey);
      if (!verifier.verifySync(inputData, signatureData)) {
        throw new Error('secure location validation failed');
      }
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  public async getVerifiedSecureLocation(priority: trustedAppService.LocatingPriority): Promise<string> {
    try {
      await this.initSecureLocationAttestContext();
      const secureLocation = await trustedAppService.getCurrentSecureLocation(this.timeout, priority);
      /**
       * The best practice is to complete the secure location verification on the server.
       * The reference code is provided here.
       */
      await this.verifySecureLocation(secureLocation);
      return JSON.stringify(secureLocation.originalLocation);
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }
}

export default new LocationService(10000, 'trusted_app_service_default_userdata');
