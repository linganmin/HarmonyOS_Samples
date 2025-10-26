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
import { PipWindowComponent } from '../view/PipWindowComponent';
import { ResizeWindowComponent } from '../view/ResizeWindowComponent';
import { MiniWindowComponent } from '../view/MiniWindowComponent';
import { NavigationRedirectComponent } from '../view/NavigationRedirectComponent';
import { SubWindowComponentRouter } from '../view/SubWindowComponentRouter';
import CommonConstants from '../constants/CommonConstants';

@Entry
@Component
struct Index {
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('screenWidth') screenWidth: number = 0;
  @StorageLink('screenHeight') screenHeight: number = 0;
  private navId: string = 'navId';

  onPageShow(): void {
    AppStorage.setOrCreate('pageInfos', this.pageInfos);
  }

  @Builder
  PageMap(name: string) {
    if (name === 'PipWindowComponent') {
      PipWindowComponent({ navId: this.navId })
    } else if (name === 'ResizeWindowComponent') {
      ResizeWindowComponent({ navId: this.navId })
    } else if (name === 'MiniWindowComponent') {
      MiniWindowComponent({ navId: this.navId })
    } else if (name === 'NavigationRedirectComponent') {
      NavigationRedirectComponent({ navId: this.navId })
    } else if (name === 'subWindowRouter') {
      SubWindowComponentRouter({ navId: this.navId })
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column({space: CommonConstants.COLUMN_DEFAULT_SPACE}) {
        Button($r('app.string.floating_window'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'subWindowRouter' });
          })

        Button($r('app.string.small_video_window'))
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('app.float.common_button_font'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'PipWindowComponent' });
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        left: $r('app.float.common_lr_padding'),
        right: $r('app.float.common_lr_padding'),
        bottom: $r('app.float.common_lr_padding')
      })
    }
    .hideTitleBar(true)
    .hideBackButton(false)
    .hideToolBar(true)
    .navDestination(this.PageMap)
    .id(this.navId)
    .onAreaChange((oldValue: Area, newArea: Area) => {
      this.screenWidth = newArea.width as number;
      this.screenHeight = newArea.height as number;
    })
  }
}