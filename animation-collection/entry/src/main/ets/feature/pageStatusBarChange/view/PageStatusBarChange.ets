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
import { CommonConstants } from '../common/constants/CommonConstants';

@Component
export struct PageStatusBarChange {
  @State scrollOffset: number = 0;
  @State headOpacity: number = 0;
  @State isTop: Boolean = true;
  @State titleBackgroundColor: Resource = $r('app.color.start_window_background');
  private opacityDefaultValue: number = 1;
  private opacityComputeRadix: number = 35;
  private columnSpace: number = 15;
  private scroller: Scroller = new Scroller();

  @Builder
  contentsBuilder(name: Resource, img: Resource, top?: boolean) {
    Text(name)
      .fontColor(Color.Black)
      .fontSize($r('app.float.font_size_twenty'))
      .margin({
        top: top ? $r('app.float.top_interval_sixty') : 0,
        bottom: $r('app.float.bottom_interval_minus_five')
      })
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .textAlign(TextAlign.Center)
    Image(img)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.TWENTY_FIVE_PERCENT)
      .borderRadius($r('app.float.borderRadius_twelve'))
      .margin({ bottom: $r('app.float.top_interval_ten') })
  }

  build() {
    Stack() {
      Scroll(this.scroller) {
        Column({ space: this.columnSpace }) {
          Text($r('app.string.text_welcome'))
            .fontSize($r('app.float.font_size_twenty_two'))
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.float.top_interval_sixty') })
          Text($r('app.string.text_new_user_registration'))
            .fontSize($r('app.float.font_size_fourteen'))
            .margin({ top: $r('app.float.top_interval_minus_five') })
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .textAlign(TextAlign.Start)
          Button($r('app.string.text_load'), { type: ButtonType.Capsule })
            .margin({ top: $r('app.float.top_interval_twenty') })
            .fontSize($r('app.float.font_size_eighteen'))
            .height($r('app.float.width_and_height_forty'))
            .width($r('app.float.width_and_height_one_hundred_and_thirty'))
            .position({ y: $r('app.float.positionY') })
          this.contentsBuilder($r('app.string.text_shopping'), $r('app.media.shopping'), true)
          this.contentsBuilder($r('app.string.text_happy'), $r('app.media.happly'))
          this.contentsBuilder($r('app.string.text_relaxation'), $r('app.media.relaxation'))
        }
        .width(CommonConstants.NINETY_TWO_PERCENT)
      }
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_PERCENT)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onDidScroll(() => {
        this.scrollOffset = this.scroller.currentOffset().yOffset;
        if (this.scrollOffset <= this.opacityComputeRadix) {
          this.headOpacity = this.scrollOffset / this.opacityComputeRadix;
        } else {
          this.headOpacity = this.opacityDefaultValue;
        }
      })
      Header({
        headOpacity: this.headOpacity,
        titleBackgroundColor: $r('app.color.start_window_background'),
        isTop: false
      });
      Header({
        headOpacity: this.opacityDefaultValue,
        titleBackgroundColor: $r('app.color.transparent_color'),
        isTop: true
      });
    }
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
    .backgroundColor($r('app.color.mine_background'))
    .alignContent(Alignment.Top)
  }
}

@Component
struct Header {
  @Prop headOpacity: number;
  @Prop titleBackgroundColor: Resource;
  @Prop isTop: Boolean;
  private columnSpace: number = 15;
  private opacityTopValue: number = 0;
  private opacityUnTopValue: number = 1;

  build() {
    Row() {
      Row({ space: this.columnSpace }) {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.button_setting_configuration'))
            .width($r('app.float.width_and_height_thirty_five'))
            .height($r('app.float.width_and_height_thirty_five'))
        }
        .backgroundColor($r('app.color.transparent_color'))

        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.button_scan'))
            .width($r('app.float.width_and_height_thirty'))
            .height($r('app.float.width_and_height_thirty'))
        }
        .backgroundColor($r('app.color.transparent_color'))
      }
      .justifyContent(FlexAlign.Start)
      .margin({ left: $r('app.float.left_interval_value') })
      .width(CommonConstants.THIRTY_PERCENT)

      Text($r('app.string.text_mine'))
        .fontColor(Color.Black)
        .fontSize($r('app.float.font_size_twenty_two'))
        .opacity(this.isTop ? this.opacityTopValue : this.opacityUnTopValue)

      Row() {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.button_customer_service_line'))
            .width($r('app.float.width_and_height_thirty'))
            .height($r('app.float.width_and_height_thirty'))
        }
        .backgroundColor($r('app.color.transparent_color'))
      }
      .justifyContent(FlexAlign.End)
      .margin({ right: $r('app.float.right_interval_value') })
      .width(CommonConstants.THIRTY_PERCENT)
    }
    .opacity(this.headOpacity)
    .height($r('app.float.width_and_height_sixty'))
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor(this.titleBackgroundColor)
  }
}

@Builder
export function getPageStatusBarChange(name: string): void {
  if (name === 'PageStatusBarChange') {
    NavDestination() {
      PageStatusBarChange()
    }
  }
}

export const wrappedBuilderStatusBarChange: WrappedBuilder<[string, number]> = wrapBuilder(getPageStatusBarChange);