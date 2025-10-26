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

import { BUY_SELL_SHARES, SELL_SHARES, SUBMISSION_TIME, transactionDetails } from '../models/DataModel';
import { BreakpointType } from '../utils/BreakpointType';
import { StockDetails } from './CommonView';

@Component
export struct StockDealDetails {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  private concludeDetailsScroller: Scroller = new Scroller();

  build() {
    Row() {
      Column({ space: 2 }) {
        Text($r('app.string.market_conditions'))
          .width('100%')
          .height(20)
          .fontColor('#FA7137')
          .backgroundColor('#FFEFEE')
          .fontSize(10)
          .textAlign(TextAlign.Center)
        ForEach(SELL_SHARES, (item: transactionDetails, index: number) => {
          StockDetails({
            title: item.title,
            price: item.price,
            amount: item.amount,
            index: index + 1
          })
            .padding({
              right: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint),
              left: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint)
            })
        }, (item: transactionDetails, index: number) => (item.price + index).toString())
        Row() {
          Slider({
            value: 60,
            min: 0,
            max: 100,
            style: SliderStyle.NONE
          })
            .trackColor('#1DB775')
            .selectedColor('#FA4337')
        }
        .width('100%')
        .height(10)

        ForEach(BUY_SELL_SHARES, (item: transactionDetails, index: number) => {
          StockDetails({
            title: item.title,
            price: item.price,
            amount: item.amount,
            index: index + 1
          })
            .padding({
              right: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint),
              left: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint)
            })
        }, (item: transactionDetails, index: number) => (item.price + index).toString())

        Text($r('app.string.transaction_details'))
          .width('100%')
          .height(20)
          .backgroundColor('#F4F3F8')
          .fontSize(10)
          .textAlign(TextAlign.Center)

        Scroll(this.concludeDetailsScroller) {
          Column() {
            ForEach(SUBMISSION_TIME, (item: transactionDetails, index: number) => {
              StockDetails({
                title: item.title,
                price: item.price,
                amount: item.amount,
                isShowNumber: false,
                index: index + 1
              })
                .padding({
                  top: 2,
                  right: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint),
                  bottom: 2,
                  left: new BreakpointType(8.25, 8.25, 9).getValue(this.currentWidthBreakpoint)
                })
            }, (item: transactionDetails, index: number) => (item.price + index).toString())
          }
        }
        .height(new BreakpointType(70, 70, 102).getValue(this.currentWidthBreakpoint))
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 4,
        bottom: 12
      })
    }
    .width(new BreakpointType(103, 103, 192).getValue(this.currentWidthBreakpoint))
    .height('100%')
    .padding({
      left: 4
    })
  }
}