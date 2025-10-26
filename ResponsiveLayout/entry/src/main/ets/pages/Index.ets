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
import { WindowInfo, WindowUtil } from '../utils/WindowUtil';

@Entry
@Component
struct Index {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  aboutToDisappear(): void {
    this.windowUtil?.release();
  }

  build() {
    Navigation(this.pageInfos) {
      Scroll() {
        // [Start Avoid]
        Column() {
          Column() {
            Text($r('app.string.sample_name'))
              .fontSize(30)
              .fontWeight(700)
              .lineHeight(40)
          }
          .height(112)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.End)
          .margin({ bottom: 12 })

          ListJumpView({
            mainWindowInfo: this.windowUtil?.mainWindowInfo
          })
        }
        .width('100%')
        .padding({
          top: this.getUIContext().px2vp(this.windowUtil?.mainWindowInfo.AvoidSystem?.topRect.height),
          left: 16,
          right: 16
        })
        // [End Avoid]
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor('#F1F3F5')
      .scrollBar(BarState.Off)
    }
    .height('100%')
    .width('100%')
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .hideToolBar(true)
  }
}

@Component
struct ListJumpView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @ObjectLink mainWindowInfo: WindowInfo;
  layoutInfos: Resource[] = [$r('app.string.list'), $r('app.string.water_flow'), $r('app.string.swiper'),
    $r('app.string.grid'), $r('app.string.sidebar'), $r('app.string.double_column'), $r('app.string.triple_column'),
    $r('app.string.move_layout'), $r('app.string.tabs'), $r('app.string.indented_layout')];
  urlInfos: string[] = ['List', 'WaterFlow', 'Swiper', 'Grid', 'Sidebar', 'DoubleColumn', 'TripleColumn', 'MoveLayout',
    'Bottom/SideTabs', 'IndentedLayout'];

  build() {
    List() {
      ForEach(this.layoutInfos, (item: Resource, index: number) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(16)
            Blank()
            Image($r('app.media.chevron_right'))
              .width(12)
              .height(24)
              .opacity(0.4)
          }
          .height('100%')
          .width('100%')
          .padding({
            left: 12,
            right: 12
          })
          .onClick(() => {
            this.pageInfos.pushPathByName(this.urlInfos[index], null);
          })
        }
        .height(48)
      }, (item: Resource, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
    .lanes(new WidthBreakpointType(1, 2, 2).getValue(this.mainWindowInfo.widthBp))
    .borderRadius(16)
    .divider({ strokeWidth: 1, color: '#33000000', startMargin: 12, endMargin: 12 })
    .backgroundColor(Color.White)
  }
}