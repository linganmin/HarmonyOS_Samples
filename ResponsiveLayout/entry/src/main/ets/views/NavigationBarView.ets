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

import { WindowInfo } from '../utils/WindowUtil';

@Component
export struct NavigationBarView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @Link isShowingSidebar: boolean;
  isTriView: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    if (this.mainWindowInfo.widthBp !== WidthBreakpoint.WIDTH_SM) {
      this.pathStack.pushPathByName('navigationContent1', null);
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.open_sidebar'))
          .width(40)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.isShowingSidebar = !this.isShowingSidebar;
          })
          .visibility(!this.isShowingSidebar && this.isTriView ? Visibility.Visible : Visibility.None)
        Image($r('app.media.ic_public_back'))
          .width(40)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.pageInfos.pop();
          })
        Text(this.isTriView ? $r('app.string.triple_column') : $r('app.string.double_column'))
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        Text('Navigation')
          .fontSize(18)
          .margin({ bottom: 12 })
        Text($r('app.string.navigation_bar'))
          .fontSize(24)
          .margin({ bottom: 12 })
        Button($r('app.string.jump_content_home'))
          .fontSize(12)
          .width(150)
          .margin({ bottom: 12 })
          .onClick(() => {
            this.pathStack.pushPathByName('navigationContent1', null);
          })
        Button($r('app.string.jump_content_detail'))
          .fontSize(12)
          .width(150)
          .onClick(() => {
            this.pathStack.pushPathByName('navigationContent2', null);
          })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
      left: 16,
      right: 16
    })
  }
}