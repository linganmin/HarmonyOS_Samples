/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { wearEngine } from '@kit.WearEngine';
import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct AuthPage {
  // Get AuthClient instance
  @State authClient: wearEngine.AuthClient = wearEngine.getAuthClient(getContext(this));
  // Create AuthorizationRequest instance
  @State request: wearEngine.AuthorizationRequest = {
    permissions: []
  }
  // Call result information displayed on the page
  @State printContent: string = '';

  build() {
    Column() {
      Text($r("app.string.auth_title"))
        .fontSize(STRING_MARGIN.TITLE_FONT_SIZE)
        .margin({
          top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
        })

      Text($r('app.string.select_permission'))
        .fontSize(STRING_MARGIN.TIP_FONT_SIZE)
        .margin({
          left: STRING_MARGIN.TITLE_TIP_LEFT_SIZE,
          top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
        })
        .alignSelf(ItemAlign.Start)

      // Select the permissions that require user authorization
      Scroll() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap
        }) {
          ForEach(Object.values(wearEngine.Permission).filter(item => isNaN(Number(item))),
            (item: string, index: number | undefined) => {
              Row() {
                Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
                  .select(false)
                  .selectedColor(0xed6f21)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.request.permissions.push(wearEngine.Permission[item]);
                    } else {
                      this.request.permissions =
                        this.request.permissions.filter(permission => permission !== wearEngine.Permission[item]);
                    }
                    console.info(JSON.stringify(this.request.permissions))
                  })
                Text(item).fontSize(14).opacity(Number.parseFloat('0.6'))
              }
              .margin({ left: 10, top: 8 })
            }, (item: number) => JSON.stringify(item))
        }
      }

      // Request user authorization
      Button($r('app.string.btn_request_authorization'), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r("app.color.base_button_color"))
        .margin({
          top: STRING_MARGIN.BUTTONS_TOP_SIZE
        })
        .onClick(() => {
          this.authClient.requestAuthorization(this.request).then((result) => {
            this.printContent += `The authorized permissions this time are ${JSON.stringify(result.permissions)}` + '.\n';
            console.info(`Succeeded in requesting authorization, authorized permissions are ${JSON.stringify(result.permissions)}.`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to request authorization. Code is ${error.code}, message is ${error.message}.` + '\n';
            console.error(`Failed to request authorization. Code is ${error.code}, message is ${error.message}.`);
          })
        })

      // Get all authorized permissions
      Button($r('app.string.btn_get_authorization'), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r("app.color.base_button_color"))
        .margin({
          top: STRING_MARGIN.BUTTONS_TOP_SIZE
        })
        .onClick(() => {
          this.authClient.getAuthorization().then((result) => {
            this.printContent += `All authorized permissions are ${JSON.stringify(result.permissions)}` + '.\n';
            console.info(`Succeeded in getting authorized permissions, result is ${JSON.stringify(result.permissions)}.`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to get authorized permissions. Code is ${error.code}, message is ${error.message}.` + '\n';
            console.error(`Failed to get authorized permissions. Code is ${error.code}, message is ${error.message}.`);
          })
        })

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

      Button($r("app.string.btn_clear_print"), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .backgroundColor($r("app.color.clear_button_color"))
        .onClick(() => {
          this.printContent = '';
        })
        .margin({
          top: STRING_MARGIN.MARGIN_TOP_SIZE
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width(STRING_PERCENT.MAX_PERCENT)
  }
}