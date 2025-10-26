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
* FAQ:如何实现PixelMap和base64的相互转换
*/

// [Start PixelMapAndBase64ConverToEachOther_One]
import { image } from '@kit.ImageKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  @State message: string = 'PixelMapToBase64';
  @State base64: string = '';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async () => {
            let resourceManager = this.getUIContext().getHostContext()!.resourceManager
            let imageArray = await resourceManager.getMediaContent($r('app.media.sample7'));
            let pixelBuffer = new Uint8Array(imageArray).buffer as Object as ArrayBuffer;
            let imageResource = image.createImageSource(pixelBuffer);
            let opts: image.DecodingOptions = { editable: true }
            let pixelMap = await imageResource.createPixelMap(opts);

            // 转换成base64
            const imagePackerApi: image.ImagePacker = image.createImagePacker();
            let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
            imagePackerApi.packToData(pixelMap, packOpts).then((data: ArrayBuffer) => {
              let buf: buffer.Buffer = buffer.from(data);
              this.base64 = 'data:image/jpeg;base64,' + buf.toString('base64', 0, buf.length);
              console.info('base64: ' + this.base64);
            })
          })
        Image(this.base64)
          .width(200).height(200).margin(15)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End PixelMapAndBase64ConverToEachOther_One]