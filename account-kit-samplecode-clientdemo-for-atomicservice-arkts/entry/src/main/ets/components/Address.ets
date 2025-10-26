/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { showErrorMessage } from '../common/Utils';
import { hilog } from '@kit.PerformanceAnalysisKit';

const logTag: string = 'Address';
const domainId: number = 0x0000;

@Component
export struct Address {
  @Prop address: functionalButtonComponentManager.ChooseAddressResult;
  onChange: (phone: functionalButtonComponentManager.ChooseAddressResult | undefined) => void = () => {
  };

  build() {
    Flex({
      direction: FlexDirection.RowReverse,
      alignItems: ItemAlign.Center
    }) {
      if (this.address) {
        Image($r('app.media.ic_public_arrow_right'))
          .fillColor($r('sys.color.ohos_id_color_foreground'))
          .opacity(0.2)
          .width(12)
          .height(24)
          .margin({ left: 4 })
      }

      Row() {
        Text($r('app.string.shippingAddress'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)

        Blank()
          .width(16)

        Row() {
          if (this.address) {
            Column() {
              Text(`${this.address.userName} ${this.address.mobileNumber}`)
                .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
              Text(`${this.address.provinceName} ${this.address.cityName} ${this.address.districtName}` +
                ` ${this.address.streetName} ${this.address.detailedAddress}`)
                .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
            }
            .alignItems(HorizontalAlign.End)
          } else {
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.CHOOSE_ADDRESS,
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
                .onChooseAddress((err, data) => {
                  if (err) {
                    // Processing upon an error.
                    showErrorMessage(this.getUIContext(), err);
                    return;
                  }
                  // Processing upon a success.
                  // ...
                  hilog.info(domainId, logTag, 'Succeeded in getting address.');
                  this.onChange(data);
                })
            }).id('addressFunctionalButtonId')
          }
        }
        .padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
      }
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
