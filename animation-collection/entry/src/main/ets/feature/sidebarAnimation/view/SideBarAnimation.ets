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

/**
 * Realize：
 * 1. Cancel the default button of the SideBarContainer component and implement the sidebar animation through the customized button and explicit animation.
 * 2. Associate the animation-related attributes with the display of the sidebar.
 */

import { resourceManager } from '@kit.LocalizationKit';
import { SideBarView } from './SideBarView';
import { SideBarContentView } from './SideBarContentView';
import { SideBarAnimationViewConstants } from '../constants/SideBarAnimationViewConstants';

@Component
export struct SideBarAnimation {
  @State isShowSideBar: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  sidebarType: SideBarContainerType = SideBarContainerType.Embed;
  deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE;

  aboutToAppear(): void {
    this.deviceType = this.getUIContext().getHostContext()!.resourceManager.getDeviceCapabilitySync().deviceType;
    if (this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
      this.sidebarType = SideBarContainerType.Overlay;
    }
  }

  build() {
    SideBarContainer(this.sidebarType) {
      /**
       * Here is a custom animation for Opacity. Note that because this solution uses explicit animation,
       * In addition, this.isShowSideBar is changed through explicit animation.
       * Therefore, related animation attributes must be associated with this.isShowSideBar.
       * For details about the animation implementation, see the switchTabBar method in SideBarContentView.
       */
      SideBarView()
        .opacity(this.isShowSideBar ? SideBarAnimationViewConstants.SIDEBAR_OPACITY_SHOW :
          SideBarAnimationViewConstants.SIDEBAR_OPACITY_HIDDEN)
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))

      SideBarContentView({ isShowSideBar: this.isShowSideBar, deviceType: this.deviceType })
        .width($r('app.string.full_size'))
    }
    .divider(null)
    .sideBarPosition(SideBarPosition.End)
    // Control the display of the sidebar through the showSideBar attribute to customize the animation effect.
    .showSideBar(this.isShowSideBar)
    // The default buttons of the SideBarContainer cannot be used to customize animation effects. Therefore, you need to hide the buttons and customize buttons to control animation effects.
    .showControlButton(SideBarAnimationViewConstants.SIDEBAR_IS_SHOW_BUTTON)
    .sideBarWidth(SideBarAnimationViewConstants.SIDEBAR_WIDTH)
    .maxSideBarWidth(this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE ?
      SideBarAnimationViewConstants.SIDEBAR_WIDTH : null)
    .minSideBarWidth(this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE ?
      SideBarAnimationViewConstants.SIDEBAR_WIDTH : null)
    .autoHide(SideBarAnimationViewConstants.SIDEBAR_IS_AUTO_HIDE)
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
    .padding($r('sys.float.ohos_id_card_margin_start'))
  }
}

// Create the WrappedBuilder object and construct the page during dynamic route jumping.
@Builder
function getSideBarAnimation(name: string) {
  if (name === SideBarAnimationViewConstants.SIDEBAR_ANIMATION) {
    NavDestination() {
      SideBarAnimation();
    }
  }
}

export const sideBarAnimationViewWrappedBuilder: WrappedBuilder<[string, number]> = wrapBuilder(getSideBarAnimation);