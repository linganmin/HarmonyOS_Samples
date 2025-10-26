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
export struct NavigationContent1 {
  @ObjectLink mainWindowInfo: WindowInfo;
  isTripleView: boolean = false;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Row() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .margin({ right: 12 })
          .onClick(() => {
            this.pathStack.pop();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

       Column() {
        Text('Navigation')
          .fontSize(18)
          .margin({ bottom: 12 })
        Text($r('app.string.navigation_content_home'))
          .fontSize(24)
          .margin({ bottom: 12 })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
      left: 12,
      right: 12
    })
    .hideTitleBar(true)
    .backgroundColor('#FDBFFC')
  }
}

@Component
export struct NavigationContent2 {
  @ObjectLink mainWindowInfo: WindowInfo;
  @State isShow: boolean = false;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .position({
            x: 0,
            y: 0
          })
          .onClick(() => {
            this.pathStack.pop();
          })
        Text('Navigation')
          .fontSize(18)
          .margin({ bottom: 12 })
        Text($r('app.string.navigation_content_home'))
          .fontSize(24)
          .onClick(() => {
            this.isShow = true;
          })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({
        top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
        bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
        left: 16,
        right: 16
      })
    }
    .width('100%')
    .height('100%')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .hideTitleBar(true)
    .backgroundColor('#FDBFFC')
  }
}