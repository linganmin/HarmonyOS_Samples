/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { image } from '@kit.ImageKit';
import { generateBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CashFlowCenterCard } from '../view/CashFlowCenterCard';
import { Constants } from '../common/Constants';
import { ReceiveMoneyServiceCardItem, ReceiveMoneyCardViewModel } from '../viewmodel/ReceiveMoneyCardViewModel';
import { Logger } from '../common/Logger';

@Component
export struct ReceivePaymentPage {
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State receiveMoneyServiceCard: ReceiveMoneyServiceCardItem[] = new ReceiveMoneyCardViewModel()
    .getReceiveMoneyServiceCardsWithNotBrief();
  @Consume('pathInfos') pathInfos: NavPathStack;
  // [Start receive_payment_page]
  private timer: number | null = null;
  private getQRCode = () => (new Date()).valueOf().toString();

  private getAndUpdateQRCode(): void {
    // [StartExclude receive_payment_page]
    const content: string = this.getQRCode();
    if (canIUse('SystemCapability.Multimedia.Scan.GenerateBarcode')) {
      if (canIUse('SystemCapability.Multimedia.Scan.Core')) {
        const options: generateBarcode.CreateOptions = {
          scanType: scanCore.ScanType.QR_CODE,
          height: Constants.QRCODE_SIZE,
          width: Constants.QRCODE_SIZE
        };
        generateBarcode.createBarcode(content, options, (error: BusinessError, pixelMap: image.PixelMap) => {
          if (error) {
            Logger.error(`Callback error: ${JSON.stringify(error)}`);
            return;
          }
          this.pixelMap = pixelMap;
        })
      }
    }
    // [EndExclude receive_payment_page]
  }

  aboutToAppear(): void {
    this.getAndUpdateQRCode();
    this.timer = setInterval(() => {
      this.getAndUpdateQRCode();
    }, 60 * 1000);
  }

  aboutToDisappear(): void {
    this.timer = null;
  }
  // [End receive_payment_page]

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_return'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
          .onClick(() => {
            this.pathInfos.pop();
          })
        Text($r('app.string.receive_and_pay_money'))
          .opacity(Constants.OPACITY)
          .fontFamily($r('app.string.normal_font_family'))
          .fontSize($r('app.float.bigger_font_size'))
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .fontWeight(Constants.FONT_WEIGHT[0])
        Image($r('app.media.ic_share'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
          .fillColor($r('app.color.icon_color'))
      }
      .width(Constants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Column() {
        Row() {
          Image($r('app.media.receive_payment'))
            .width($r('app.float.icon_size'))
            .height($r('app.float.icon_size'))
            .margin({ right: Constants.CONTENT_SPACE[1] })

          Text($r('app.string.personal_receive_money'))
            .fontFamily($r('app.string.medium_font_family'))
            .fontSize($r('app.float.biggest_font_size'))
            .fontColor(Color.Black)
            .fontWeight(Constants.FONT_WEIGHT[1])

        }
        .width(Constants.FULL_WIDTH)
        .alignItems(VerticalAlign.Center)
        .padding({
          top: Constants.CONTENT_SPACE[6],
          left: Constants.CONTENT_SPACE[6],
          bottom: Constants.CONTENT_SPACE[6]
        })

        Text($r('app.string.slogan'))
          .fontFamily($r('app.string.normal_font_family'))
          .fontSize($r('app.float.smaller_font_size'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
          .fontWeight(Constants.FONT_WEIGHT[0])

        Text($r('app.string.user_name'))
          .fontFamily($r('app.string.medium_font_family'))
          .fontSize($r('app.float.middle_font_size'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
          .fontWeight(Constants.FONT_WEIGHT[1])

        Stack({ alignContent: Alignment.Center }) {
          Row() {
            Image(this.pixelMap)
              .width(Constants.FULL_WIDTH)
              .height(Constants.FULL_HEIGHT)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)

          Image($r('app.media.avatar'))
            .width($r('app.float.avatar_size'))
            .height($r('app.float.avatar_size'))

        }
        .width($r('app.float.receive_money_container_size'))
        .height($r('app.float.receive_money_container_size'))
        .margin({
          top: $r('app.float.receive_money_container_smaller_margin_top'),
          bottom: $r('app.float.receive_money_container_smaller_margin_bottom')
        })

        Row() {
          Text($r('app.string.set_amount'))
            .fontFamily($r('app.string.normal_font_family'))
            .fontSize($r('app.float.bigger_border_radius'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
            .fontWeight(Constants.FONT_WEIGHT[1])
            .width($r('app.float.receive_money_card_bottom_text_width'))
            .height($r('app.float.set_amount_height'))
            .textAlign(TextAlign.Center)
          Divider()
            .vertical(true)
            .color($r('app.color.divider_color'))
            .height($r('app.float.divider_height'))
          Text($r('app.string.save_image'))
            .fontFamily($r('app.string.normal_font_family'))
            .fontSize($r('app.float.middle_font_size'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
            .fontWeight(Constants.FONT_WEIGHT[1])
            .width($r('app.float.receive_money_card_bottom_text_width'))
            .height($r('app.float.save_image_height'))
            .textAlign(TextAlign.Center)
        }

        Column() {
          CashFlowCenterCard({ cashFlowCenterItem: this.receiveMoneyServiceCard[0] })
        }
        .width(Constants.FULL_WIDTH)
        .margin({ top: $r('app.float.receive_money_bottom_card_margin_top') })
      }
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.bigger_border_radius'))
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: Constants.CONTENT_SPACE[5], bottom: Constants.CONTENT_SPACE[5] })

      Column() {
        ForEach(this.receiveMoneyServiceCard.slice(1, 3), (item: ReceiveMoneyServiceCardItem) => {
          CashFlowCenterCard({ cashFlowCenterItem: item })
            .margin({ bottom: Constants.CONTENT_SPACE[5] })
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.smaller_border_radius'))
        }, (item: ReceiveMoneyServiceCardItem, index: number) => index + JSON.stringify(item))
      }
    }
    .width(Constants.FULL_WIDTH)
    .height(Constants.FULL_HEIGHT)
    .backgroundColor($r('app.color.receive_payment_background_color'))
    .padding({
      top: $r('app.float.avoid_area_top'),
      bottom: $r('app.float.avoid_area_bottom'),
      left: Constants.CONTENT_SPACE[5],
      right: Constants.CONTENT_SPACE[5]
    })
  }
}