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

import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../constants/CommonConstants';

/**
 * Top Title Back Button Component.
 */
@Component
export struct CommonIconButton {
  @Prop commonIcon: Resource;
  triggerMethod: () => void = () => {
  };

  build() {
    Row() {
      Row() {
        Image(this.commonIcon)
          .width($r('app.integer.icon_size'))
          .height($r('app.integer.icon_size'))
          .onClick(() => this.triggerMethod())
      }
      .width($r('app.integer.top_area_size'))
      .height($r('app.integer.top_area_size'))
      .backgroundColor($r('app.color.background_color4'))
      .borderRadius($r('app.integer.top_area_radius'))
      .justifyContent(FlexAlign.Center)

      Text($r('app.string.home_top_title'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.integer.comm_font_size20'))
        .margin({
          left: $r('app.integer.comm_margin_padding_size12')
        })
    }
    .padding({
      left: $r('app.integer.comm_margin_padding_size16')
    })
  }
}

/**
 * Title bar at the top of the map.
 */
@Component
export struct HomeTop {
  // Status bar height.
  @Link statusBarHeight: number;

  triggerMethod(): void {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.terminateSelf();
  }

  build() {
    Row() {
      CommonIconButton({
        commonIcon: $r('app.media.ic_public_arrow_left'),
        triggerMethod: this.triggerMethod
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.PAGE_HEADER_HEIGHT)
    .margin({
      top: this.statusBarHeight
    })
  }
}

/**
 * Image Map Layout Style.
 */
@Component
export struct ImageMapView {
  // X-axis position of the image in the parent component.
  @State imagePositionX: number = 0;
  // Y-axis position of the image in the parent component.
  @State imagePositionY: number = 0;
  // X-axis position of the image after the drag event ends.
  @State offsetX: number = 0;
  // Y-axis position of the image after the drag event ends.
  @State offsetY: number = 0;

  build() {
    Column() {
      // Background map image.
      Image($r("app.media.background_map"))
        .id('bg_img')
        .width($r('app.integer.background_map_size'))
        .height($r('app.integer.background_map_size'))
        .objectFit(ImageFit.Contain)
        .draggable(true)
        .translate({
          x: this.offsetX,
          y: this.offsetY
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .clip(true)
    .gesture(
      PanGesture({ direction: PanDirection.All, fingers: CommonConstants.PAN_GESTURE_FINGERS })
        .onActionUpdate((event: GestureEvent) => {
          this.offsetX = event.offsetX + this.imagePositionX;
          this.offsetY = event.offsetY + this.imagePositionY;
        })
        .onActionEnd(() => {
          this.imagePositionX = this.offsetX;
          this.imagePositionY = this.offsetY;
        })
    )
  }
}

/**
 * Title bar at the top of the list.
 */
@Component
export struct ItemHead {
  @Prop headerContent: Resource;

  build() {
    Column() {
      Row() {
        Text(this.headerContent)
          .fontSize($r('app.integer.comm_font_size14'))
          .fontColor($r('app.color.list_header_text_color'))
      }
      .shadow({
        radius: $r('app.integer.comm_border_radius10'),
        color: $r('app.color.list_header_shadow_color')
      })
      .height($r('app.integer.comm_height50'))
      .margin({ left: $r('app.integer.comm_margin_padding_size30') })
      .backgroundColor($r('app.color.list_header_background_color'))
      .borderRadius($r('app.integer.comm_border_radius10'))
      .padding({
        right: $r('app.integer.comm_margin_padding_size16'),
        left: $r('app.integer.comm_margin_padding_size16')
      })
    }
    .id('listHeader')
    .borderRadius($r('app.integer.comm_border_radius10'))
    .alignRules(CommonConstants.LIST_TITLE_ALIGN_RULES)
    .height(CommonConstants.LIST_HEADER_HEIGHT)
  }
}

/**
 * listItem Layout Style.
 */
@Component
export struct SettingItemView {
  // Avoidance Height of Bottom Navigation Bar.
  @Link bottomAvoidHeight: number;

  build() {
    Image($r('app.media.ic_comm_pic'))
      .draggable(false)
      .height($r('app.integer.comm_pic_height'))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.integer.comm_border_radius10'))
      .padding({
        top: $r('app.integer.comm_margin_padding_size6'),
        right: $r('app.integer.comm_margin_padding_size16'),
        bottom: $r('app.integer.comm_margin_padding_size6'),
        left: $r('app.integer.comm_margin_padding_size16')
      })
  }
}

/**
 * Customized title at the top of the page.
 */
@Component
export struct StatusHead {
  @Link statusBarHeight: number;
  @State topHeaderHeight: number = 0;
  @Link isShow: boolean;

  build() {
    Column() {
      Blank()
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
        .height(this.statusBarHeight)
      Row() {
        CommonIconButton({
          commonIcon: $r('app.media.ic_public_arrow_down')
        })
      }
      .backgroundColor(Color.White)
      .width(CommonConstants.FULL_PERCENT)
      .height(this.topHeaderHeight)
    }
    .visibility(this.isShow ? Visibility.Visible : Visibility.None)
    .animation({
      duration: CommonConstants.STATUS_HEAD_ANIMATION_DURATION,
      curve: Curve.Smooth,
      iterations: CommonConstants.ANIMATION_PLAY_TIMES,
      playMode: PlayMode.Normal
    })
  }
}