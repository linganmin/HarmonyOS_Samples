/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { Shopping, ProductDetail, FaqList, ShoppingFullScreen } from 'shopping';
import { Route, ROUTES } from '../constants/Constants';
import { VideoPlayer } from './VideoPlayer';
import { MiniGame } from './MiniGame';
import { MusicPlayer } from './MusicPlayer';

@Entry
@Component
struct Index {
  @Provide navPageInfos: NavPathStack = new NavPathStack();

  go(to: string | undefined) {
    if (!to) {
      return;
    }
    this.navPageInfos.pushPath({ name: to });
  }

  @Builder
  NavPageMap(name: string) {
    if (name === 'Shopping') {
      Shopping();
    } else if (name === 'ProductDetail') {
      ProductDetail();
    } else if (name === 'FaqList') {
      FaqList();
    } else if (name === 'VideoPlayer') {
      VideoPlayer();
    } else if (name === 'MiniGame') {
      MiniGame();
    } else if (name === 'MusicPlayer') {
      MusicPlayer();
    } else if (name === 'ShoppingFullScreen') {
      ShoppingFullScreen()
    }
  }

  build() {
    Navigation(this.navPageInfos) {
      Column() {
        Text($r('app.string.title'))
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .fontColor('#E6000000')
          .width('100%')
          .height(140)
        ForEach(ROUTES, (route: Route) => {
          Text(route.title)
            .width('100%')
            .fontColor('#99000000')
            .fontSize(18)
          Column() {
            ForEach(route.children || [], (routeItem: Route, index) => {
              if (index !== 0) {
                Divider()
                  .color('#0D000000')
                  .strokeWidth(0.5)
              }
              Row() {
                Text(routeItem.title)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                Image($r('app.media.arrow_right'))
                  .width(24)
                  .height(24)

              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .onClick(() => this.go(routeItem.to))
            }, (routerItem: Route) => JSON.stringify(routerItem))
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .margin({ top: 16, bottom: 28 })
          .padding({ left: 12, right: 12 })
        }, (route: Route) => JSON.stringify(route))
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
      .padding(16)
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.NavPageMap)
  }
}