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
// [Start scan_util]
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { CyclingConstants, CyclingStatus } from '../constants/CyclingConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

export class ScanUtil {
  public static scan(obj: Object, uiContext: UIContext): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE],
      enableMultiMode: true,
      enableAlbum: true
    };
    try {
      scanBarcode.startScanForResult(uiContext?.getHostContext(), options).then((result: scanBarcode.ScanResult) => {
        Logger.info('[BicycleSharing]', 'Promise scan result: %{public}s', JSON.stringify(result));
        if (result.scanType === CyclingConstants.SCAN_TYPE) {
          AppStorage.setOrCreate(CyclingConstants.CYCLING_STATUS, CyclingStatus.WAITING_UNLOCK);
          uiContext?.getRouter().pushUrl({ url: 'pages/ConfirmUnlock' });
        }
      }).catch((error: BusinessError) => {
        Logger.error(0x0001, '[BicycleSharing]', 'Promise error: %{public}s', JSON.stringify(error));
      });
    } catch (error) {
      Logger.error(0x0001, '[BicycleSharing]', 'failReason: %{public}s', JSON.stringify(error));
    }
  }
}

// [End scan_util]