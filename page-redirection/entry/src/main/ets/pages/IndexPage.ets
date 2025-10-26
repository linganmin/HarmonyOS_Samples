/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import Logger from '../common/utils/Logger';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ArkTSFunModel } from '../model/ProductModel';

const TAG: string = '[IndexPage]';

@Entry
@Component
struct IndexPage {
  @State @Watch('updateStatus') webCanBack: boolean = false;
  @State webCanForward: boolean = false;
  @State controller: webview.WebviewController = new webview.WebviewController();
  @State statusBarHeight: number = 0;
  @State sliderBarHeight: number = 0;
  arkTSObj: ArkTSFunModel = {
    jumpOrderConfirm: (detailStr: string) => this.jumpOrderConfirm(detailStr)
  };

  aboutToAppear() {
    webview.WebviewController.setWebDebuggingAccess(true);
    window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, windowClass: window.Window) => {
      if (err && err.code) {
        Logger.error(TAG, `Failed to obtain the main window. Cause: code=${err.code}, message=${err.message}`);
        return;
      }
      Logger.info(TAG, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));

      // Realize the immersive effect.
      try {
        let type = window.AvoidAreaType.TYPE_SYSTEM;
        // Get status bar height.
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(type);
        let statusBarHeight = this.getUIContext().px2vp(area.topRect.height);
        let sliderBarHeight = this.getUIContext().px2vp(area.bottomRect.height);
        this.statusBarHeight = statusBarHeight;
        this.sliderBarHeight = sliderBarHeight;
        if (statusBarHeight > 0) {
          windowClass.setWindowLayoutFullScreen(true);
        }
      } catch (exception) {
        let error = exception as BusinessError;
        Logger.error(TAG,
          `Failed to set the system bar properties. Cause: code=${error.code}, message=${error.message}`);
      }
    });
  }

  onPageShow() {
    this.updateStatusBar(this.webCanBack);
  }

  onPageHide() {
    this.updateStatusBar(false);
  }

  updateStatus() {
    this.updateStatusBar(this.webCanBack);
  }

  onBackPress() {
    if (this.webCanBack) {
      try {
        this.controller.backward();
      } catch (exception) {
        let error = exception as BusinessError;
        Logger.error(TAG, `Failed to backward. Cause: code=${error.code}, message=${error.message}`);
      }
      return true;
    }
    return false;
  }

  updateStatusBar(isDarkMode?: boolean): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then((windowClass: window.Window) => {
      let systemBarProperties: window.SystemBarProperties = {
        statusBarColor: isDarkMode ? '#000000' : '#F1F3F5',
        statusBarContentColor: isDarkMode ? '#FFFFFF' : '#000000'
      };
      try {
        windowClass.setWindowSystemBarProperties(systemBarProperties);
      } catch (exception) {
        let error = exception as BusinessError;
        Logger.error(TAG,
          `Failed to set the system bar properties. Cause: code=${error.code}, message=${error.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `Failed to get window. Cause: code=${error.code}, message=${error.message}`);
    })
  }

  jumpOrderConfirm(detailStr: string): void {
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/OrderConfirmPage',
      params: { statusBarHeight: this.statusBarHeight, sliderBarHeight: this.sliderBarHeight, detailStr }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `Failed to push url. Cause: code=${error.code}, message=${error.message}`);
    })
  }

  build() {
    Column() {
      Web({ src: $rawfile('product_list.html'), controller: this.controller })
        .layoutWeight(1)
        .javaScriptProxy({
          object: this.arkTSObj,
          name: 'arkTSFunObj',
          methodList: ['jumpOrderConfirm'],
          controller: this.controller
        })
        .onConfirm(() => {
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.toast_msg'),
              duration: CommonConstants.TOAST_DURATION
            });
          } catch (exception) {
            let error = exception as BusinessError;
            Logger.error(TAG, `Failed to show toast. Cause: code=${error.code}, message=${error.message}`);
          }
          return false;
        })
        .onPageEnd(() => {
          try {
            this.webCanBack = this.controller.accessBackward();
            this.webCanForward = this.controller.accessForward();
          } catch (exception) {
            let error = exception as BusinessError;
            Logger.error(TAG,
              `Failed to access backward or forward. Cause: code=${error.code}, message=${error.message}`);
          }
        })

      Row() {
        Button() {
          Image(this.webCanBack ? $r('app.media.ic_back_on') : $r('app.media.ic_back_off'))
            .width($r('app.float.img_size'))
            .aspectRatio(1)
        }
        .width($r('app.float.btn_size'))
        .backgroundColor($r('app.color.common_bg'))
        .aspectRatio(1)
        .enabled(this.webCanBack)
        .onClick(() => {
          try {
            this.controller.backward();
          } catch (exception) {
            let error = exception as BusinessError;
            Logger.error(TAG, `Failed to backward. Cause: code=${error.code}, message=${error.message}`);
          }
        })

        Button() {
          Image(this.webCanForward ? $r('app.media.ic_next_on') : $r('app.media.ic_next_off'))
            .width($r('app.float.img_size'))
            .aspectRatio(1)
        }
        .width($r('app.float.btn_size'))
        .backgroundColor($r('app.color.common_bg'))
        .aspectRatio(1)
        .enabled(this.webCanForward)
        .onClick(() => {
          try {
            this.controller.backward();
          } catch (exception) {
            let error = exception as BusinessError;
            Logger.error(TAG, `Failed to backward. Cause: code=${error.code}, message=${error.message}`);
          }
        })

        Button() {
          Image($r('app.media.ic_home'))
            .width($r('app.float.img_size'))
            .aspectRatio(1)
        }
        .width($r('app.float.btn_size'))
        .backgroundColor($r('app.color.common_bg'))
        .aspectRatio(1)
        .onClick(() => {
          try {
            this.controller.backward();
          } catch (exception) {
            let error = exception as BusinessError;
            Logger.error(TAG, `Failed to backward. Cause: code=${error.code}, message=${error.message}`);
          }
        })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.navi_height'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.common_bg'))
    .padding({ top: this.statusBarHeight - 1, bottom: this.sliderBarHeight })
  }
}