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

import { CustomRoutes, Route, ChildRoute } from '../common/CustomRoutes';
import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct Index {
  private routes: Route[] = CustomRoutes.ROUTES;
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  buildList() {
    ForEach(this.routes, (item: Route) => {
      Row() {
        Text(item.title)
          .width(CommonConstants.INDEX_CONTENT_WIDTH)
          .fontSize(18)
          .fontColor(Color.Black)
      }
      .height(20)

      Column() {
        ForEach(item.child, (itemChild: ChildRoute, index: number) => {
          Column() {
            Row() {
              Text(itemChild.text)
                .height(48)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 12 })
                .fontSize(16)
                .fontColor($r('app.color.black_E6'))
              Column().layoutWeight(1)

              Text(itemChild.title ?? '')
                .height(48)
                .textAlign(TextAlign.End)
                .fontWeight(FontWeight.Normal)
                .fontSize(14)
                .fontColor($r('app.color.black_99'))

              Image($r('app.media.chevron_right'))
                .width(24)
                .height(24)
                .margin({ right: 8 })
                .fillColor($r('app.color.black_33'))
            }
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Text(itemChild.description)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.gray_3'))
              .padding({
                left: 12,
                right: 12,
                bottom: (itemChild.description ?? '').length > 0 ? 10 : 0
              })
              .fontSize(12)

            Stack() {
              if (item.child.length - 1 !== index) {
                Row()
                  .backgroundColor($r('app.color.gray_6'))
                  .width(CommonConstants.DIVIDER_WIDTH)
                  .height(CommonConstants.DIVIDER_HEIGHT)
              }
            }
          }
          .onClick(() => {
            this.pathStack.pushPathByName(itemChild.to, null);
          })
          .width(CommonConstants.INDEX_CONTENT_WIDTH)
        }, (item: ChildRoute, index: number) => JSON.stringify(item) + index)
      }
      .margin({ top: 14, bottom: 18 })
      .borderRadius(18)
      .backgroundColor(Color.White)
    }, (item: Route, index: number) => JSON.stringify(item) + index)
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Row() {
          Text('组件复用使用示例')
            .fontWeight(FontWeight.Bold)
            .fontSize(30)
            .width('100%')
            .fontColor('#FF333333')
        }
        .width(CommonConstants.INDEX_CONTENT_WIDTH)
        .height(CommonConstants.INDEX_TITLE_HEIGHT)

        Scroll() {
          Column() {
            this.buildList()
          }
          .padding({ bottom: 200 })
        }
        .scrollBar(BarState.Off)
        .width(CommonConstants.Full_WIDTH)
        .scrollable(ScrollDirection.Vertical)
      }
      .alignItems(HorizontalAlign.Center)
    }
    .hideNavBar(false)
    .backgroundColor('#FFF5F5F5')
    .mode(NavigationMode.Stack)
    .width(CommonConstants.Full_WIDTH)
    .height(CommonConstants.Full_HIIGHT)
  }
}