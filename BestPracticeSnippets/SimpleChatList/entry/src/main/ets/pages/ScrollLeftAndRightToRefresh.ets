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

@Component
export struct ScrollLeftAndRightToRefresh {
  @State isRefreshing: boolean = false;
  @State arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    NavDestination() {
      // [Start ScrollLeftAndRightToRefresh]
      Column() {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 10 }) {
            ForEach(this.arr, (item: number) => {
              ListItem() {
                Text('' + item)
                  .width(300)
                  .height(80)
                  .fontSize(16)
                  .textAlign(TextAlign.Center)
                  .borderRadius(16)
                  .backgroundColor(0xFFFFFF)
                  .translate({ x: (80 - 300) / 2 })
                  .rotate({
                    x: 0,
                    y: 0,
                    z: 1,
                    centerX: '50%',
                    centerY: '50%',
                    angle: 90
                  })
              }
              .width(80)
              .height(300)
            }, (item: string) => item)
          }
          .width(300)
          .height(300)
          .alignListItem(ListItemAlign.Center)
          .scrollBar(BarState.Off)
        }
        .onRefreshing(() => {
          setTimeout(() => {
            this.isRefreshing = false;
          }, 2000)
        })
        .backgroundColor(0xDCDCDC)
        .refreshOffset(64)
        .pullToRefresh(true)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .rotate({
        x: 0,
        y: 0,
        z: 1,
        centerX: '50%',
        centerY: '50%',
        angle: -90
      })

      // [End ScrollLeftAndRightToRefresh]
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}