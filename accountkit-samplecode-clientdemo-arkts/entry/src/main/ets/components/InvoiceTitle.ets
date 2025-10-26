/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { invoiceAssistant } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';

const storage: LocalStorage = new LocalStorage();

const domainId: number = 0x0000;
const logTag: string = 'InvoiceTitle';

@Component
export struct InvoiceTitle {
  @Link invoiceTitle: string;

  // Obtain the invoice title.
  private selectInvoiceTitle() {
    const context = this.getUIContext().getHostContext();
    try {
      if (canIUse("SystemCapability.HuaweiID.InvoiceAssistant")) {
        invoiceAssistant.selectInvoiceTitle(context).then((data: invoiceAssistant.InvoiceTitle) => {
          this.invoiceTitle = data.title + ' ' + data.taxNumber;
          storage.setOrCreate('invoiceTitle', this.invoiceTitle);
        }).catch((error: BusinessError) => {
          hilog.error(domainId, logTag,
            `Failed to selectInvoiceTitle. BusinessError errCode: ${error.code}, errMessage: ${error.message}`);
        })
      } else {
        // The API is not supported on this device.
        hilog.error(domainId, logTag, 'The API is not supported on this device.');
      }
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to selectInvoiceTitle. errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  build() {
    // Invoice title.
    Flex({ direction: FlexDirection.RowReverse, alignItems: ItemAlign.Center }) {
      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(0.2)
        .draggable(false)
        .width(12)
        .height(24)
        .margin({ left: 4 })

      Row() {
        Text($r('app.string.invoiceTitle'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)

        Row() {
          Text(this.invoiceTitle ? this.invoiceTitle : $r('app.string.addInvoiceTitle'))
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.End)
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
    .border({
      width: 2,
      color: AppStorage.get('colorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
        $r('sys.color.ohos_fa_list_card_bg') : Color.Transparent,
      radius: 20
    })
    .id('invoiceTitleRow')
    .onClick(() => {
      AvoidRepeatClick.avoidRepeatClick(() => {
        this.selectInvoiceTitle();
      });
    })
  }
}
