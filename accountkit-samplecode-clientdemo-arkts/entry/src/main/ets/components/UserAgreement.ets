/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { loginComponentManager } from '@kit.AccountKit';
import { common } from '@kit.AbilityKit';
import { connection } from '@kit.NetworkKit';

const logTag: string = 'UserAgreement';
const domainId: number = 0x0000;

@Component
export struct UserAgreement {
  onChange?: (value: boolean) => void;
  privacyText: loginComponentManager.PrivacyText[] = []
  @Prop enableStatus: boolean; // Enabled or not.
  @Link isSelected: boolean; // Specify whether the agreements are accepted.
  pageInfos: NavPathStack = new NavPathStack();

  // Redirect to the HUAWEI ID User Authentication Agreement page.
  jumpToPrivacyWebView(item: loginComponentManager.PrivacyText) {
    hilog.info(domainId, logTag, 'Click protocol url');
    try {
      const hasNet: boolean = connection.hasDefaultNetSync();
      if (!hasNet) {
        this.getUIContext().showAlertDialog({
          message: $r('app.string.hwid_no_internet_connect'),
          textStyle: { wordBreak: WordBreak.BREAK_WORD },
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Center,
          autoCancel: false,
          confirm: {
            value: $r('app.string.hwid_text_button_known'),
            action: () => {
            }
          }
        })
        return;
      }
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to obtain network information, errCode: ${error?.code}, errMessage: ${error?.message}`);
    }
    if (item.tag && item.tag !== '') {
      // Obtain the multi-language environment information of the system.
      const systemLanguage: string =
        (this.getUIContext().getHostContext() as common.UIAbilityContext).config.language ?? '';
      hilog.info(domainId, logTag, `systemLanguage is ${systemLanguage}`);
      const params: Record<string, Object> = {
        'isFromDialog': false,
        'protocolUrl': item.tag + systemLanguage
      };
      // Concatenate link parameters.
      this.pageInfos?.pushPathByName('ProtocolWebView', params, true);
    }
  }

  build() {
    // Agreement.
    Flex({
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start
    }) {
      Row() {
        Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
          .width(24)
          .height(24)
          .padding(2)
          .focusable(true)
          .focusOnTouch(true)
          .selectedColor($r('app.color.activity_color'))
          .select(this.isSelected)
          .enabled(this.enableStatus)
          .margin({ top: 0 })
          .onChange((value: boolean) => {
            this.isSelected = value;
            if (this.onChange) {
              this.onChange(value);
            }
          })
      }

      Row() {
        Text() {
          if (this.privacyText && this.privacyText.length > 0) {
            ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
              if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                Span(item?.text)
                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .fontSize($r('sys.float.ohos_id_text_size_body3'))
              } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                Span(item?.text)
                  .fontColor(this.enableStatus ? $r('sys.color.ohos_id_color_text_primary') :
                    $r('sys.color.ohos_id_color_text_tertiary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_body3'))
                  .id('userAgreeProtocolUrlSpan')
                  .onClick(() => {
                    hilog.info(domainId, logTag, 'protocol url click');
                    if (this.enableStatus) {
                      try {
                        this.jumpToPrivacyWebView(item);
                      } catch (error) {
                        const code: number = error.code;
                        const message: string = error.message;
                        hilog.error(domainId, logTag,
                          `Failed to jump privacy webview , errCode: ${code}, errMessage: ${message}`);
                      }
                    }
                  })
              }
            }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
          }
        }
      }
      .constraintSize({ minHeight: 24 })
      .padding({ left: 12 })
    }
  }
}