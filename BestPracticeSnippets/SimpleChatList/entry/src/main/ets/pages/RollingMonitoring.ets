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

import { curves } from '@kit.ArkUI';

@Component
export struct RollingMonitoring {
  @State arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  private scroller: Scroller = new Scroller();
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    NavDestination() {
      // [Start Specify_Offset_Scrolling]
      Button('scroll 200')
        .height('5%')
        .onClick(() => {
          let curve = curves.interpolatingSpring(10, 1, 228, 30);
          const yOffset: number = this.scroller.currentOffset().yOffset;
          this.scroller.scrollTo({ xOffset: 0, yOffset: yOffset + 200, animation: { duration: 1000, curve: curve } })
        })
      // [End Specify_Offset_Scrolling]

      // [Start Partial_Refresh]
      Button('Partial_Refresh')
        .height('5%')
        .margin({ top: 8, bottom: 8 })
        .onClick(() => {
          this.arr[0] += 10;
        })
      // [End Partial_Refresh]

      List({ space: 20, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.arr, (item: number) => {
          ListItem() {
            Text('' + item)
              .width('100%')
              .height(100)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .borderRadius(16)
              .backgroundColor(0xDCDCDC)
          }
          .borderRadius(16)
          .backgroundColor(0xDCDCDC)
        }, (item: string) => item)
      }
      .scrollBar(BarState.Off)
      .friction(0.6)
      .contentEndOffset(60)
      // [Start Rolling_Monitoring]
      .onWillScroll(() => {
        // Trigger before scrolling component scrolling.
        console.info('currentOffset:' + this.scroller.currentOffset().yOffset)
      })
      .onDidScroll(() => {
        // Triggered when scrolling components scroll.
        console.info('currentOffset:' + this.scroller.currentOffset().yOffset)
      })
      // [End Rolling_Monitoring]
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}