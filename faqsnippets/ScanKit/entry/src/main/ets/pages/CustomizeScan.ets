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
* FAQ:自定义界面扫码如何实现扫码框
*/

// [Start CustomizeScan]
import { customScan, scanBarcode } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// For example, the width and height set by XCompoonent are cameraWidth=1080px and cameraHeight=1920px
let cameraWidth = 1080;
let cameraHeight = 1920;
// If the custom scan box has a scan box of 800px * 800px in the middle of the screen, then the coordinates of the scan box relative to xCompoonent left: 140px, top: 560px, right: 940px, bottom: 1360px
let scanBoxWidth = 800;
let scanBoxHeight = 800;
let scanBox: scanBarcode.ScanCodeRect = {
  left: (cameraWidth - scanBoxWidth) / 2,
  top: (cameraHeight - scanBoxHeight) / 2,
  right: (cameraWidth + scanBoxWidth) / 2,
  bottom: (cameraHeight + scanBoxHeight) / 2
}

// Set ViewControl parameters
let viewControl: customScan.ViewControl = {
  width: cameraWidth,
  height: cameraHeight,
  surfaceId: '123' // Mock data, actually needs to be generated and obtained from components
};
try {
  customScan.start(viewControl, async (error: BusinessError, result: Array<scanBarcode.ScanResult>) => {
    if (error) {
      // Scan code recognition failed
      return;
    }
    // For example, the result returned by the mock scan is the first result [0]={left: 150px, top: 400px, right: 450px, bottom: 700px}
    let scanResult: scanBarcode.ScanCodeRect = {
      left: 150,
      top: 400,
      right: 450,
      bottom: 700
    };
    // Determine whether the code map is located within the scanning box range
    if (scanResult.left >= scanBox.left && scanResult.top >= scanBox.top && scanResult.right <= scanBox.right &&
      scanResult.bottom <= scanBox.bottom) {
      // Scan code successfully, the code image is located within the scanning box range, and the scanning result will be processed according to business requirements
    } else {
      // The code map position is not within the scanning box range, continue scanning the code
      try {
        customScan.rescan();
      } catch (error) {
        hilog.error(0x0001, '[Scan Sample]', `Failed to rescan. Code: ${error.code}, message: ${error.message}`);
      }
    }
  });
} catch (error) {
  hilog.error(0x0001, '[Scan Sample]', `Failed to start customScan. Code: ${error.code}, message: ${error.message}`);
}
// [End CustomizeScan]

