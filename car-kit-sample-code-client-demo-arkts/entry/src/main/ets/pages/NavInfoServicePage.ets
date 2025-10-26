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

import { navigationInfoMgr } from '@kit.CarKit';
import { promptAction } from '@kit.ArkUI';
import CommonUtils from '../common/CommonUtils';
import { Logger } from '../common/Logger';

const TAG = 'NavInfoServicePublicApiSample';

@CustomDialog
struct CustomDialogExample {
  @Link title: string | Resource;
  @Link message: string;
  controller?: CustomDialogController;
  uiContext: UIContext | undefined = undefined;

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
  }

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Scroll() {
      Column() {
        Text(this.title)
          .fontSize(CommonUtils.getCustomDialogTitleSize(this.uiContext))
          .fontWeight(700)
          .height(this.uiContext?.px2vp(196))
          .margin({ left: this.uiContext?.px2vp(84), right: this.uiContext?.px2vp(84), top: this.uiContext?.px2vp(42) })
          .textAlign(TextAlign.Center)
        Text(this.message)
          .fontSize(this.uiContext?.px2vp(56))
          .fontWeight(400)
          .textAlign(TextAlign.Start)
          .margin({ left: this.uiContext?.px2vp(84), right: this.uiContext?.px2vp(84), top: this.uiContext?.px2vp(28) })
          .width('90%')
        Button('OK', { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL })
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close();
            }
          })
          .stateEffect(false)
          .fontSize(this.uiContext?.px2vp(56))
          .fontWeight(500)
          .margin(this.uiContext?.px2vp(28))
      }
    }
  }
}

@Component
struct NavInfoServicePage {
  @State titleValue: string | Resource = '';
  @State messageValue: string = '';
  index: number = 0;
  state: boolean = false;
  uiContext: UIContext | undefined = undefined;

  // location0: Location
  location0: navigationInfoMgr.Location = {
    name: 'location0', // Address Name
    coordType: navigationInfoMgr.LocationCoordType.GCJ02, // Location coordinate coding type
    longitude: 29.53851890563965, // Longitude
    latitude: 16.50643920898438, // Latitude
    altitude: 3.00015949516846, // Altitude
  };
  // location1: Location
  location1: navigationInfoMgr.Location = {
    name: 'location1',
    coordType: navigationInfoMgr.LocationCoordType.WGS84,
    longitude: 4.4445874651238,
    latitude: 5.55565329843751,
    altitude: 6.66641578943265,
  };
  // navStatus0: NavigationStatus
  navStatus0: navigationInfoMgr.NavigationStatus = {
    status: navigationInfoMgr.MapStatus.CRUISE, // Map status
    naviType: navigationInfoMgr.NaviType.WALKING, // Navigation type
    // When status is MapStatus.NAVIGATION, this field indicates the destination address. When status is MapStatus.POI, this field indicates POI information.
    destLocation: this.location0,
    passPoint: [this.location1, this.location0], // Pass point
    routeIndex: 101, // Route index
    routePreference: [navigationInfoMgr.RoutePreference.MAIN_ROAD_FIRST,
      navigationInfoMgr.RoutePreference.TIME_FIRST], // Route preference
    theme: navigationInfoMgr.ThemeType.DARK, // Map theme color
    customData: 'navStatus0 test custom data 0' // Custom data
  };
  // navStatus1: NavigationStatus
  navStatus1: navigationInfoMgr.NavigationStatus = {
    status: navigationInfoMgr.MapStatus.ROUTE,
    naviType: navigationInfoMgr.NaviType.MOTORCYCLE,
    destLocation: this.location1,
    passPoint: [this.location0, this.location1],
    routeIndex: 202,
    routePreference: [navigationInfoMgr.RoutePreference.HIGHWAY_FIRST,
      navigationInfoMgr.RoutePreference.INTELLIGENT_RECOMMENDATION],
    theme: navigationInfoMgr.ThemeType.LIGHT,
    customData: 'navStatus1 test custom data 1'
  };

  @Builder
  customButton(text: string | Resource, clickCall: (() => void)) {
    Row() {
      Button(text)
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.ohos_dialog_text_alert_dark'))
        .fontWeight(500)
        .fontSize(CommonUtils.getCustomButtonFontSize(this.uiContext))
        .align(Alignment.Start)
        .type(ButtonType.Capsule)
        .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56), top: this.uiContext?.px2vp(42) })
        .height(this.uiContext?.px2vp(168))
        .type(ButtonType.Normal)
        .borderRadius(this.uiContext?.px2vp(56))
        .layoutWeight(1)
        .onClick(() => {
          clickCall?.();
        })
    }
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        Logger.info(TAG, 'Callback when the first button is clicked')
      },
      confirm: () => {
        Logger.info(TAG, 'Callback when the second button is clicked')
      },
      title: this.titleValue,
      message: this.messageValue,
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    backgroundColor: Color.White,
  });

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
  }

  aboutToDisappear() {
    this.dialogController = null;
  }

  showAlertDialog(title: string | Resource, message: string) {
    this.titleValue = title;
    this.messageValue = message;
    if (this.dialogController != null) {
      this.dialogController.open();
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.customButton($r('app.string.update_navigation_status_1'), () => {
            this.updateNavStatusMsg(this.navStatus0);
          });

          this.customButton($r('app.string.update_navigation_status_2'), () => {
            this.updateNavStatusMsg(this.navStatus1);
          });

          this.customButton($r('app.string.register_system_signal_listener'), () => {
            this.registerSystemListener();
          });

          this.customButton($r('app.string.unregister_system_signal_listener'), () => {
            this.unregisterSystemListener();
          });

          this.customButton($r('app.string.update_navigation_metadata'), () => {
            this.sendNavigationMetaDataCmd();
          });
        }
      }
      .align(Alignment.TopStart)
      .height('100%')
      .width('100%')
    }
    .title(CommonUtils.resourceToString($r('app.string.navigation_information_interaction_examples'), this.uiContext))
    .backgroundColor($r('app.color.start_window_background'))
  }

  updateNavStatusMsg(status: navigationInfoMgr.NavigationStatus) {
    try {
      // Get single instance of NavigationController.
      let controller: navigationInfoMgr.NavigationController = navigationInfoMgr.getNavigationController();
      // Set navigation status, including the navigation type, navigation destination, navigation passpoint, and route.
      controller.updateNavigationStatus(status);
      this.showAlertDialog($r('app.string.update_navigation_status_1'), CommonUtils.getNavStatusString(status));
    } catch (err) {
      Logger.error(TAG, `updateNavStatusMsg error ${err.code}`);
    }
  }

  registerSystemListener() {
    try {
      // Get single instance of NavigationController.
      let controller: navigationInfoMgr.NavigationController = navigationInfoMgr.getNavigationController();
      let that = this;
      // System navigation event listener
      let listenerImpl: navigationInfoMgr.SystemNavigationListener = {
        // Listening to system query events
        onQueryNavigationInfo(query: navigationInfoMgr.QueryType,
          args: Record<string, object>): Promise<navigationInfoMgr.ResultData> {
          promptAction.openToast({ message: `queryType: [${query}]` })
            .catch(() => {
              Logger.error(TAG, 'query type open toast error');
          });
          return new Promise(resolve => {
            let data: navigationInfoMgr.ResultData = {
              code: 1111,
              message: `get queryType success. queryType: [${query}]`,
              data: {}
            }
            resolve(data);
          })
        },

        // Listening to system command events.
        onReceiveNavigationCmd(command: navigationInfoMgr.CommandType,
          args: Record<string, object>): Promise<navigationInfoMgr.ResultData> {
          that.showAlertDialog($r('app.string.register_system_signal_listener'),
            CommonUtils.handleCmdReceived(command, args));
          return new Promise(resolve => {
            let data: navigationInfoMgr.ResultData = {
              code: 2222,
              message: `get commandType success. commandType: [${command}]`,
              data: {}
            }
            resolve(data);
          })
        }
      };
      // Registers and listens to system navigation information and instructions. This method is invoked when the map application is started.
      controller.registerSystemNavigationListener(listenerImpl);
      promptAction.openToast({ message: $r('app.string.register_system_signal_listener') })
        .catch(() => {
          Logger.error(TAG, 'open toast error');
      });
    } catch (err) {
      Logger.error(TAG, `registerSystemListener error ${err.code}`);
    }
  }

  unregisterSystemListener() {
    try {
      // Get single instance of NavigationController.
      let controller: navigationInfoMgr.NavigationController = navigationInfoMgr.getNavigationController();
      // Unregister the monitoring system navigation information and instructions.
      controller.unregisterSystemNavigationListener();
      promptAction.openToast({ message: $r('app.string.unregister_system_signal_listener') })
        .catch(() => {
          Logger.error(TAG, 'open toast error');
      });
    } catch (err) {
      Logger.info(TAG, `unregisterSystemListener error ${err.code}`);
    }
  }

  // Update navigation metadata
  async sendNavigationMetaDataCmd(): Promise<void> {
    try {
      // Get single instance of NavigationController.
      let navigationController: navigationInfoMgr.NavigationController = navigationInfoMgr.getNavigationController();
      // Navigation metadata.
      let data: navigationInfoMgr.NavigationMetadata = {
        naviTurnMode: this.index,
        segmentLeftDis: this.index,
        currentRoadName: 'currentRoadName' + this.index,
        nextRoadName: 'nextRoadName' + this.index,
        intersectionView: 'intersectionView' + this.index,
        viewWidth: this.index,
        viewHeight: this.index,
        trafficLane: 'trafficLane' + this.index,
        cameraSpeedLimitValid: this.state,
        cameraSpeedLimit: this.index,
        naviSpeedLimitValid: this.state,
        naviSpeedLimit: this.index,
        currentSpeed: this.index,
        naviBearing: this.index,
        totalLeftDis: this.index,
        remainingTime: this.index,
        customData: { 'sample': 'sampleData' },
      };
      Logger.info(TAG, `updateNavigationMetadata ${JSON.stringify(data)}`);
      this.showAlertDialog($r('app.string.update_navigation_metadata'), CommonUtils.getNavMetadataString(data));
      // Set navigation metadata, including TBT information, roads, and electronic eyes.
      navigationController.updateNavigationMetadata(data);
      this.index += 2;
      this.state = !this.state;
    } catch (err) {
      Logger.error(TAG, `sendNavigationMetaDataCmd error ${err.code}`);
    }
  }
}

@Builder
export function NavInfoServicePageBuilder() {
  NavInfoServicePage();
}