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

import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct TakeOutDetails {
  @State @Watch('resizeImage') ifPictureExpansion: Boolean = false;
  @State @Watch('resizeImage') imageRatio: number = 0;
  @State @Watch('resizeImage') imageWidth: number = 0;
  @State speed: number = 0;
  @State rotateAngle: number = 0;
  @State imageHeightExtension: number = 0;
  @State imageHeightFold: number = 0;
  @State imageHeight: number = 0;
  private scroller: Scroller = new Scroller();

  resizeImage(): void {
    this.imageHeightExtension = this.imageWidth * this.imageRatio;
    this.imageHeightFold = Math.min(380, this.imageHeightExtension);
    if (this.ifPictureExpansion) {
      this.imageHeight = this.imageHeightExtension;
    } else {
      this.imageHeight = this.imageHeightFold;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            Image($r('app.media.merchandiseMap'))
              .width(CommonConstants.FULL_PERCENT)
              .height(this.imageHeight)
              .objectFit(ImageFit.Cover)
              .animation({
                duration: 250,
                curve: Curve.EaseOut,
                iterations: 1,
                playMode: PlayMode.Normal
              })
              .onComplete((msg) => {
                this.imageRatio = msg!.height / msg!.width
              })
              .onAreaChange((oldArea: Area, newArea: Area) => {
                this.imageWidth = Number.parseInt(JSON.stringify(newArea.width));
                if (this.ifPictureExpansion === false) {
                  this.imageHeight = this.imageHeightFold;
                } else {
                  this.imageHeight = this.imageHeightExtension;
                }
              })
            Column() {
              Text('this.ratio' + this.imageRatio)
              Text('this.imageWidth' + this.imageWidth)
              Text('this.imageHeightFold' + this.imageHeightFold)
              Text('this.imageHeightExtension' + this.imageHeightExtension)
              Text('this.ifPictureExpansion' + this.ifPictureExpansion)
            }
            .height($r('app.float.details_height'))
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor(Color.Gray)
          }
        }
        .onScrollFrameBegin((offset: number) => {
          if (!this.ifPictureExpansion && offset < 0) {
            this.imageHeight = this.imageHeightExtension;
            this.ifPictureExpansion = true;
            return { offsetRemain: 0 };
          } else if (this.ifPictureExpansion && offset > 0) {
            this.imageHeight = this.imageHeightFold;
            this.ifPictureExpansion = false;
            return { offsetRemain: 0 };
          } else {
            return { offsetRemain: offset };
          }
        })

        Image($r('app.media.icon_back'))
          .width($r('app.float.common_image'))
          .aspectRatio(1)
        Row() {
          Column() {
            Text($r('app.string.detail_text'))
            Text($r('app.string.delivery_fee'))
          }

          Blank()
          Text($r('app.string.send_from'))
        }
        .width(CommonConstants.NINETY_PERCENT)
        .height($r('app.float.send_height'))
        .backgroundColor('#232426')
        .borderRadius($r('app.float.send_radius'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
  }
}
