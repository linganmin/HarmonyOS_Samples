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

import { ShareIndex, SHARE_INDEX } from '../models/DataModel';
import { BreakpointType } from '../utils/BreakpointType';
import { StockTable } from '../views/StockTable';

@Component
export struct OptionPage {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = 1;
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  ShareIndexBuilder(info: ShareIndex, index: number) {
    Column() {
      Text(info.title)
        .lineHeight(16)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
      Column() {
        Text(info.index)
          .lineHeight(21)
          .fontSize(16)
          .fontColor(index % 2 === 0 ? '#FA4337' : '#1DB775')
          .fontWeight(FontWeight.Bold)
        Text(info.priceLimit)
          .lineHeight(10)
          .fontSize(10)
          .fontColor(index % 2 === 0 ? '#FA4337' : '#1DB775')
          .fontWeight(FontWeight.Medium)
      }
      .height(32)
    }
    .width(new BreakpointType(78, 101, 96).getValue(this.currentWidthBreakpoint))
    .height(73)
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 10,
      bottom: 12
    })
  }

  build() {
    Column() {
      // Self-Selected Stock Top Headline
      Row() {
        Text($r('app.string.self_select_stock'))
          .fontSize(24)
          .height(32)
          .fontWeight(700)
      }
      .width('100%')
      .height(56)
      .padding({
        right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
        left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
      })

      // [Start stock_list_area]
      // List of stock indices
      Row() {
        List({
          space: new BreakpointType(13, 14, 16).getValue(this.currentWidthBreakpoint),
          initialIndex: 0
        }) {
          ForEach(SHARE_INDEX, (item: ShareIndex, index: number) => {
            ListItem() {
              this.ShareIndexBuilder(item, index)
            }
            .margin({
              left: index === 0 ? new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint) : 0
            })
          }, (item: ShareIndex, index: number) => (item.priceLimit + index).toString())
        }
        // [StartExclude stock_list_area]
        .height(73)
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .layoutWeight(1)
        // [EndExclude stock_list_area]

        // Fixed Area.
        Row() {
          // [StartExclude stock_list_area]
          Column() {
            Text($r('app.string.stock_company'))
              .lineHeight(16)
              .fontSize(12)
              .fontColor('#FA4337')
              .fontWeight(FontWeight.Medium)
              .padding({
                bottom: 8
              })
            Column() {
              Text($r('app.string.stock_text_start'))
                .maxLines(1)
                .fontSize(10)
                .fontColor('#FA4337')
                .margin({
                  bottom: 2
                })
              Text($r('app.string.stock_text_end'))
                .fontSize(10)
                .fontColor('#FA4337')
                .maxLines(1)
            }
            .height(32)
          }
          .justifyContent(FlexAlign.SpaceBetween)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor(['#FA4337'])
            .fontSize(20)
            .margin({
              bottom: 40,
              left: new BreakpointType(4, 12, 18).getValue(this.currentWidthBreakpoint)
            })
          // [EndExclude stock_list_area]
        }
        .width(new BreakpointType(78, 101, 96).getValue(this.currentWidthBreakpoint))
        // [StartExclude stock_list_area]
        .height(73)
        .justifyContent(FlexAlign.Center)
        .borderRadius(8)
        .linearGradient({
          direction: GradientDirection.Bottom, // Gradient Direction
          repeating: true, // Does the gradient color repeat
          colors: [['#FFF9F9', 0], ['#FFFAFA', 0.5], ['#FFFEFE', 0.7], ['#FFFFFF', 1]]
        })
        // [EndExclude stock_list_area]
        .margin({
          right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
        })
      }
      // [End stock_list_area]
      .width('100%')
      .height(71)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Blank()
        .width('100%')
        .height(1)
        .backgroundColor($r('sys.color.gray_01'))

      Column() {
        // [Start stock_toolbar_area]
        Row() {
          Column() {
            Text($r('app.string.all'))
            // [StartExclude stock_toolbar_area]
              .fontSize(16)
              .fontWeight(700)
              .fontColor('#FA4337')
              .height(21)
              .focusable(true)
            // [EndExclude stock_toolbar_area]
          }
          .border({
            width: { bottom: 2 },
            color: { bottom: '#FA4337' },
            style: { bottom: BorderStyle.Solid }
          })

          Blank()
          Row() {
            SymbolGlyph($r('sys.symbol.rectangle_on_rectangle'))
            // [StartExclude stock_toolbar_area]
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(24)
              .margin({
                right: 24
              })
            // [EndExclude stock_toolbar_area]
            SymbolGlyph($r('sys.symbol.line_3_horizontal'))
            // [StartExclude stock_toolbar_area]
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(24)
            // [EndExclude stock_toolbar_area]
          }
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .padding({
          right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
          left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
        })
        // [End stock_toolbar_area]

        // Stock table list
        StockTable()
      }

      // Add custom buttons
      Row() {
        Row() {
          Text($r('app.string.add_custom_options'))
            .fontSize(16)
            .fontColor('#999999')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .borderColor('#E5E5E5')
        .borderWidth(1)
        .borderRadius(20)
        .width(240)
        .height(40)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        top: 24
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      top: AppStorage.get<number>('statusBarHeight')
    })
  }
}