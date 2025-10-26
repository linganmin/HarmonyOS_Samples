/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { wearEngine } from '@kit.WearEngine';
import { BusinessError, Callback } from '@kit.BasicServicesKit';

@Entry
@Component
struct ServicePage {
  @State printContent: string = '';
  private callback: Callback<void> = () => {
    console.info('Wear Engine service disconnected.');
  }

  build() {
    Column() {
      Column() {
        Text($r("app.string.service_title"))
          .fontSize(STRING_MARGIN.TITLE_FONT_SIZE)
          .margin({
            left: STRING_MARGIN.TITLE_TIP_LEFT_SIZE,
            right: STRING_MARGIN.TITLE_TIP_RIGHT_SIZE,
            top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
          })
          .alignSelf(ItemAlign.Center)
        Text($r('app.string.service_tip'))
          .fontSize(STRING_MARGIN.TIP_FONT_SIZE)
          .margin({
            left: STRING_MARGIN.TITLE_TIP_LEFT_SIZE,
            right: STRING_MARGIN.TITLE_TIP_RIGHT_SIZE,
            top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
          })
          .alignSelf(ItemAlign.Start)
      }
      .width(STRING_PERCENT.MAX_PERCENT)

      Row() {
        Button($r('app.string.btn_on'), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            try {
              wearEngine.on('serviceDie', this.callback);
              this.printContent += 'Succeeded in subscribing the service destruction event.' + '\n';
            } catch (err) {
              this.printContent += `Failed to subscribe the service destruction event. Code is ${err.code}, message is ${err.message}.` + '\n';
            }
          })
      }
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE,
        left: STRING_MARGIN.BUTTONS_LEFT_SIZE,
        right: STRING_MARGIN.BUTTONS_RIGHT_SIZE
      })
      .alignSelf(ItemAlign.Start)

      Row() {
        Button($r('app.string.btn_off'), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            try {
              wearEngine.off('serviceDie', this.callback);
              this.printContent += 'Succeeded in unsubscribing the service destruction event.' + '\n';
              console.info(`Succeeded in unsubscribing the service destruction event.`);
            } catch (error) {
              const err: BusinessError = error as BusinessError;
              console.error(`Failed to unsubscribe the service destruction event. Code is ${err.code}, message is ${err.message}`);
            }
          })
      }
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE,
        left: STRING_MARGIN.BUTTONS_LEFT_SIZE,
        right: STRING_MARGIN.BUTTONS_RIGHT_SIZE
      })
      .alignSelf(ItemAlign.Start)

      Row() {
        Button($r('app.string.btn_destroy'), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            wearEngine.destroy().then(() => {
              this.printContent += 'Succeeded in destroying wear engine channel.' + '\n';
              console.info(`Succeeded in destroying wear engine channel`);
            }).catch((error: BusinessError) => {
              console.error(`Failed to destroy wear engine channel. Code is ${error.code}, message is ${error.message}`);
            })
          })
      }
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE,
        left: STRING_MARGIN.BUTTONS_LEFT_SIZE,
        right: STRING_MARGIN.BUTTONS_RIGHT_SIZE
      })
      .alignSelf(ItemAlign.Start)


      Scroll() {
        Text(this.printContent)
          .fontSize(STRING_MARGIN.TEXT_FONT_SIZE)
          .textAlign(TextAlign.Start)
          .width(STRING_PERCENT.NINETY_PERCENT)
      }
      .margin({
        left: STRING_MARGIN.PRINT_SCROLL_SIZE,
        right: STRING_MARGIN.PRINT_SCROLL_SIZE,
        top: STRING_MARGIN.PRINT_SCROLL_SIZE
      })
      .width(STRING_PERCENT.MAX_PERCENT)
      .height(STRING_PERCENT.SIXTY_PERCENT)
      .align(Alignment.TopStart)

      Row() {
        Button($r('app.string.btn_clear_print'), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .onClick(() => {
            this.printContent = '';
          })
          .layoutWeight(1)
          .backgroundColor($r("app.color.clear_button_color"))

      }
      .margin({
        top: STRING_MARGIN.BUTTONS_TOP_SIZE,
        left: STRING_MARGIN.BUTTONS_LEFT_SIZE,
        right: STRING_MARGIN.BUTTONS_RIGHT_SIZE
      })
      .alignSelf(ItemAlign.Start)
    }
  }
}
