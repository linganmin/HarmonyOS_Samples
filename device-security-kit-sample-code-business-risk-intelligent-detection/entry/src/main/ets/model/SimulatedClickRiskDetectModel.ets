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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { businessRiskIntelligentDetection } from '@kit.DeviceSecurityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[SimulatedClickRiskDetectModel]';

export class SimulatedClickRiskDetectModel {
  private displayText: String = '';

  private simulatedClickRiskDetectPromise(): Promise<String> {
    return new Promise(async (resolve: Function, reject: Function) => {
      let params: businessRiskIntelligentDetection.SimulatedClickDetectionRequest = {
        version: 1
      };
      try {
        businessRiskIntelligentDetection.detectSimulatedClickRisk(params).then((result: string) => {
          // Indicates communication with the service was successful.
          // Use result to get the result data.
          // It is recommended that the result be parsed and verified on the server.
          resolve(result);
        }).catch((error: Error) => {
          // An error occurred while communicating with the service.
          let e: BusinessError = error as BusinessError;
          hilog.error(0x0000, TAG, '%{public}s', `Detect simulated click risk failed: ${e.code} , ${e.message}`);
          reject(error);
        });
      } catch (error) {
        // An error occurred while using api.
        let e: BusinessError = error as BusinessError;
        hilog.error(0x0000, TAG, '%{public}s', `Detect simulated click risk failed: ${e.code} , ${e.message}`);
        reject(error);
      }
    });
  }

  async simulatedClickRiskDetect(callback: Function) {
    this.displayText = '';
    hilog.info(0x0000, TAG, '%{public}s', 'Detect simulated click risk begin.');
    this.simulatedClickRiskDetectPromise().then((result) => {
      hilog.info(0x0000, TAG, 'Detect simulated click risk success: %{public}s', result);
      this.displayText = result;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'Detect simulated click risk failed, errCode is ' + err.code;
      callback(this.displayText);
    });
  }
}

let simulatedClickRiskDetectModel = new SimulatedClickRiskDetectModel();

export default simulatedClickRiskDetectModel as SimulatedClickRiskDetectModel;
