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

import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';
import { Logger } from '../common/Logger';

@Component
export struct XComponentView {
  @Prop cameraWidth: number;
  @Prop cameraHeight: number;
  playAnimation: (() => void) | null = null;
  private mXComponentController: XComponentController = new XComponentController();

  aboutToAppear(): void {
    const options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };

    try {
      customScan.init(options);
    } catch (error) {
      Logger.error(`Failed to init, error: ${JSON.stringify(error)}`);
    }
  }

  aboutToDisappear(): void {
    customScan.release().catch((error: BusinessError<void>) => {
      hilog.error(0x0000, 'testTag', 'release failed, code = %{public}d, message = %{public}s',
        error.code, error.message)
    })
  }

  build() {
    XComponent({
      id: 'componentId',
      type: XComponentType.SURFACE,
      controller: this.mXComponentController
    })
      .onLoad(() => {
        const surfaceId: string = this.mXComponentController.getXComponentSurfaceId();
        let viewControl: customScan.ViewControl = {
          width: this.cameraWidth,
          height: this.cameraHeight,
          surfaceId: surfaceId
        };
        try {
          customScan.start(viewControl, (error: BusinessError, scanResult: Array<scanBarcode.ScanResult>) => {
            if (error) {
              Logger.error(`start failed , error: ${JSON.stringify(error)}`);
              return;
            }
            Logger.info(`callback scan result: ${JSON.stringify(scanResult)}`);
          });
          this.playAnimation && this.playAnimation();
        } catch (error) {
          Logger.error(`start failed , error: ${JSON.stringify(error)}`);
        }
      })
      .width(this.cameraWidth)
      .height(this.cameraHeight)
  }
}