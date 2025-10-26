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
* FAQ:将pixelFormat设置为nv21或者nv12时抛出错误码62980096怎么处理
*/

// [Start PixelFormat]
import { image } from '@kit.ImageKit';

@Entry
@Component
struct Index {
  @State message: string = 'NV21AndNV12ToPixelMap';
  @State private pixelMap: PixelMap | null = null;
  @State private pixelMap2: PixelMap | null = null;

  build() {
    Row() {
      Column() {
        Image(this.pixelMap)
          .width(200).height(200).margin(15)
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async () => {
            let resourceManager = this.getUIContext().getHostContext()!.resourceManager
            let imageArray = await resourceManager.getMediaContent($r("app.media.sample14_NV21_fromJPG_510X510"));
            let pixelBuffer = new Uint8Array(imageArray).buffer as Object as ArrayBuffer;
            // The value 8 of the sourcePixelFormat parameter corresponds to NV21 format, and 9 corresponds to NV12 format; The sourceSize parameter needs to set the width and height (the width and height data of the original yuv image), and the width value cannot be odd.
            let sourceOptions: image.SourceOptions =
              { sourceDensity: 120, sourcePixelFormat: 8, sourceSize: { width: 510, height: 510 } };
            let imageResource = image.createImageSource(pixelBuffer, sourceOptions);
            let opts: image.DecodingOptions = { editable: true }
            this.pixelMap = await imageResource.createPixelMap(opts);

            let imageArray2 = await resourceManager.getMediaContent($r('app.media.sample10_NV12_fromJPG_510X510'));
            let pixelBuffer2 = new Uint8Array(imageArray2).buffer as Object as ArrayBuffer;
            // The value 8 of the sourcePixelFormat parameter corresponds to NV21 format, and 9 corresponds to NV12 format; The sourceSize parameter needs to set the width and height (the width and height data of the original yuv image), and the width value cannot be odd.
            let sourceOptions2: image.SourceOptions =
              { sourceDensity: 120, sourcePixelFormat: 9, sourceSize: { width: 510, height: 510 } };
            let imageResource2 = image.createImageSource(pixelBuffer2, sourceOptions2);
            let opts2: image.DecodingOptions = { editable: true }
            this.pixelMap2 = await imageResource2.createPixelMap(opts2);
          })
        Image(this.pixelMap2)
          .width(200).height(200).margin(15)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End PixelFormat]

