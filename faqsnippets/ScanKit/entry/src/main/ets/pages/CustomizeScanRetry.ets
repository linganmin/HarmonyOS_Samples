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
* FAQ:自定义界面扫码如何增加重试机制
*/

// [Start CustomizeScanRetry]
import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State viewControl: customScan.ViewControl = {
    width: 1080,
    height: 1080,
    surfaceId: ''
  };
  private retryScanTimes = 0;
  private options: scanBarcode.ScanOptions = {
    scanTypes: [scanCore.ScanType.ALL],
    enableMultiMode: true,
    enableAlbum: true
  };
  private customScanCallbackScan: AsyncCallback<scanBarcode.ScanResult[]> =
    async (error: BusinessError, result: scanBarcode.ScanResult[]) => {
      if (error && error.code !== 0) {
        hilog.error(0x0001, '[Scan Sample]',
          `An error is returned by customScan.start->CallbackScan. Code: ${error.code}`);
        // Start callback, triggers camera stream restart when internal error 1000500001 occurs
        if (error.code === scanCore.ScanErrorCode.INTERNAL_ERROR) {
          this.retryCamera(error);
        }
      }
      // Code recognition processing logic
      // ...
    }

  // Restart camera stream
  retryCamera(error: BusinessError) {
    if (this.retryScanTimes < 3 && error.code === scanCore.ScanErrorCode.INTERNAL_ERROR) {
      this.retryScanTimes++;
      let timeId = setTimeout(async () => {
        hilog.info(0x0001, '[Scan Sample]',
          `Retry camera start. Times: ${this.retryScanTimes}.`);
        // Pause and release the camera stream first
        await this.releaseCamera();
        // Restart camera stream
        this.startCamera();
        hilog.info(0x0001, '[Scan Sample]', 'Retry camera end.');
        clearTimeout(timeId);
      }, 100)
    }
  }

  // Start camera stream
  startCamera() {
    try {
      customScan.init(this.options);
      hilog.info(0x0001, '[Scan Sample]', 'customScan->init end');
      try {
        customScan.start(this.viewControl, this.customScanCallbackScan);
        hilog.info(0x0001, '[Scan Sample]', 'customScan->start end');
      } catch (error) {
        hilog.error(0x0001, '[Scan Sample]',
          `Failed to customScan->start. Code: ${error.code}, message: ${error.message}`);
      }
    } catch (error) {
      hilog.error(0x0001, '[Scan Sample]',
        `Failed to customScan->init. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Pause and release camera stream
  async releaseCamera() {
    try {
      await customScan.stop();
      hilog.info(0x0001, '[Scan Sample]', 'customScan->stop end');
      try {
        await customScan.release();
        hilog.info(0x0001, '[Scan Sample]', 'customScan->release end');
      } catch (error) {
        hilog.error(0x0001, '[Scan Sample]',
          `Failed to customScan->release. Code: ${error.code}, message: ${error.message}`);
      }
    } catch (error) {
      hilog.error(0x0001, '[Scan Sample]',
        `Failed to customScan->stop. Code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
  }
}
// [End CustomizeScanRetry]

