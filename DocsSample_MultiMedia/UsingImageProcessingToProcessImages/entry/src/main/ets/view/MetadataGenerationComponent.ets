/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { image } from '@kit.ImageKit';
import nativePix from 'libentry.so';
import { colorSpaceManager } from '@kit.ArkGraphics2D';

@Component
export struct MetadataGenerationComponent {
  @Consume('pageInfos') pageInfo: NavPathStack;
  @State isShow: boolean = false;
  @State pixelMapDst: image.PixelMap | undefined = undefined;
  @StorageLink('hdrPixelMap') hdrPixelMap: image.PixelMap | undefined = undefined;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.hdr_image'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            bottom: 16
          })

          Image(this.hdrPixelMap)
            .width('100%')
            .aspectRatio(1.25)
            .borderRadius(16)
            .objectFit(ImageFit.Contain)
            .constraintSize({
              maxWidth: 360
            })
          Row({ space: 12 }) {
            Text($r('app.string.generate_hdr_images'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            top: 16,
            bottom: 16
          })

          if (this.isShow) {
            Image(this.pixelMapDst)
              .width('100%')
              .aspectRatio(1.25)
              .borderRadius(16)
              .objectFit(ImageFit.Contain)
              .constraintSize({
                maxWidth: 360
              })
          }
        }
        .padding(16)
      }
      .scrollBar(BarState.Off)
    }
    .title($r('app.string.metadata_generation'))
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    .onAppear(() => {
      if (!this.hdrPixelMap) {
        return;
      }
      this.isShow = false;
      // [Start colorSpaceManager]
      let colorSpaceBT2020_HLG: colorSpaceManager.ColorSpaceManager =
        colorSpaceManager.create(colorSpaceManager.ColorSpace.BT2020_HLG);
      this.hdrPixelMap.setColorSpace(colorSpaceBT2020_HLG);
      this.hdrPixelMap.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.ALTERNATE);
      // [End colorSpaceManager]
      nativePix.generateMetadata(this.hdrPixelMap);
      this.pixelMapDst = this.hdrPixelMap;
      this.isShow = true;
    })
  }
}

@Builder
export function MetadataGenerationComponentBuilder() {
  MetadataGenerationComponent()
}