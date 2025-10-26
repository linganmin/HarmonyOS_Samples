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
import { LocationInfo } from '../model/LocationInfo';

@Builder
export function resultsPageBuilder() {
  ResultsPageView()
}

@Component
struct ResultsPageView {
  @State currentIndex: number = 0;
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  locationBuilder(item: LocationInfo) {
    Column() {
      Row() {
        Image($r('app.media.location'))
          .width(20)
        Text(item.location)
          .margin({ left: 6 })
          .fontSize(20)
          .fontWeight(500)
          .fontColor($r('sys.color.white'))
      }

      Text(item.address)
        .fontSize(16)
        .fontWeight(400)
        .fontColor('#A8FFFFFF')
    }
    .onClick(() => {
      this.pathStack.pushPathByName('RoutePage', null);
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.result'))
          .font({
            size: 19,
            weight: 700
          })
          .fontColor($r('sys.color.white'))
          .margin({ top: 17 })
        List() {
          ForEach(CommonConstants.RESULT, (item: LocationInfo) => {
            ListItem() {
              this.locationBuilder(item);
            }
            .width('80%')
            .height(56)
            .margin({ bottom: 8 })
            .backgroundColor('#26FFFFFF')
            .borderRadius(32)
          }, (item: LocationInfo) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .height(120)
        .margin({ top: 35 })
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
    .backgroundColor(Color.Black)
    .borderRadius('50%')
  }
}