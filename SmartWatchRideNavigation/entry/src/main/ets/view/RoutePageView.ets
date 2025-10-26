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

import { CommonConstants } from '../common/constants/CommonConstants';
import { RouteInformation } from '../model/RouteInfo';

@Builder
export function routePageViewBuilder() {
  RoutePageView()
}

@Component
struct RoutePageView {
  @State currentIndex: number = 0;
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  routeBuilder(item: RouteInformation) {
    Column() {
      Row() {
        Text(item.duration)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('sys.color.white'))
          .margin({ left: 5 })
        Text(item.distance)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('sys.color.white'))
      }

      Row() {
        Image($r('app.media.trafficLight'))
          .width(18)
        Text(item.trafficLightsNumber.toString())
          .fontSize(14)
          .fontWeight(400)
          .opacity(0.66)
          .margin({ left: 5 })
        Text(item.description)
          .fontSize(12)
          .fontWeight(400)
          .opacity(0.66)
          .margin({ left: 10 })
      }
    }
    .onClick(() => {
      this.pathStack.pushPathByName('NavigationPage', null);
    })
    .margin({ bottom: 8 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(50)
    .backgroundColor('#26FFFFFF')
    .borderRadius(32)
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.Ride'))
          .width(52)
          .margin({ top: 3 })
        Text($r('app.string.ride'))
          .fontSize(18)
          .fontWeight(700)
          .fontColor(Color.White)
          .margin({ top: 3 })
        List() {
          ForEach(CommonConstants.ROUTES, (item: RouteInformation) => {
            ListItem() {
              this.routeBuilder(item);
            }
            .width('80%')
          }, (item: RouteInformation) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .alignListItem(ListItemAlign.Center)
        .width('100%')
        .height(108)
        .margin({ top: 8 })
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

