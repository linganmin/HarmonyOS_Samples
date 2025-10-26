/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { LengthMetrics } from '@ohos.arkui.node';
import { getBorderRadius, isNewCardPaymentType } from '../util/PaymentUtil';
import { PaymentOrderComp } from './PaymentOrderComp';
import { PaymentItemComp } from './PaymentItemComp';
import { ConfirmButton } from './ConfirmButton';
import { PaymentType } from '../data/PaymentType';
import { paymentTypeList, paymentTypes3PayShow } from '../data/TestData';

@Preview
@Component
export struct CashierComponent {
  // Merchant Name
  private mercShortName: string = "华为支付测试商户";
  // Payment amount
  private paymentAmount: string = '0.01';
  @State selectedPaymentType: PaymentType = new PaymentType();
  @State selectedPayTypeSerialNo: string = '';

  // Header: Merchant order information
  @Builder
  orderDetail() {
    Column() {
      PaymentOrderComp({
        mercShortName: this.mercShortName,
        paymentAmount: this.paymentAmount,
      })
        .margin({ bottom: 24 });
    }
    .width('100%')
    .padding({
      top: $r('sys.float.ohos_id_elements_margin_vertical_m'),
    })
  }

  // Central: Title of the list of payment methods
  @Builder
  displayHeader() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Image($r('app.media.kit_hwpay_wallet'))
          .borderRadius(getBorderRadius(24))
          .width(24)
          .height(24)
          .margin({ end: LengthMetrics.vp(16) })

        Text($r('app.string.kit_hwpay_desc'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi-Medium')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
      }
      .width('100%')
      .constraintSize({ minHeight: 48 })
      .padding({
        left: 8,
        right: 8,
        top: 12,
        bottom: 12,
      })

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .width('100%')
        .margin({
          start: LengthMetrics.vp(48),
          end: LengthMetrics.vp(12),
        })
    }
  }

  // Central: Other payment options
  @Builder
  moreBankFooter() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text($r('app.string.kit_hwpay_change_other_pay_type'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))

      Image($r('app.media.kit_hwpay_right_v2'))
        .matchTextDirection(true)
        .width(12)
        .height(24)
        .fillColor($r('sys.color.ohos_id_color_fourth'))
    }
    .padding({
      top: 12,
      bottom: 12,
    })
    .margin({ start: LengthMetrics.vp(40) })
  }

  // Central: Select payment event
  select(PaymentType: PaymentType) {
    this.selectedPaymentType = PaymentType;
    this.selectedPayTypeSerialNo = PaymentType.payTypeSerialNo || '';
  }

  // Central: List of payment methods
  @Builder
  paymentListBuilder() {
    Column() {
      List() {
        ListItemGroup({
          header: this.displayHeader(),
          style: ListItemGroupStyle.CARD,
        }) {
          ForEach(paymentTypeList, (paymentType: PaymentType) => {
            ListItem({ style: ListItemStyle.CARD }) {
              PaymentItemComp({
                paymentType: paymentType,
                canChecked: !isNewCardPaymentType(paymentType),
                isChecked: this.selectedPayTypeSerialNo === paymentType.payTypeSerialNo,
                onSelect: () => {
                  if (paymentType.isAvailable) {
                    this.select(paymentType);
                  }
                },
              })
            }
            .height(undefined)
            .constraintSize({ minHeight: 48 })
            .backgroundColor(Color.Transparent)
          })

          // Other payment methods
          ListItem({ style: ListItemStyle.CARD }) {
            this.moreBankFooter();
          }
          .height(undefined)
          .constraintSize({ minHeight: 48 })
          .backgroundColor(Color.Transparent)
        }.divider({
          strokeWidth: 0.5,
          color: $r('sys.color.ohos_id_color_list_separator'),
          startMargin: 48,
          endMargin: 12,
        }).margin({
          left: 0,
          right: 0,
        }).backgroundColor($r('sys.color.comp_background_list_card'))
      }.width('100%')

      // Three-party payment method
      List() {
        ListItemGroup({ style: ListItemGroupStyle.CARD }) {
          ForEach(paymentTypes3PayShow, (paymentType: PaymentType) => {
            ListItem({ style: ListItemStyle.CARD }) {
              PaymentItemComp({
                paymentType: paymentType,
                canChecked: true,
                isChecked: this.selectedPayTypeSerialNo === paymentType.payTypeSerialNo,
                onSelect: () => {
                  if (paymentType.isAvailable) {
                    this.select(paymentType);
                  }
                },
              })
            }
            .height(undefined)
            .constraintSize({ minHeight: 48 })
            .backgroundColor(Color.Transparent)
          })
        }.divider({
          strokeWidth: 0.5,
          color: $r('sys.color.ohos_id_color_list_separator'),
          startMargin: 48,
          endMargin: 12,
        })
        .margin({
          left: 0,
          right: 0,
        }).backgroundColor($r('sys.color.comp_background_list_card'))
      }
      .width('100%')
      .margin({
        top: 12,
      })
    }
  }

  // Central: Payment Method List Container
  @Builder
  paymentListContent() {
    Column() {
      this.paymentListBuilder();
    }
    .margin({
      bottom: 12,
    })
  }

  // Bottom: Button area
  @Builder
  buttonArea() {
    ConfirmButton({
      text: $r('app.string.kit_hwpay_checkout_confirm_pay'),
    })
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_l'),
      });
  }

  // Cashier Home Page
  @Builder
  cashierUI() {
    // Order information area and Payment method area
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      this.orderDetail();
      this.paymentListContent();
    }
    .align(Alignment.Top)
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
    })

    // Button area
    Column() {
      this.buttonArea();
      // bottom aiBar
      Row()
        .width('100%')
        .height(28)
        .margin({ top: $r('sys.float.ohos_id_elements_margin_vertical_l') })
    }
    .flexShrink(0)
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
    })
  }

  // Page Container
  build() {
    Column() {
      this.cashierUI();
    }
  }
}