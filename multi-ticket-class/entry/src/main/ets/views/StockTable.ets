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

import { StockForm, STOCK_FORM, STOCK_TITLE } from '../models/DataModel';
import { BreakpointType } from '../utils/BreakpointType';
import { WordBackgroundComm } from './CommonView';

@Component
export struct StockTable {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('tabletMode') tabletMode: NavigationMode;
  private scroller: Scroller = new Scroller();

  @Builder
  StickyHeader(): void {
    Row() {
      ForEach(STOCK_TITLE, (item: Resource, index: number) => {
        Row() {
          Text(item)
            .fontSize(12)
        }
        .justifyContent(index === 0 ? FlexAlign.Start : FlexAlign.End)
        .width(index === 1 || index === 2 || index === 3 ? 90 : 100)
        .padding({
          right: index === STOCK_TITLE.length - 1 ?
            (new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)) : 0,
          left: index === 0 ? (new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)) : 0
        })

      }, (item: Resource, index: number) => item.toString() + index)
    }
    .height(36)
    .backgroundColor(Color.White)
  }

  build() {
    // [Start stock_list_area]
    Scroll(this.scroller) {
      List({ space: 20, initialIndex: 0 }) {
        ListItemGroup({ header: this.StickyHeader() }) {
          // [StartExclude stock_list_area]
          ListItem() {
          }
          // [EndExclude stock_list_area]
          ForEach(STOCK_FORM, (item: StockForm) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title)
                  // [StartExclude stock_list_area]
                    .minFontSize(8)
                    .maxFontSize(16)
                    .height(21)
                    .width(64)
                    .maxLines(1)

                  Row() {
                    Text(item.stockNumber)
                      .fontSize(12)
                      .height(16)
                      .fontColor($r('sys.color.font_tertiary'))
                      .textAlign(TextAlign.Start)
                    WordBackgroundComm({
                      text: item.plate,
                      textFontColor: item.plateFontColor,
                      textBackgroundColor: item.plateBackgroundColor
                    })
                  }
                  .width(64)
                  .justifyContent(FlexAlign.SpaceBetween)
                  // [EndExclude stock_list_area]
                }
                .alignItems(HorizontalAlign.Start)
                // [StartExclude stock_list_area]
                .width(100)
                .padding({
                  left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
                })

                Text((item.latestPrice / 100).toString())
                  .fontSize(14)
                  .height(19)
                  .width(90)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text((item.highsAndLows > 0 ? '+' + item.highsAndLows : item.highsAndLows).toString())
                  .fontSize(14)
                  .height(19)
                  .width(90)
                  .fontColor(item.highsAndLows > 0 ? '#FA4337' : '#1DB775')
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text(item.priceLimit)
                  .fontSize(14)
                  .height(19)
                  .width(90)
                  .fontColor(item.highsAndLows > 0 ? '#FA4337' : '#1DB775')
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text(item.gross)
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text(item.impressions)
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .fontColor(item.highsAndLows > 0 ? '#FA4337' : '#1DB775')
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text() {
                  Span(item.volumeTransaction)
                  Span($r('app.string.billion'))
                }
                .fontSize(14)
                .height(19)
                .width(100)
                .textAlign(TextAlign.End)
                .fontWeight(FontWeight.Medium)

                Text(item.amplitude)
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text(item.changeHands)
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                Text(item.PEG.toString())
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Medium)
                // [EndExclude stock_list_area]
                Text(item.PB.toString())
                  .textAlign(TextAlign.End)
                  // [StartExclude stock_list_area]
                  .fontSize(14)
                  .height(19)
                  .width(100)
                  .fontWeight(FontWeight.Medium)
                  .padding({
                    right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
                  })
                  // [EndExclude stock_list_area]
              }
            }
            .height(56)
          }, (item: StockForm, index: number) => (item.latestPrice + index).toString())
          // [StartExclude stock_list_area]
          ListItem() {
          }
          // [EndExclude stock_list_area]
        }
        .backgroundColor(Color.White)
        .divider({ strokeWidth: 1, color: '#F2RDED' }) // The dividing line between each row
      }
      .scrollBar(BarState.Off)
      .sticky(StickyStyle.Header)
      .onClick(() => {
        this.pageInfos.replacePathByName('StockDetailsPage', null, true);
      })
    }
    .scrollable(ScrollDirection.Horizontal) // Rolling direction: vertical
    .scrollBar(BarState.Off) // Permanent display of the scroll bar
    // [End stock_list_area]
  }
}