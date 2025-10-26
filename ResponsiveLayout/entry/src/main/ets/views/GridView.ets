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

import { JSON } from '@kit.ArkTS';
import { WidthBreakpointType } from '../utils/WidthBreakpointType';
import { WindowInfo } from '../utils/WindowUtil';

@Component
export struct GridView {
  @ObjectLink mainWindowInfo: WindowInfo;
  pageInfos: NavPathStack = new NavPathStack();
  infoArray: number[] = [0, 1, 2, 3, 4, 5, 6, 7];
  listScroller: ListScroller = new ListScroller();

  build() {
    Scroll() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_public_back'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.pageInfos.pop();
              })
          }
          .height(40)
          .width(40)
          .borderRadius(40)
          .backgroundColor('#0D000000')
          .justifyContent(FlexAlign.Center)
          .margin({ right: 12 })
          Text($r('app.string.grid'))
            .fontSize(24)
        }
        .width('100%')
        .margin({ bottom: 12 })

        // [Start grid_view]
        Grid() {
          ForEach(this.infoArray.slice(new WidthBreakpointType(4, 2, 0).getValue(this.mainWindowInfo.widthBp)),
            (item: number) => {
              // [StartExclude grid_view]
              GridItem() {
                Row() {}
                .width('100%')
                .aspectRatio(1.8)
                .borderRadius(16)
                .backgroundColor('#F1F3F5')
              }
              // [EndExclude grid_view]
            }, (item: number, index: number) => JSON.stringify(item) + index)
        }
        .width('100%')
        .columnsTemplate(`repeat(${new WidthBreakpointType(2, 3, 4).getValue(this.mainWindowInfo.widthBp)}, 1fr)`)
        .columnsGap(12)
        .rowsGap(12)
        // [End grid_view]
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
      left: 16,
      right: 16
    })
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}