/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { cancelAuthorization, showErrorMessage } from '../common/Utils';

const logTag: string = 'Phone';
const domainId: number = 0x0000;

@Component
export struct Phone {
  @Prop phone: string;
  onChange: (phone: string | undefined) => void = () => {
  };

  build() {
    Flex({ direction: FlexDirection.RowReverse, alignItems: ItemAlign.Center }) {
      if (this.phone) {
        Image($r('app.media.ic_public_arrow_right'))
          .fillColor($r('sys.color.ohos_id_color_foreground'))
          .opacity(0.2)
          .width(12)
          .height(24)
          .margin({ left: 4 })
      }

      Row() {
        Text($r('app.string.phone'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)

        Row() {
          if (this.phone) {
            Text(this.phone)
              .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .textAlign(TextAlign.End)
          } else {
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
                label: $r('app.string.get'),
                // Adjust the button style.
                styleOption: {
                  styleConfig: new functionalButtonComponentManager
                    .ButtonConfig()
                    .width(72)
                    .height(28)
                    .fontSize(14)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                    .fontColor($r('sys.color.ohos_id_color_focused_content_primary'))
                    .fontWeight(FontWeight.Medium)
                }
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController()
                .onGetPhoneNumber((err, data) => {
                  if (err) {
                    // Processing upon an error.
                    showErrorMessage(this.getUIContext(), err);
                    return;
                  }
                  // Processing upon a success.
                  // ...
                  hilog.info(domainId, logTag, 'succeeded in getting phone number.');
                  const code = data.code;

                  /*
                   * After obtaining the authorization code, send it to the atomic service server.
                   * The atomic service server calls the Account Kit server API to obtain an access token,
                   * and then use the access token to obtain the user's mobile number.
                   * ...
                   * In this example, the mobile number is not actually obtained.
                   * The mobile number is used for display purposes only.
                   * */
                  this.onChange('180******00');

                  /*
                   * The example demonstrates that a user will be prompted for authorization
                   * to access their mobile number on each use.
                   * Please note that this is a sample scenario.
                   * */
                  cancelAuthorization();
                })
            }).id('phoneFunctionalButtonId')
          }
        }
        .padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.End)
        .constraintSize({ minHeight: 48, maxWidth: '60%' })
        .width('100%')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding({
      left: 12,
      right: 12,
      top: 4,
      bottom: 4
    })
    .margin({ top: 12 })
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .borderRadius(20)
  }
}
