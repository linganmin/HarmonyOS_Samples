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

// [Start PixelMapAndBase64ConverToEachOther_Two]
import CommonConstants from '../common/constants/CommonContants';
import { util } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';

@Entry
@Component
struct Index {
  @State message: string = 'Base64ToPixelMap';
  private base64: string = CommonConstants.Image_Base64_String; // 该变量为图片的base64格式字符串
  @State private pixelMap: PixelMap | null = null;

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async () => {
            let helper = new util.Base64Helper();
            let buffer: ArrayBuffer = helper.decodeSync(this.base64, util.Type.MIME).buffer as ArrayBuffer;
            let imageSource = image.createImageSource(buffer);
            let opts: image.DecodingOptions = { editable: true };
            this.pixelMap = await imageSource.createPixelMap(opts);
          })
        Image(this.pixelMap)
          .width(200).height(200).margin(15)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End PixelMapAndBase64ConverToEachOther_Two]