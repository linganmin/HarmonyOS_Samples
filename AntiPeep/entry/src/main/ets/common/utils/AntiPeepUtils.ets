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

import { dlpAntiPeep } from '@kit.DeviceSecurityKit';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface AntiPeepCallback {
  onStatusChanged: (status: dlpAntiPeep.DlpAntiPeepStatus) => void;
}

/*
* can use screen privacy capability
* */
export function canUseAntiPeep(): boolean {
  return canIUse('SystemCapability.Security.DlpAntiPeep');
}

/*
* is screen privacy enabled
* */
export async function isAntiPeepOn(): Promise<boolean> {
  try {
    let result: boolean = await dlpAntiPeep.isDlpAntiPeepSwitchOn();
    hilog.info(0x0000, 'AntiPeepUtils', `[isAntiPeepOn] isDlpAntiPeepSwitchOn success. ${result}`);
    return result;
  } catch (err) {
    hilog.error(0x0000, 'AntiPeepUtils', `[isAntiPeepOn] isDlpAntiPeepSwitchOn failed.${JSON.stringify(err)}`);
    return false;
  }
}

/*
* get current screen privacy status
* */
export function getAntiPeepInfo(): dlpAntiPeep.DlpAntiPeepStatus {
  try {
    let dlpAntiPeepStatus = dlpAntiPeep.getDlpAntiPeepInfo();
    hilog.info(0x0000, 'AntiPeepUtils', `getDlpHideInfo success. ${JSON.stringify(dlpAntiPeepStatus)}`);
    return dlpAntiPeepStatus;
  } catch (err) {
    hilog.info(0x0000, 'AntiPeepUtils', `getDlpHideInfo failed. ${JSON.stringify(err)}`);
    return -1;
  }
}

/*
* listen on screen privacy
* */
export function listenOnAntiPeepStatus(antiPeepCB: AntiPeepCallback): boolean {
  try {
    hilog.info(0x0000, 'AntiPeepUtils', `start on('dlpAntiPeep')`);
    dlpAntiPeep.on('dlpAntiPeep', (dlpAntiPeepStatus: dlpAntiPeep.DlpAntiPeepStatus) => {
      hilog.info(0x0000, 'AntiPeepUtils', `dlpAntiPeep callback: ${JSON.stringify(dlpAntiPeepStatus)}`);
      if (antiPeepCB) {
        antiPeepCB.onStatusChanged(dlpAntiPeepStatus);
      } else {
        hilog.warn(0x0000, 'AntiPeepUtils', `antiPeepCB is empty`);
      }
    });
    hilog.info(0x0000, 'AntiPeepUtils', `on('dlpAntiPeep') ok`);
    return true;
  } catch (err) {
    hilog.error(0x0000, 'AntiPeepUtils', `dlpAntiPeep.on failed. ${JSON.stringify(err)}`);
    return false;
  }
}

/*
* listen off screen privacy
* */
export function listenOffAntiPeepStatus() {
  try {
    hilog.info(0x0000, 'AntiPeepUtils', `start off('dlpAntiPeep')`);
    dlpAntiPeep.off('dlpAntiPeep');
    hilog.info(0x0000, 'AntiPeepUtils', `off('dlpAntiPeep') ok`);
  } catch (err) {
    hilog.error(0x0000, 'AntiPeepUtils', `dlpAntiPeep.off failed. ${JSON.stringify(err)}`);
  }
}