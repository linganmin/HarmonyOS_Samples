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

import { StockInForm, STOCK_INFORM_LIST } from '../models/DataModel';
import { BreakpointType } from '../utils/BreakpointType';
import { StockInFormList } from './CommonView';

@Component
export struct StockDetailsInfo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @Consume('isExpand') isExpand: boolean;

  build() {
    Column() {
      Row() {
        Text('20.01')
          .fontSize(30)
          .height(30)
          .fontColor('#FA4337')
          .fontWeight(FontWeight.Medium)
          .margin({
            right: 11.5
          })
        Text('+19.8 +0.64%')
          .fontSize(14)
          .height(19)
          .fontColor('#FA4337')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Bottom)
      .backgroundColor(Color.White)
      .padding({
        top: 9,
        right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
        bottom: 9,
        left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
      })

      // [Start market_quote_data_area]
      Row() {
        Column() {
          GridRow({
            columns: 12,
            direction: GridRowDirection.Row
          }) {
            ForEach(STOCK_INFORM_LIST, (item: StockInForm, index: number) => {
              GridCol({
                span: {
                  xs: 6,
                  sm: 6,
                  md: 4,
                  lg: 3
                }
              }) {
                StockInFormList({ item: item, index: index })
              }
            }, (item: StockInForm, index: number) => item.title1.toString() + index)
          }
          .width('100%')

          SymbolGlyph(this.isExpand ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize(16)
            .onClick(() => {
              this.isExpand = !this.isExpand;
            })
            // [StartExclude market_quote_data_area]
            .padding({
              bottom: 4
            })
            // [EndExclude market_quote_data_area]
        }
        // [StartExclude market_quote_data_area]
        .width('100%')
        .backgroundColor(Color.White)
        // [EndExclude market_quote_data_area]
      }
      // [End market_quote_data_area]
    }
  }
}