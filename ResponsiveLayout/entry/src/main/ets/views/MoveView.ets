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
export struct MoveView {
  @ObjectLink mainWindowInfo: WindowInfo;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      // [Start move_view]
      GridRow({
        columns: { xs: 4, sm: 4, md: 8, lg: 12, xl: 12 },
        gutter: 0,
        breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp']},
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: { xs: 4, sm: 4, md: 4, lg: 4, xl: 4 },
          offset: 0
        }) {
          // [StartExclude move_view]
          Column() {
            Image($r('app.media.ic_public_back'))
              .width(40)
              .height(40)
              .margin({ bottom: 12 })
              .onClick(() => {
                this.pathStack.pop();
              })

            GridRow({
              columns: { xs: 8, sm: 8, md: 8, lg: 12, xl: 12 },
              gutter: 8,
              breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp']},
              direction: GridRowDirection.Row
            }) {
              GridCol({
                span: { xs: 5, sm: 5, md: 8, lg: 12, xl: 12 },
                offset: 0
              }) {
                Row() {}
                .width('100%')
                .aspectRatio(1)
                .borderRadius(24)
                .backgroundColor('#F1F3F5')
                .margin({
                  left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 0 : 8,
                  right: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 0 : 8,
                  bottom: 12
                })
              }
              .layoutWeight(1)

              GridCol({
                span: { xs: 3, sm: 3, md: 8, lg: 12, xl: 12 },
                offset: 0
              }) {
                Column() {
                  Text($r('app.string.playlist'))
                    .fontSize(20)
                    .opacity(0.8)
                    .margin({ bottom: 8 })
                  Text($r('app.string.song_description'))
                    .fontSize(16)
                    .opacity(0.5)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? HorizontalAlign.Start :
                  HorizontalAlign.Center)
                .layoutWeight(1)
              }
              .layoutWeight(1)
              .width('100%')
            }
            .width('100%')
            .layoutWeight(1)
          }
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: new WidthBreakpointType(12, 16, 24).getValue(this.mainWindowInfo.widthBp),
            right: new WidthBreakpointType(12, 16, 24).getValue(this.mainWindowInfo.widthBp)
          })
          // [EndExclude move_view]
        }
        .height(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? this.getGridColHeight() : '100%')
        .padding({ top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12})
        .backgroundColor('#AAD3F1')

        GridCol({
          span: { xs: 4, sm: 4, md: 4, lg: 8, xl: 8 },
          offset: 0
        }) {
          // [StartExclude move_view]
          Scroll() {
            Column() {
              Text($r('app.string.song_list'))
                .fontSize(16)
                .opacity(0.8)
            }
            .alignItems(HorizontalAlign.Start)
            .height(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 600 : '100%')
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          // [EndExclude move_view]
        }
        .backgroundColor(Color.Pink)
        .layoutWeight(1)
        .padding({ top: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 0 :
          this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) })
      }
      // [End move_view]
      .width('100%')
      .layoutWeight(1)

      Row() {
        Row() {
          Column() {
            Image($r('app.media.ic_previous'))
              .height(24)
              .aspectRatio(1)
          }
          .layoutWeight(1)
          Column() {
            Image($r('app.media.ic_play_all'))
              .height(24)
              .aspectRatio(1)
          }
          .layoutWeight(1)
          Column() {
            Image($r('app.media.ic_next'))
              .height(24)
              .aspectRatio(1)
          }
          .layoutWeight(1)
        }
        .width(120)
        .height('100%')
        .margin({ right: 16 })
      }
      .justifyContent(FlexAlign.End)
      .height(this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height) + 32)
      .width('100%')
      .backgroundColor('#F1F3F5')
      .padding({ bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height) })
    }
  }

  getGridColHeight(): number {
    let gridColHeight: number = 0;
    // Height of avoidance zone in the top status bar.
    gridColHeight += this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height);
    // Height of back icon row
    gridColHeight += 40 + 12;
    // Height of image.
    gridColHeight += (this.getUIContext().px2vp(this.mainWindowInfo.windowSize.width) - 32) * 5 / 8 + 12 + 12;
    return gridColHeight;
  }
}