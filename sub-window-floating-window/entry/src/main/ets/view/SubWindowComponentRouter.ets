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
import CommonConstants from '../constants/CommonConstants';

@Component
export struct SubWindowComponentRouter {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State picPath: string = 'app.media.pic1';
  @State count: number = 1;
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  navId: string = '';

  build() {
    NavDestination() {
      Column({ space: CommonConstants.COLUMN_DEFAULT_SPACE }) {
        Button($r('app.string.create_window_resize'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'ResizeWindowComponent' });
          })

        Button($r('app.string.show_sub_window'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'MiniWindowComponent' });
          })

        Button($r('app.string.sub_jump_pip'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'NavigationRedirectComponent' });
          })

        Button($r('app.string.router_jump_index'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/RouterRedirect'
            });
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        left: $r('app.float.common_lr_padding'),
        right: $r('app.float.common_lr_padding'),
        bottom: $r('app.float.common_lr_padding')
      })
    }
  }
}