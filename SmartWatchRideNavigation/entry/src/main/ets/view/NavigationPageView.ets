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
import { ArcButton, ArcButtonOptions } from "@ohos.arkui.advanced.ArcButton";
import { ArcButtonPosition, ArcButtonStyleMode, LengthMetrics, LengthUnit } from "@kit.ArkUI";

@Builder
export function navigationPageBuilder() {
  NavigationPageView()
}

@Component
struct NavigationPageView {
  pathStack: NavPathStack = new NavPathStack();
  bottomOptions: ArcButtonOptions = new ArcButtonOptions({});

  aboutToAppear(): void {
    this.bottomOptions = new ArcButtonOptions({
      label: $r('app.string.stop_navigation'),
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      position: ArcButtonPosition.BOTTOM_EDGE,
      fontSize: new LengthMetrics(12, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => {
        this.pathStack.replacePathByName('SearchPage', null);
      }
    })
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.ride_navigation'))
          .font({
            size: 19,
            weight: 700
          })
          .fontColor($r('sys.color.white'))
          .margin({ top: 17 })

        Image($r('app.media.navigation'))
          .width(68)
          .margin({ top: 12 })

        Text($r('app.string.navigation_message_one'))
          .font({
            size: 15,
            weight: 500
          })
          .fontColor(Color.White)
          .margin({ top: 4 })

        Text($r('app.string.navigation_message_two'))
          .font({
            size: 15,
            weight: 500
          })
          .fontColor(Color.White)

        Blank()

        ArcButton({ options: this.bottomOptions })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .hideToolBar(true)
    .height('100%')
    .width('100%')
    .borderRadius('50%')
  }
}