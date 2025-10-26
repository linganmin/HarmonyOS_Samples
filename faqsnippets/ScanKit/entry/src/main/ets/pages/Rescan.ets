/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:自定义界面扫码如何连续扫码（customScan.rescan）
*/

// [Start Rescan]
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { customScan, scanBarcode } from '@kit.ScanKit';

@Entry
@Component
struct Index {
  private callback: AsyncCallback<Array<scanBarcode.ScanResult>> =
    async (error: BusinessError, result: Array<scanBarcode.ScanResult>) => {
      if (error) {
        hilog.error(0x0001, '[Scan Sample]',
          `Failed to get ScanResult by callback. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      hilog.info(0x0001, '[Scan Sample]',
        `Succeeded in getting ScanResult by callback, result is ${JSON.stringify(result)}`);
      try {
        // Retrigger code scanning: It is not necessary to restart the camera and trigger the code scanning again. You can call the rescan interface in the Callback asynchronous callback of the start interface.
        customScan.rescan();
      } catch (error) {
        hilog.error(0x0001, '[Scan Sample]', `Failed to rescan. Code: ${error.code}, message: ${error.message}`);
      }
    }

  build() {
  }
}
// [End Rescan]

