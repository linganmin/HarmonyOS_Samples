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
export struct IndentedView {
  @ObjectLink mainWindowInfo: WindowInfo;
  infoArray: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  listScroller: ListScroller = new ListScroller();
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(40)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.pathStack.pop();
          })
        Text($r('app.string.indented_layout'))
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // [Start indented_view]
      GridRow({
        columns: { xs: 4, sm: 4, md: 8, lg: 12, xl: 12 },
        gutter: 0,
        breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp']},
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: { xs: 4, sm: 4, md: 6, lg: 8, xl: 8 },
          offset: { xs: 0, sm: 0, md: 1, lg: 2, xl: 2 }
        }) {
          // [StartExclude indented_view]
          List({
            space: 12,
            scroller: this.listScroller
          }) {
            ForEach(this.infoArray, (item: number, index: number) => {
              ListItem() {
                Row() {
                }
                .width('100%')
                .height(60)
                .borderRadius(16)
                .backgroundColor('#F1F3F5')
              }
              .margin({
                bottom: index === this.infoArray.length - 1 ?
                this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height) : 0
              })
            }, (item: number, index: number) => JSON.stringify(item) + index)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          // [EndExclude indented_view]
        }
        .width('100%')
        .height('100%')
      }
      // [End indented_view]
      .width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      left: 16,
      right: 16
    })
  }
}