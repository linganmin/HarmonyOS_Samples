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
import { curves } from '@kit.ArkUI';
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct FullScreen {
  private positionY: number = 0;
  @State translateY: string | number = '110%';

  build() {
    Stack() {
      Navigation() {
        Column() {
          Button($r('app.string.full_screen'))
            .onClick(() => {
              this.getUIContext().animateTo({
                duration: CommonConstants.DURATION,
                curve: Curve.Sharp
              }, () => {
                this.translateY = '0%';
              });
            })
            .margin({ bottom: $r('app.float.card_padding') })
        }
        .height(CommonConstants.ONE_HUNDRED_PERCENT)
        .justifyContent(FlexAlign.End)
      }
      .title($r('app.string.full_screen'))
      .titleMode(NavigationTitleMode.Mini)

      RelativeContainer() {
        Image($r('sys.media.ohos_ic_public_arrow_down'))
          .fillColor($r('app.color.shadow_color'))
          .width($r('app.float.check_button_height'))
          .height($r('app.float.calendar_height'))
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({
            top: $r('app.float.check_button_height'),
            left: $r('app.float.corner_radius_default_m')
          })
          .onClick(() => {
            this.closeSelf();
          })
          .id('button')

        Row() {
        }
        .width($r('app.float.shadow_radius'))
        .height($r('app.float.row_padding'))
        .backgroundColor("#EAEDED")
        .borderRadius($r('app.float.text_margin'))
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .margin({ top: $r('app.float.row_height') })
        .offset({ x: $r('app.float.offset_x') })
        .id('title')

        Row() {
        }
        .width($r('app.float.bind_sheet_height'))
        .height($r('app.float.bind_sheet_height'))
        .clipShape(new Circle({ width: CommonConstants.GRID_HEIGHT_M, height: CommonConstants.GRID_HEIGHT_M }))
        .backgroundColor($r('app.color.shadow_color'))
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Center },
          left: { anchor: "__container__", align: HorizontalAlign.Center },
        })
        .offset({ x: $r('app.float.offset_x_l'), y: $r('app.float.offset_y') })
        .id('main')

        Row() {
        }
        .width($r('app.float.width_l'))
        .height($r('app.float.text_margin'))
        .backgroundColor($r('app.color.shadow_color'))
        .borderRadius($r('app.float.border_radius5'))
        .alignRules({
          top: { anchor: "main", align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ top: $r('app.float.text_margin') })
        .offset({ x: $r('app.float.offset_x_m'), y: $r('app.float.offset_y_l') })
        .id('slider')

        Image($r('sys.media.ohos_ic_public_play'))
          .fillColor($r('app.color.shadow_color'))
          .width($r('app.float.row_height'))
          .height($r('app.float.row_height'))
          .alignRules({
            top: { anchor: "slider", align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .offset({ x: $r('app.float.column_margin'), y: $r('app.float.offset_x') })
          .id('play')

        Image($r('sys.media.ohos_ic_public_play_next'))
          .fillColor($r('app.color.shadow_color'))
          .width($r('app.float.row_height'))
          .height($r('app.float.row_height'))
          .alignRules({
            top: { anchor: "slider", align: VerticalAlign.Bottom },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .offset({ x: $r('app.float.offset_20'), y: $r('app.float.offset_x') })
          .id('playNext')

        Image($r('sys.media.ohos_ic_public_play_last'))
          .fillColor($r('app.color.shadow_color'))
          .width($r('app.float.row_height'))
          .height($r('app.float.row_height'))
          .alignRules({
            top: { anchor: "slider", align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .offset({ x: $r('app.float.train_image_size'), y: $r('app.float.offset_x') })
          .id('playPrev')

      }
      .linearGradient({
        colors: [
          [$r('app.color.color_linear1'), CommonConstants.ZERO_ZERO],
          [$r('app.color.color_linear2'), CommonConstants.ZERO_Three],
          [$r('app.color.color_linear3'), CommonConstants.ONE_ZERO]
        ]
      })
      .borderRadius({
        topLeft: $r('app.float.column_padding'),
        topRight: $r('app.float.column_padding')
      })
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
      .translate({ x: CommonConstants.ZERO, y: this.translateY })
      .gesture(
        PanGesture({ direction: PanDirection.Vertical, distance: CommonConstants.JANUARY })
          .onActionUpdate((event?: GestureEvent) => {
            this.handlePanGestureUpdate(event?.offsetY);
          })
          .onActionEnd((event?: GestureEvent) => {
            this.handlePanGestureEnd(event?.offsetY);
          })
      )
    }
  }

  private closeSelf() {
    this.getUIContext().animateTo({
      duration: CommonConstants.GRID_HEIGHT_M,
      curve: Curve.Sharp,
    }, () => {
      this.translateY = '110%';
    });
  }

  private reset() {
    this.getUIContext().animateTo({
      curve: curves.responsiveSpringMotion()
    }, () => {
      this.translateY = '0%';
      this.positionY = 0;
    });
  }

  handlePanGestureUpdate(offsetY?: number): void {
    if (!offsetY || offsetY < 0) {
      return;
    }
    this.getUIContext().animateTo({
      curve: curves.responsiveSpringMotion()
    }, () => {
      this.translateY = this.positionY + offsetY;
    });
  }

  handlePanGestureEnd(offsetY?: number): void {
    if (!offsetY) {
      return;
    }
    if (offsetY > 300) {
      this.closeSelf();
    } else {
      this.reset();
    }
  }
}