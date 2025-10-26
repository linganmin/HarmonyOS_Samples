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

import { resourceManager } from '@kit.LocalizationKit';
import { SideBarAnimationViewConstants } from '../constants/SideBarAnimationViewConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Preview
@Component
export struct SideBarContentView {
  @Link isShowSideBar: boolean;
  @State sideBarBtnOffset: number = 0;
  deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE;

  switchTabBar() {
    // When the button is clicked, the explicit animation is used to control the display and hiding of the sidebar.
    // Because only this.isShowSideBar is changed, all related animations need to be associated with it.
    this.getUIContext()
      .animateTo({ duration: SideBarAnimationViewConstants.SIDEBAR_ANIMATION_DURATION, curve: Curve.Friction }, () => {
        this.isShowSideBar = !this.isShowSideBar;
        if (this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          if (this.isShowSideBar) {
            this.sideBarBtnOffset = -1 * SideBarAnimationViewConstants.SIDEBAR_WIDTH;
          } else {
            this.sideBarBtnOffset = 0;
          }
        }
      })
  }

  @Builder
  buildChatInfo() {
    Row() {
      Image(null)
        .width(SideBarAnimationViewConstants.HEAD_ICON_SIZE)
        .height(SideBarAnimationViewConstants.HEAD_ICON_SIZE)
        .borderRadius(SideBarAnimationViewConstants.HEAD_ICON_BORDER_RADIUS)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      Column() {
        Text(SideBarAnimationViewConstants.SENDER_INFO)
        Text(SideBarAnimationViewConstants.CASE_DESCRIPTION)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .padding($r('sys.float.ohos_id_card_margin_start'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
          .constraintSize({
            // The maximum width of the component is limited to avoid the component size exceeding the parent component
            maxWidth: SideBarAnimationViewConstants.MESSAGE_MAX_WIDTH
          })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: $r('sys.float.ohos_id_card_margin_start'),
      })
    }
    .width($r('app.string.full_size'))
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Text(SideBarAnimationViewConstants.GROUP_NAME)
            .fontSize($r('sys.float.ohos_id_text_size_headline8'))
            .fontWeight(SideBarAnimationViewConstants.GROUP_NAME_FONT_WEIGHT)
            .margin($r('sys.float.ohos_id_card_margin_start'))
          Divider()
          Column() {
            this.buildChatInfo()
          }
          .width($r('app.string.full_size'))
          .padding({ top: $r('sys.float.ohos_id_card_margin_start') })
        }
        .alignItems(HorizontalAlign.Start)
        .width($r('app.string.full_size'))

        Blank()
        if (this.deviceType !== resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          Stack() {
            TextArea()
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
              .height(SideBarAnimationViewConstants.INPUT_BOX_HEIGHT)
            Button(SideBarAnimationViewConstants.BTN_SEND_MSG)
              .onClick(() => {
                try {
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: SideBarAnimationViewConstants.NOT_IMPLEMENT_PROMPT });
                } catch (err) {
                  let error = err as BusinessError;
                  hilog.error(0x0000, 'SideBarContentView', `error code=${error.code}, message=${error.message}`);
                }
              })
              .margin($r('sys.float.ohos_id_card_margin_end'))
          }
          .align(Alignment.BottomEnd)
        }
      }
      .alignItems(HorizontalAlign.End)
      .width($r('app.string.full_size'))
      .height($r('app.string.full_size'))
      .padding({
        left: $r('sys.float.ohos_id_card_margin_start'),
        right: $r('sys.float.ohos_id_card_margin_start')
      })

      Image(this.isShowSideBar ? $r('sys.media.ohos_ic_public_arrow_right') : $r('sys.media.ohos_ic_public_arrow_left'))
        .autoResize(SideBarAnimationViewConstants.SIDEBAR_IS_BUTTON_AUTORESIZE)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.switchTabBar();
        })
        .height(SideBarAnimationViewConstants.SIDEBAR_BUTTON_HEIGHT)
        .width(SideBarAnimationViewConstants.SIDEBAR_BUTTON_WIDTH)
        .borderRadius({
          topLeft: SideBarAnimationViewConstants.SIDEBAR_BUTTON_RADIUS,
          bottomLeft: SideBarAnimationViewConstants.SIDEBAR_BUTTON_RADIUS
        })
        .offset({ x: this.sideBarBtnOffset })
        .responseRegion({
          // When the device type is phone, it is difficult for the edge to respond to the event. Therefore, the hot zone is extended here.
          x: SideBarAnimationViewConstants.BACK_BTN_X,
          y: SideBarAnimationViewConstants.BACK_BTN_Y,
          width: SideBarAnimationViewConstants.BACK_BTN_RESPONSE_WIDTH,
          height: SideBarAnimationViewConstants.BACK_BTN_RESPONSE_HEIGHT
        })
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .width($r('app.string.full_size'))
    .alignContent(Alignment.End)
  }
}