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
* FAQ:如何生成带logo的二维码
 */

// [Start generate_qr_code]
import { image } from '@kit.ImageKit';
import { generateBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State pixelMap: image.PixelMap | undefined = undefined;
  private setting: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
  private img: ImageBitmap = new ImageBitmap('common/startIcon.png');

  createQRCode() {
    this.pixelMap = undefined;
    let content: string = 'helloWorld';
    // [Start generate_barcode]
    let options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: 300,
      width: 300
    };
    generateBarcode.createBarcode(content, options).then((pixelMap: image.PixelMap) => {
      this.pixelMap = this.pixelMap;
      this.context.drawImage(this.pixelMap, 0, 0, 300, 300, 0, 0, 300, 300);
      this.context.drawImage(this.img, 0, 0, 80, 80, 110, 110, 80, 80);
    }).catch((error: BusinessError) => {
      hilog.error(0x0001, '[generateBarcode]', 'promise error : %{public}s', JSON.stringify(error));
    })
    // [End generate_barcode]
  }

  build() {
    Column() {
      // [Start canvas]
      Canvas(this.context)
        .width(300)
        .height(300)
        .onReady(() => {
          this.createQRCode();
        })
      // [End canvas]
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}
// [End generate_qr_code]