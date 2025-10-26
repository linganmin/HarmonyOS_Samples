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
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import nativePix from 'libentry.so';

@Component
export struct ImageColorSpaceConversionComponent {
  @Consume('pageInfos') pageInfo: NavPathStack;
  @State text: string = '';
  @State colorSpace: string = '';
  @State canConvertSRGB: boolean = false;
  @State canConvertP3: boolean = false;
  @State canConvertHLG: boolean = false;
  @State isCanConverting: boolean = false;
  @State isShow: boolean = false;
  @State hasPhoto: boolean = false;
  @State aiHdrError: boolean = false;
  @State pixelMapSrc: image.PixelMap | undefined = undefined;
  @State pixelMapDst: image.PixelMap | undefined = undefined;
  @State inputWidth: number = 0;
  @State inputHeight: number = 0;
  @State srcColorSpace: number = 0;
  @State targetColorSpace: colorSpaceManager.ColorSpaceManager | undefined = undefined;
  @StorageLink('hdrPixelMap') hdrPixelMap: image.PixelMap | undefined = undefined;

  @Builder
  colorSpaceMenu() {
    Menu() {
      MenuItemGroup({ header: 'SDR' }) {
        MenuItem({ content: 'sRGB' })
          .enabled(this.canConvertSRGB)
          .onClick(() => {
            this.targetColorSpace = colorSpaceManager.create(colorSpaceManager.ColorSpace.SRGB);
            this.colorspaceConvert();
          })
        MenuItem({ content: 'DisplayP3' })
          .enabled(this.canConvertP3)
          .onClick(() => {
            this.targetColorSpace = colorSpaceManager.create(colorSpaceManager.ColorSpace.DISPLAY_P3);
            this.colorspaceConvert();
          })
      }

      MenuItemGroup({ header: 'HDR' }) {
        MenuItem({ content: 'HLG' })
          .enabled(this.canConvertHLG)
          .onClick(() => {
            this.targetColorSpace = colorSpaceManager.create(colorSpaceManager.ColorSpace.BT2020_HLG);
            this.colorspaceConvert();
          })
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Row({ space: 12 }) {
              Text(this.text)
                .fontSize(18)
                .fontColor($r('sys.color.mask_secondary'))
              Text(this.colorSpace)
                .fontSize(18)
                .fontColor($r('sys.color.mask_secondary'))
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: 16
            })

            Image(this.pixelMapSrc)
              .width('100%')
              .aspectRatio(1.25)
              .borderRadius(16)
              .objectFit(ImageFit.Contain)
              .constraintSize({
                maxWidth: 360
              })
            if (this.srcColorSpace !== 0 && !this.isCanConverting) {
              Row() {
                Text($r('app.string.can_not_converting'))
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_warning'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({
                top: 12
              })
            }
            if (this.srcColorSpace !== 0 && this.isCanConverting) {
              Button($r('app.string.color_space_conversion'))
                .bindMenu(this.colorSpaceMenu())
                .width('100%')
                .margin({
                  top: 32,
                  bottom: 16
                })
              if (this.aiHdrError) {
                Row() {
                  Text($r('app.string.sdr_not_hdr'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_warning'))
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .margin({
                  top: -4
                })
              }
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
          }
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)

        if (!this.hasPhoto) {
          Button($r('app.string.select_image'))
            .fontSize(16)
            .width('100%')
            .onClick(() => {
              this.pickerPicture();
            })
        }
      }
      .padding(16)
      .height('100%')
      .width('100%')
      .justifyContent(this.hasPhoto ?FlexAlign.Start : FlexAlign.SpaceBetween)
    }
    .title($r('app.string.image_space_conversion'))
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
  }

  getColorSpace(): void {
    if (!this.pixelMapSrc) {
      return;
    }
    // [Start getImageInfo]
    try {
      const imageInfo: image.ImageInfo = this.pixelMapSrc.getImageInfoSync();
      this.inputWidth = imageInfo.size.width;
      this.inputHeight = imageInfo.size.height;
      if (imageInfo.isHdr) {
        this.text = 'HDR';
        this.hdrPixelMap = this.pixelMapSrc;
      } else {
        this.text = 'SDR';
      }
    } catch (e) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', `getImageInfoSync ${JSON.stringify(e)}`);
    }
    // [End getImageInfo]
    this.canConvertSRGB = false;
    this.canConvertP3 = false;
    this.canConvertHLG = false;
    try {
      this.srcColorSpace = this.pixelMapSrc.getColorSpace().getColorSpaceName();
    } catch (e) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', `getColorSpaceName ${JSON.stringify(e)}`);
    }
    hilog.info(0x0000, 'UsingImageProcessingToProcessImages', 'the iamge color space is ' + this.srcColorSpace);
    switch (this.srcColorSpace) {
      case colorSpaceManager.ColorSpace.ADOBE_RGB_1998:
        this.colorSpace = 'ADOBE_RGB_1998';
        this.canConvertSRGB = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.DISPLAY_P3:
        this.colorSpace = 'DISPLAY_P3';
        this.canConvertSRGB = true;
        this.canConvertHLG = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.SRGB:
        this.colorSpace = 'SRGB';
        this.canConvertHLG = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.SRGB_LIMIT:
        this.colorSpace = 'SRGB_LIMIT';
        this.canConvertHLG = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.DISPLAY_P3_LIMIT:
        this.colorSpace = 'DISPLAY_P3_LIMIT';
        this.canConvertSRGB = true;
        this.canConvertHLG = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT:
        this.colorSpace = 'BT2020_HLG_LIMIT';
        this.canConvertSRGB = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.BT2020_HLG:
        this.colorSpace = 'ADOBE_RGB_1998';
        this.canConvertSRGB = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.BT2020_PQ:
        this.colorSpace = 'ADOBE_RGB_1998';
        this.canConvertSRGB = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      case colorSpaceManager.ColorSpace.BT2020_PQ_LIMIT:
        this.colorSpace = 'ADOBE_RGB_1998';
        this.canConvertSRGB = true;
        this.canConvertP3 = true;
        this.isCanConverting = true;
        break;
      default:
        this.isCanConverting = false;
    }
  }

  colorspaceConvert(): void {
    let outPutPixelMap: image.PixelMap | undefined = undefined;
    this.isShow = false;
    this.aiHdrError = false;
    this.pixelMapDst = undefined;
    try {
      if (this.targetColorSpace?.getColorSpaceName() != colorSpaceManager.ColorSpace.BT2020_HLG) {
        // [Start createPixelMap]
        outPutPixelMap = nativePix.createPixelMap(this.inputHeight, this.inputWidth);
        // [End createPixelMap]
        // [Start setMetadata]
        outPutPixelMap?.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.NONE);
        outPutPixelMap?.setColorSpace(this.targetColorSpace);
        // [End setMetadata]
        if (this.text === 'SDR') {
          let srcPixelMap = nativePix.createPixelMap(this.inputHeight, this.inputWidth);
          let buffer = this.inputHeight * this.inputWidth * 4;
          const readBuffer: ArrayBuffer = new ArrayBuffer(buffer);
          this.pixelMapSrc?.readPixelsToBufferSync(readBuffer);
          srcPixelMap.writeBufferToPixelsSync(readBuffer);
          let errorCode: number = nativePix.getNativeImgFromPixelMap(srcPixelMap, outPutPixelMap);
          hilog.error(0x0000, 'UsingImageProcessingToProcessImages', 'getNativeImgFromPixelMap ' + errorCode);
          this.pixelMapDst = outPutPixelMap;
        } else {
          let errorCode: number = nativePix.getNativeImgFromPixelMap(this.pixelMapSrc, outPutPixelMap);
          hilog.error(0x0000, 'UsingImageProcessingToProcessImages', 'getNativeImgFromPixelMap ' + errorCode);
          this.pixelMapDst = outPutPixelMap;
        }
        this.isShow = true;
      } else {
        let srcPixelMap = nativePix.createPixelMap(this.inputHeight, this.inputWidth);
        let buffer = this.inputHeight * this.inputWidth * 4;
        const readBuffer: ArrayBuffer = new ArrayBuffer(buffer);
        this.pixelMapSrc?.readPixelsToBufferSync(readBuffer);
        srcPixelMap.writeBufferToPixelsSync(readBuffer);
        let opts: image.InitializationOptions = {
          editable: true,
          pixelFormat: image.PixelMapFormat.RGBA_1010102,
          size: {
            height: this.inputHeight,
            width: this.inputWidth
          }
        };
        outPutPixelMap = image.createPixelMapSync(opts);
        outPutPixelMap.setMetadata(image.HdrMetadataKey.HDR_METADATA_TYPE, image.HdrMetadataType.ALTERNATE);
        outPutPixelMap.setColorSpace(this.targetColorSpace);
        let errorCode: number = nativePix.hdrAIHDR(srcPixelMap, outPutPixelMap);
        hilog.error(0x0000, 'UsingImageProcessingToProcessImages', 'hdrAIHDR ' + errorCode);
        if (errorCode === 0) {
          this.pixelMapDst = outPutPixelMap;
          this.hdrPixelMap = outPutPixelMap;
          this.isShow = true;
        } else {
          this.aiHdrError = true;
        }
      }
    } catch (e) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', `colorspaceConvert ${JSON.stringify(e)}`);
    }
  }

  pickerPicture(): void {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoViewPicker.select(photoSelectOptions)
        .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          let fd = fileIo.openSync(photoSelectResult.photoUris[0], fileIo.OpenMode.READ_ONLY);
          const imageSource = image.createImageSource(fd.fd);
          let option: image.DecodingOptions = {};
          option.index = 0;
          option.desiredDynamicRange = image.DecodingDynamicRange.AUTO;
          this.pixelMapSrc = imageSource.createPixelMapSync(option);
          this.getColorSpace();
          this.hasPhoto = true;
        })
        .catch((error: BusinessError) => {
          hilog.error(0x0000, 'UsingImageProcessingToProcessImages', 'pickerPicture ' + error.code);
        });
    } catch (error) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', 'pickerPicture try catch ' + JSON.stringify(error));
    }
  }
}

@Builder
export function ImageColorSpaceConversionComponentBuilder() {
  ImageColorSpaceConversionComponent()
}