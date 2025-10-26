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
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { hilog } from '@kit.PerformanceAnalysisKit';
import nativePix from 'libentry.so';

@Component
export struct HDRImageConversionComponent {
  @Consume('pageInfos') pageInfo: NavPathStack;
  @State text: string = 'default';
  @State index: number = 0;
  @State isShow: boolean = false;
  @State pixelMapSrc: image.PixelMap | undefined = undefined;
  @State pixelMapDst: image.PixelMap | undefined = undefined;
  @State dualLayerMap: image.PixelMap | undefined = undefined;
  @State gainmapPixelMap: image.PixelMap | undefined = undefined;
  @State inputWidth: number = 0;
  @State inputHeight: number = 0;
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
          Row() {
            Text($r('app.string.single_to_dual'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            top: 32,
            bottom: 16
          })

          if (this.isShow) {
            Column({ space: 16 }) {
              Image(this.dualLayerMap)
                .width('100%')
                .aspectRatio(1.25)
                .borderRadius(16)
                .objectFit(ImageFit.Contain)
                .constraintSize({
                  maxWidth: 360
                })
              Image(this.gainmapPixelMap)
                .width('100%')
                .aspectRatio(1.25)
                .borderRadius(16)
                .objectFit(ImageFit.Contain)
                .constraintSize({
                  maxWidth: 360
                })
            }
          }
          Row() {
            Text($r('app.string.dual_to_single'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            top: 32,
            bottom: 16
          })
          if (this.isShow) {
            Image(this.dualLayerMap)
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
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .title($r('app.string.image_layer_conversion'))
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    .onAppear(() => {
       this.isShow = false;
       this.getImageInfo();
       this.hdrDecomposeAndCompose();
       this.isShow = true;
    })
  }

  getImageInfo(): void {
    if (!this.hdrPixelMap) {
      return;
    }
    try {
      const imageInfo: image.ImageInfo = this.hdrPixelMap.getImageInfoSync();
      this.inputWidth = imageInfo.size.width;
      this.inputHeight = imageInfo.size.height;
    } catch (e) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', `getImageInfo ${JSON.stringify(e)}`);
    }
  }

  hdrDecomposeAndCompose(): void {
    // [Start createPixelMap]
    let dualPixelMap: image.PixelMap = nativePix.createPixelMap(this.inputHeight, this.inputWidth);
    let gainmapPixelMap: image.PixelMap = nativePix.createPixelMap(this.inputHeight, this.inputWidth);
    // [End createPixelMap]
    try {
      // [Start colorSpaceManager]
      let colorSpaceDisplayP3: colorSpaceManager.ColorSpaceManager =
        colorSpaceManager.create(colorSpaceManager.ColorSpace.DISPLAY_P3);
      let colorSpaceHlg: colorSpaceManager.ColorSpaceManager =
        colorSpaceManager.create(colorSpaceManager.ColorSpace.BT2020_HLG);
      dualPixelMap.setColorSpace(colorSpaceDisplayP3);
      dualPixelMap.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.BASE);
      gainmapPixelMap.setColorSpace(colorSpaceDisplayP3);
      gainmapPixelMap.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.GAINMAP);
      // [End colorSpaceManager]
      nativePix.hdrDecompose(dualPixelMap, gainmapPixelMap, this.hdrPixelMap);
      this.dualLayerMap = dualPixelMap;
      this.gainmapPixelMap = gainmapPixelMap;
      // [Start createPixelMapSync]
      let opts: image.InitializationOptions = {
        editable: true,
        pixelFormat: image.PixelMapFormat.YCBCR_P010,
        size: {
          height: this.inputHeight,
          width: this.inputWidth
        }
      };
      let outPutPixelMap = image.createPixelMapSync(opts);
      // [End createPixelMapSync]
      // [Start setColorSpace]
      outPutPixelMap.setColorSpace(colorSpaceHlg);
      outPutPixelMap.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.ALTERNATE);
      // [End setColorSpace]
      nativePix.hdrCompose(dualPixelMap, gainmapPixelMap, outPutPixelMap);
      this.pixelMapDst = outPutPixelMap;
    } catch (error) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages',
        'hdrDecomposeAndCompose try catch ' + JSON.stringify(error));
    }
  }
}

@Builder
export function HDRImageConversionComponentBuilder() {
  HDRImageConversionComponent()
}