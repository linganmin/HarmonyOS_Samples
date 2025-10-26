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

import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'VibratorUtil';

// [Start Vibrator]
// Vibration Tools Class
export class VibratorUtil {
  /*
   * The method of  Vibration.
   */
  Vibrator() {
    try {
      // Use the startVibration method to enable vibration and set the duration.
      vibrator.startVibration({
        type: 'time',
        duration: 1000,
      }, {
        id: 0,
        usage: 'alarm'
      }, (error: BusinessError) => {
        if (error) {
          hilog.error(0x0000, TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeed in starting vibration');
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x00000, TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}
// [End Vibrator]