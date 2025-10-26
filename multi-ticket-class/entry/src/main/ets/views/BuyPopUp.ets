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

import { UniversalIcon } from './CommonView';

@Component
export struct BuyPopUp {
  @StorageLink('sharesHeldNumber') sharesHeldNumber: number = 0;
  @Consume('isFirstBulletBox') isFirstBulletBox: boolean;
  @Consume('popUpBoxIsShow') popUpBoxIsShow: boolean;
  @Consume('currentStockPrice') currentStockPrice: number;
  @Consume('purchaseQuantity') purchaseQuantity: number;
  @Consume('buyIsShow') buyIsShow: boolean;

  build() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Row() {
            UniversalIcon({
              icon: $r('sys.symbol.chevron_left'),
              iconBackgroundColor: $r('sys.color.comp_background_tertiary')
            })
              .onClick(() => {
                this.isFirstBulletBox = true;
              })
            Column() {
              Text($r('app.string.buy'))
                .fontSize(20)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              Text($r('app.string.Stock_name_code'))
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .margin({
              left: 8
            })
          }

          UniversalIcon({
            icon: $r('sys.symbol.xmark'),
            iconBackgroundColor: $r('sys.color.comp_background_tertiary'),
            fontSize: $r('sys.float.Title_S')
          })
            .onClick(() => {
              this.sharesHeldNumber += this.purchaseQuantity;
              this.purchaseQuantity = 100;
              this.buyIsShow = false;
              this.popUpBoxIsShow = false;
              this.isFirstBulletBox = true;
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(60)

        Row() {
          Text($r('app.string.shareholder_account'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Row() {
          Text($r('app.string.commissioned_price'))
          Text(this.currentStockPrice.toString())
            .fontColor('#FA4337')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding({
          right: 12,
          left: 12
        })

        Row() {
          Text($r('app.string.order_quantity'))
          Text(this.purchaseQuantity.toString())
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding({
          right: 12,
          left: 12
        })
      }
      .width('100%')

      Row() {
        Text($r('app.string.confirm_purchase'))
          .fontSize(16)
          .fontColor('#E53137')
      }
      .width('100%')
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.sharesHeldNumber += this.purchaseQuantity;
        this.purchaseQuantity = 100;
        this.buyIsShow = false;
        this.popUpBoxIsShow = false;
        this.isFirstBulletBox = true;
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
    .padding({
      top: 12,
      right: 16,
      left: 16,
      bottom: 32
    })
  }
}