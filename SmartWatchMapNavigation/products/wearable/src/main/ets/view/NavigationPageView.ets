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

import { promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommunicationInformation, CommunicationUtils, RouteInfomation } from 'communication';
import { VibratorUtil } from 'vibrator';

@Builder
export function NavigationPageViewBuilder() {
  NavigationPageView()
}

const TAG: string = 'NavigationPageView';

@Component
struct NavigationPageView {
  // Signals for synchronizing the start and end of navigation on both sides of the phone and watch.
  @StorageLink('isStartNavigation') isStartNavigation: boolean = false;
  // Navigation route information
  @StorageLink('route_information') @Watch('getTurnImg') route_information: RouteInfomation =
    new RouteInfomation('', 0, 0);
  // [Start setWindowKeepScreenOn]
  // Window object obtained from EntryAbility, which is used to ensure that the screen is steady on during navigation.
  @StorageLink('windowClass') windowClass: window.Window | undefined = undefined;
  // [StartExclude setWindowKeepScreenOn]
  // Navigation display image
  @State turn_img: ResourceStr = '';
  // Navigation text information
  @State turn_information: ResourceStr = '';
  private pathStack: NavPathStack = new NavPathStack();
  private connectUtils: CommunicationUtils = new CommunicationUtils(this.getUIContext().getHostContext() as Context);
  private meter: string = '';
  private estimatedTime: string = '';
  private second: string = '';

  private getStringContext(id: number): string {
    let stringContext = '';
    try {
      stringContext = this.getUIContext().getHostContext()?.resourceManager.getStringSync(id) as string;
    } catch(error) {
      let err = error as BusinessError
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to get string context. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
    return stringContext;
  }
  // [EndExclude setWindowKeepScreenOn]

  aboutToAppear(): void {
    // [StartExclude setWindowKeepScreenOn]
    try {
      this.meter = this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.meter').id) as string;
    } catch (error) {
      let err = error as BusinessError;
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to get meter. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
    try {
      this.estimatedTime = this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.Estimated_Time').id) as string;
    } catch (error) {
      let err = error as BusinessError;
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to get estimated time. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
    try {
      this.second = this.getUIContext().getHostContext()?.resourceManager.getStringSync($r('app.string.Second').id) as string;
    } catch (error) {
      let err = error as BusinessError;
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to get second. Cause code: ${err.code}, message: ${err.message}`);
      }
    }

    this.connectUtils.getConnectedDevices();
    // [EndExclude setWindowKeepScreenOn]
    if (this.windowClass) {
      this.windowClass.setWindowKeepScreenOn(true, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, TAG,
            `Failed to set the screen to be always on. Cause code: ${err.code}, message: ${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in setting the screen to be always on.');
      });
    }
  }
  // [End setWindowKeepScreenOn]

  /*
   * Triggered after route_information is changed.
   * Modify turn_img and turn_information based on route_information and refresh the navigation page information.
   */
  getTurnImg(): void {
    if (this.route_information.action === 'turn-slight-right') {
      this.turn_img = $r('app.media.slight_right');
      this.turn_information =
        this.getStringContext($r('app.string.Right_front').id);
    } else if (this.route_information.action === 'turn-slight-left') {
      this.turn_img = $r('app.media.slight_left');
      this.turn_information = this.getStringContext($r('app.string.Left_front').id);
    } else if (this.route_information.action === 'turn-left') {
      this.turn_img = $r('app.media.left');
      this.turn_information = this.getStringContext($r('app.string.Left').id);
    } else if (this.route_information.action === 'turn-right') {
      this.turn_img = $r('app.media.right');
      this.turn_information = this.getStringContext($r('app.string.Right').id);
    } else if (this.route_information.action === 'end') {
      this.turn_information = this.getStringContext($r('app.string.End').id);
      let vibratorUtil: VibratorUtil = new VibratorUtil();
      vibratorUtil.Vibrator();
      promptAction.openToast({
        message: $r('app.string.End'),
        duration: 2000
      }).catch((error: Error) => {
        let err = error as BusinessError
        hilog.error(0x0000, TAG,
          `Failed to open toast. Cause code: ${err.code}, message: ${err.message}`);
        return;
      });
      setTimeout(() => {
        this.isStartNavigation = false;
        this.connectUtils.sendMessage(JSON.stringify(new CommunicationInformation(3, undefined, undefined)));
        this.pathStack.pop();
        if (this.windowClass) {
          this.windowClass.setWindowKeepScreenOn(false, (err: BusinessError) => {
            const errCode: number = err.code;
            if (errCode) {
              hilog.error(0x0000, TAG,
                `Failed to set the screen to be always on. Cause code: ${err.code}, message: ${err.message}`);
              return;
            }
            hilog.info(0x0000, TAG, 'Succeeded in setting the screen to be always on.');
          });
        }
      }, 2500)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Image(this.turn_img)
          .width(76)
          .margin({ bottom: 8 })
        Text(this.route_information.distance + this.meter + this.turn_information)
          .font({
            size: 19,
            weight: FontWeight.Medium
          })
          .margin({
            bottom: 2
          })
        Text(this.estimatedTime + this.route_information.duration + this.second)
          .font({
            size: 15,
            weight: FontWeight.Regular
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}