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

import { router, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';

@Entry
@Component
struct RouterRedirect {
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;

  onPageShow(): void {
    this.windowStage.createSubWindow('RouterRedirectPage', (err, windowClass) => {
      if (err.code > 0) {
        Logger.error('failed to create subWindow Cause:' + err.message);
        return;
      }
      try {
        windowClass.setUIContent('pages/RouterRedirectPage',()=>{
          windowClass.setWindowBackgroundColor('#00000000');
        });
        windowClass.moveWindowTo(CommonConstants.DEFAULT_WINDOW_X, CommonConstants.DEFAULT_WINDOW_Y);
        windowClass.resize(this.getUIContext().vp2px(CommonConstants.DEFAULT_WINDOW_SIZE),
          this.getUIContext().vp2px(CommonConstants.DEFAULT_WINDOW_SIZE));
        windowClass.showWindow();
        windowClass.setWindowLayoutFullScreen(true);
      } catch (err) {
        Logger.error('failed to create subWindow Cause:' + err);
      }
    })
  }

  onPageHide(): void {
    try {
      if (window.findWindow('RouterRedirectPage').isWindowShowing()) {
        window.findWindow('RouterRedirectPage').destroyWindow().catch((error: BusinessError) => {
          Logger.error(`destroyWindow error, code is ${error.code}, message is ${error.message}`);
        });
      }
    } catch (err) {
      Logger.error('failed to create subWindow Cause:' + err);
    }
  }

  build() {
    Navigation() {
      Column() {
        Row() {
          Image($r('app.media.ic_public_back'))
            .width($r('app.float.back_image'))
            .height($r('app.float.back_image'))
            .margin({
              left: $r('app.float.common_margin'),
              top: $r('app.float.common_margin')
            })
            .onClick(() => {
              this.getUIContext().getRouter().back();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        Text($r('app.string.router_back'))
          .fontSize($r('sys.float.ohos_id_text_size_body3'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({
            bottom: $r('app.float.common_lr_padding')
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .hideBackButton(false)
    .hideToolBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}