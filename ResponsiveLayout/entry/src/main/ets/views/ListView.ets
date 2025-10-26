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

import { WidthBreakpointType } from '../utils/WidthBreakpointType';
import { WindowInfo } from '../utils/WindowUtil';

@Component
export struct ListView {
  @ObjectLink mainWindowInfo: WindowInfo;
  pageInfos: NavPathStack = new NavPathStack();
  infoArray: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  listScroller: ListScroller = new ListScroller();

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(40)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.pageInfos.pop();
          })
        Text($r('app.string.list'))
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // [Start list_view]
      List({
        space: new WidthBreakpointType(8, 12, 16).getValue(this.mainWindowInfo.widthBp),
        scroller: this.listScroller
      }) {
        // [StartExclude list_view]
        ForEach(this.infoArray, (item: number, index: number) => {
          ListItem() {
            Row() {}
            .width('100%')
            .height(60)
            .borderRadius(16)
            .backgroundColor('#F1F3F5')
            .margin({ bottom: index === this.infoArray.length - 1 ?
              (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
              this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height) : 12) : 0 })
          }
        }, (item: number, index: number) => JSON.stringify(item) + index)
        // [EndExclude list_view]
      }
      .scrollBar(BarState.Off)
      .lanes(new WidthBreakpointType(1, 2, 3).getValue(this.mainWindowInfo.widthBp), 12)
      // [End list_view]
      .layoutWeight(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 1 : -1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      left: 16,
      right: 16
    })
  }
}