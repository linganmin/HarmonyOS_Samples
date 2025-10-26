/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { showErrorMessage } from '../common/Utils';

const logTag: string = 'InvoiceTitle';
const domainId: number = 0x0000;

@Component
export struct InvoiceTitle {
  @Prop invoiceTitle: functionalButtonComponentManager.ChooseInvoiceTitleResult | undefined;
  onChange: (invoiceTitle: functionalButtonComponentManager.ChooseInvoiceTitleResult | undefined) => void = () => {
  };

  build() {
    Flex({ direction: FlexDirection.RowReverse, alignItems: ItemAlign.Center }) {
      if (this.invoiceTitle) {
        Image($r('app.media.ic_public_arrow_right'))
          .fillColor($r('sys.color.ohos_id_color_foreground'))
          .opacity(0.2)
          .width(12)
          .height(24)
          .margin({ left: 4 })
      }

      Row() {
        Text($r('app.string.invoiceTitle'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)

        Row() {
          if (this.invoiceTitle) {
            Column() {
              Text(this.invoiceTitle.title)
                .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .maxLines(1)
              Text(this.invoiceTitle.taxNumber)
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
                openType: functionalButtonComponentManager.OpenType.CHOOSE_INVOICE_TITLE,
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
                .onChooseInvoiceTitle((err, data) => {
                  if (err) {
                    // Processing upon an error.
                    showErrorMessage(this.getUIContext(), err);
                    return;
                  }
                  // Processing upon a success.
                  // ...
                  hilog.info(domainId, logTag, 'Succeeded in obtaining data.');
                  this.onChange(data);
                })
            }).id('invoiceTitleFunctionalButtonId')
          }
        }.padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.End)
        .constraintSize({ minHeight: 48, maxWidth: '60%' })
        .width('100%')
      }.justifyContent(FlexAlign.SpaceBetween)
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
    .id('InvoiceTitleBuildFlex')
  }
}
