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

import { uiObserver } from '@kit.ArkUI';
import Constants from '../commom/Constants';
import BrightnessUtil from '../util/BrightnessUtil';
import { Callback } from '@kit.BasicServicesKit';

export default class BrightnessViewModel {
  // [Start navDestination_updateCallBack]
  // Switch and listen to the routing page, and set the brightness of the cached page.
  private navDestinationUpdateCallBack: Callback<NavDestinationInfo> = (info: NavDestinationInfo): void => {
    switch (info.state) {
      case uiObserver.NavDestinationState.ON_SHOWN:
        BrightnessUtil.setBrightness(info.name as string, Constants.SET_BRIGHTNESS_CLICK);
        BrightnessUtil.setStateBarContentColor(info.name as string, '#FFFFFF');
        break;
      case uiObserver.NavDestinationState.ON_HIDDEN:
      case uiObserver.NavDestinationState.ON_BACKPRESS:
        BrightnessUtil.setBrightness(Constants.NAV_DESTINATION_DEFAULT, Constants.SET_BRIGHTNESS_CLICK);
        BrightnessUtil.setStateBarContentColor(info.name as string, '#000000');
        break;
      default:
        break;
    }
  };

  public registerNavigationListener(): void {
    uiObserver.on('navDestinationUpdate', this.navDestinationUpdateCallBack);
  }

  public unRegisterNavigationListener(): void {
    uiObserver.off('navDestinationUpdate', this.navDestinationUpdateCallBack);
  }
  // [End navDestination_updateCallBack]

  public updateVideoBrightness(brightness: number): void {
    BrightnessUtil.updateVideoBrightness(brightness);
  }

  public setWindowKeepScreenState(isKeepOn: boolean): void {
    BrightnessUtil.setWindowKeepScreenState(isKeepOn);
  }
}