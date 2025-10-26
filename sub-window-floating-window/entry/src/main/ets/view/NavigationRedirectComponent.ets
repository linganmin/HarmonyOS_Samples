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

import { window } from '@kit.ArkUI';
import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';

@Component
export struct NavigationRedirectComponent {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State picPath: string = 'app.media.pic1';
  @State count: number = 1;
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  navId: string = '';

  build() {
    NavDestination() {
      Row() {
        Text($r('app.string.navigation_jump'))
          .fontSize($r('sys.float.ohos_id_text_size_body3'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .height(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Bottom)
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.windowStage.createSubWindow('NavigationRedirectPage', (err, windowClass) => {
        if (err.code > 0) {
          Logger.error('failed to create subWindow Cause:' + err.message);
          return;
        }
        try {
          windowClass.setUIContent('pages/NavigationRedirectPage',()=>{
            windowClass.setWindowBackgroundColor('#00000000');
          });
          windowClass.moveWindowTo(CommonConstants.DEFAULT_WINDOW_X, CommonConstants.DEFAULT_WINDOW_Y);
          windowClass.resize(this.getUIContext().vp2px(CommonConstants.DEFAULT_WINDOW_SIZE),
            this.getUIContext().vp2px(CommonConstants.DEFAULT_WINDOW_SIZE));
          windowClass.setWindowTouchable(true);
          windowClass.showWindow();
          windowClass.setWindowLayoutFullScreen(true);
        } catch (err) {
          Logger.error('failed to create subWindow Cause:' + err);
        }
      })
    })
    .onHidden(()=>{
      window.findWindow('NavigationRedirectPage').destroyWindow();
    })
  }
}