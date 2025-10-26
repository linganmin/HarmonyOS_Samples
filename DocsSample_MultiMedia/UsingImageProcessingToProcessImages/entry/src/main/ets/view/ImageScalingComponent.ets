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
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct ImageScalingComponent {
  @Consume('pageInfos') pageInfo: NavPathStack;
  @State text: string = 'default';
  @State index: number = 0;
  @State isShow: boolean = false;
  @State pixelMapSrc: image.PixelMap | undefined = undefined;
  @State pixelMapDst: image.PixelMap | undefined = undefined;
  @State inputWidth: number = 0;
  @State inputHeight: number = 0;
  private zoomRatio: number = 1.5;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.sdr_image'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            bottom: 16
          })

          Image($rawfile('ic_scaling.png'))
            .width('100%')
            .aspectRatio(1.25)
            .borderRadius(16)
            .objectFit(ImageFit.Contain)
            .constraintSize({
              maxWidth: 360
            })

          Row({ space: 12 }) {
            Text($r('app.string.scaling'))
              .fontSize(18)
              .fontColor($r('sys.color.mask_secondary'))
            Select([
              { value: 'NONE' },
              { value: 'LOW' },
              { value: 'MEDIUM' },
              { value: 'HIGH' }
            ])
              .selectedOptionFontColor($r('sys.color.black'))
              .selectedOptionBgColor('#1a0a59f7')
              .selected(this.index)
              .value(this.text)
              .font({ size: 16, weight: 500 })
              .selectedOptionFont({ size: 16, weight: 400 })
              .optionFont({ size: 16, weight: 400 })
              .arrowPosition(ArrowPosition.END)
              .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
              .optionWidth(200)
              .optionHeight(300)
              .onSelect((index: number, text: string) => {
                this.isShow = false;
                this.index = index;
                if (text) {
                  this.text = text;
                }
                this.pixelMapDst = undefined;
                this.getPixMap();
                nativePix.detailEnhance(this.pixelMapSrc, this.pixelMapDst, this.inputWidth, this.inputHeight,
                  this.index);
                this.isShow = true;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({
            top: 32,
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
    .title($r('app.string.image_scaling'))
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
  }

  getPixMap(): void {
    try {
      let imageSource: image.ImageSource =
        image.createImageSource(this.getUIContext().getHostContext()?.resourceManager.getRawFdSync('ic_scaling.png'));
      this.pixelMapSrc = imageSource.createPixelMapSync();
      const imageInfo: image.ImageInfo = this.pixelMapSrc.getImageInfoSync();
      const opts: image.InitializationOptions = {
        editable: true,
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        size: {
          height: imageInfo.size.height * this.zoomRatio,
          width: imageInfo.size.width * this.zoomRatio
        }
      };
      this.inputWidth = imageInfo.size.width;
      this.inputHeight = imageInfo.size.height;
      this.pixelMapDst = image.createPixelMapSync(opts);
    } catch (e) {
      hilog.error(0x0000, 'UsingImageProcessingToProcessImages', `getPixMap error ${JSON.stringify(e)}`);
    }
  }
}

@Builder
export function ImageScalingComponentBuilder() {
  ImageScalingComponent()
}