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
* FAQ:自定义界面扫码预览画面出现拉伸
*/

// [Start ScreenStretched]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, customScan } from '@kit.ScanKit';

@Entry
@Component
struct customScanPage {
  // Set preview stream height, default unit: px
  @State cameraHeight: number = 1920;
  // Set preview stream width, default unit: px
  @State cameraWidth: number = 1080;
  private mXComponentController: XComponentController = new XComponentController();

  build() {
    Stack() {
      XComponent({
        id: 'componentId',
        type: XComponentType.SURFACE,
        controller: this.mXComponentController
      })
        .onLoad(() => {
          hilog.info(0x0001, '[Scan Sample]', 'onLoad is called')
          // Get the surfaceId of XCompoonent
          let surfaceId: string = this.mXComponentController.getXComponentSurfaceId();
          hilog.info(0x0001, 'viewControl', `onLoad surfaceId: ${surfaceId}`);
          // Set the corresponding fields for viewControl
          let viewControl: customScan.ViewControl = {
            width: this.cameraWidth,
            height: this.cameraHeight,
            surfaceId: surfaceId
          };
          try {
            customScan.start(viewControl).then((scanResult: Array<scanBarcode.ScanResult>) => {
              hilog.info(0x0001, '[Scan Sample]',
                `Succeeded in getting ScanResult by promise, scanResult is ${JSON.stringify(scanResult)}`);
            }).catch((error: BusinessError) => {
              hilog.error(0x0001, '[Scan Sample]',
                `Failed to get ScanResult by promise. Code: ${error.code}, message: ${error.message}`);
            })
          } catch (error) {
            hilog.error(0x0001, '[Scan Sample]',
              `Failed to start customScan. Code: ${error.code}, message: ${error.message}`);
          }
        })
        .height(this.cameraHeight + 'px')
        .width(this.cameraWidth + 'px')
        .position({ x: 0, y: 0 })
    }
    .alignContent(Alignment.Bottom)
    .height('100%')
    .width('100%')
    .position({ x: 0, y: 0 })
  }
}
// [End ScreenStretched]

