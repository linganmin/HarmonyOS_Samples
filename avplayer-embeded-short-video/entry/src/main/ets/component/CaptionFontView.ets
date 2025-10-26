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

import { CaptionFont } from '../model/CaptionFont';
import { CaptionFontConstants } from '../common/constants/Constants';

@Component
export struct CaptionFontView {
  @Prop captionFont: CaptionFont;
  close: (captionFont: CaptionFont | null) => void = () => {
  };

  @Builder
  FontFamily(text: ResourceStr) {
    Button(text)
      .fontSize(16)
      .fontColor(this.captionFont.family === text ? Color.Black : Color.White)
      .backgroundColor(this.captionFont.family === text ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0.1)')
      .onClick(() => {
        //set fontFamily of caption
        this.captionFont.family = text;
      })
  }

  @Builder
  FontSize(text: ResourceStr) {
    Button(text)
      .fontSize(16)
      .fontColor(this.captionFont.size === Number(text) ? Color.Black : Color.White)
      .backgroundColor(this.captionFont.size === Number(text) ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0.1)')
      .onClick(() => {
        //set fontSize of caption
        this.captionFont.size = Number(text);
      })
  }

  @Builder
  FontColor(captionFontColor: ResourceColor) {
    Column() {
      if (this.captionFont.color === captionFontColor) {
        Column() {
        }
        .width(12)
        .height(12)
        .borderRadius('50%')
        .border({ width: 1, color: Color.Gray })
      }
    }
    .width(24)
    .height(24)
    .borderRadius('50%')
    .backgroundColor(captionFontColor)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      //set fontColor of caption
      this.captionFont.color = captionFontColor;
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.caption_title'))
            .fontSize(18)
            .fontWeight(700)
            .fontColor(Color.White)

          Blank()
          Row({ space: 24 }) {
            Image($r('app.media.x_mark'))
              .width(24)
              .height(24)
              .align(Alignment.Center)
              .onClick(() => {
                this.close(null);
              })
            Image($r('app.media.checkmark'))
              .width(24)
              .height(24)
              .align(Alignment.Center)
              .onClick(() => {
                this.close(this.captionFont);
              })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })

        Divider()
          .color('rgba(255,255,255,0.2)')

        Row({ space: 20 }) {
          Column() {
            Text($r('app.string.caption_family'))
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(500)
          }

          Row({ space: 12 }) {
            ForEach(CaptionFontConstants.CAPTION_FONT_FAMILY, (captionFontFamily: ResourceStr) => {
              this.FontFamily(captionFontFamily)
            }, (captionFontFamily: ResourceStr, index: number) => `${captionFontFamily}_${index}`)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 14, bottom: 14 })

        Divider()
          .color('rgba(255,255,255,0.2)')

        Row() {
          Column() {
            Text($r('app.string.caption_size'))
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(500)
          }

          Row({ space: 12 }) {
            ForEach(CaptionFontConstants.CAPTION_FONT_SIZE, (captionFontSize: ResourceStr) => {
              this.FontSize(captionFontSize)
            }, (captionFontSize: ResourceStr, index: number) => `${captionFontSize}_${index}`)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 14, bottom: 14 })

        Divider()
          .color('rgba(255,255,255,0.2)')

        Row() {
          Column() {
            Text($r('app.string.caption_color'))
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(500)
          }

          Row({ space: 16 }) {
            ForEach(CaptionFontConstants.CAPTION_FONT_COLOR, (captionFontColor: ResourceColor) => {
              this.FontColor(captionFontColor)
            }, (captionFontColor: ResourceColor, index: number) => `${captionFontColor}_${index}`)
          }
          .padding({
            left: 10,
            right: 10,
            top: 8,
            bottom: 8
          })
          .borderRadius(20)
          .backgroundColor('rgba(255,255,255,0.9)')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 14, bottom: 14 })

      }
      .width('40%')
      .height('100%')
      .linearGradient({
        angle: 269.43,
        colors: [['rgba(0,0,0,0.6)', 0.0148], ['rgba(0,0,0,0)', 0.99597]]
      })
      .position({ right: 0 })
      .padding({ top: 40, left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .margin({ bottom: 450 })
    .onClick(() => {
      this.close(null);
    })
  }
}