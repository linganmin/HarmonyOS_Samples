/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { loginComponentManager } from '@kit.AccountKit';
import { connection } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';

const logTag: string = 'AgreementDialog';
const domainId: number = 0x0000;

@CustomDialog
export struct AgreementDialog {
  dialogController?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  openDialog: () => void = () => {
  };
  closeDialog: () => void = () => {
  };
  privacyText: loginComponentManager.PrivacyText[] = [];
  pageInfos: NavPathStack = new NavPathStack();

  // Redirect to the privacy policy page.
  jumpToPrivacyWebView(isFromDialog: boolean, protocolUrl?: string) {
    hilog.info(domainId, logTag, 'Click protocol url');
    try {
      const hasNet: boolean = connection.hasDefaultNetSync();
      if (!hasNet) {
        // Pop-up message displayed when the network is unavailable.
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
      hilog.error(domainId, logTag, `Failed to has net , errCode: ${error?.code}, errMessage: ${error?.message}`);
    }
    this.closeDialog();
    const systemLanguage: string =
      (this.getUIContext().getHostContext() as common.UIAbilityContext).config.language ?? '';
    hilog.info(domainId, logTag, `systemLanguage is ${systemLanguage}`);
    const params: Record<string, Object> = {
      'isFromDialog': isFromDialog,
      'protocolUrl': protocolUrl + systemLanguage
    };
    this.pageInfos?.pushPathByName('ProtocolWebView', params, (popInfo: PopInfo) => {
      if (popInfo.result) {
        hilog.info(domainId, logTag, `pop to agreementDialog result: ${JSON.stringify(popInfo.result)}}`);
        const isFromWeb = (popInfo.result['isFromWeb'] ?? false) as boolean;
        if (isFromWeb) {
          // Re-open the agreement dialog box.
          this.openDialog();
        }
      }
    }, true);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.user_agreement_and_privacy_policy'))
          .id('loginPanel_agreement_dialog_privacy_title')
          .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
          .minFontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 56, maxWidth: 400 })
      .margin({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Row() {
        Text() {
          if (this.privacyText && this.privacyText.length > 0) {
            ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
              if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                Span(item?.text)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
              } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                Span(item?.text)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.activity_color'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .id('protocolUrlToPrivacyWebViewSpan')
                  .onClick(() => {
                    hilog.info(domainId, logTag, 'protocol url click');
                    AvoidRepeatClick.avoidRepeatClick(() => {
                      if (item?.tag !== '') {
                        try {
                          this.jumpToPrivacyWebView(true, item?.tag);
                        } catch (error) {
                          hilog.error(domainId, logTag,
                            `Failed to jump privacy webview , errCode: ${error.code}, errMessage: ${error.message}`);
                        }
                      }
                    });
                  })
              }
            }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
          }
        }
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(10)
        .textAlign(TextAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
      }
      .width('100%')
      .padding({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Flex({
        direction: FlexDirection.Row
      }) {
        Button($r('app.string.cancel'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .backgroundColor(Color.Transparent)
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .margin({ right: 8 })
          .width('50%')
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .id('cancelAgreementDialogButton')
          .onClick(() => {
            hilog.info(domainId, logTag, 'AgreementDialog cancel');
            AvoidRepeatClick.avoidRepeatClick(() => {
              this.cancel();
            });
          })

        Button($r('app.string.agree_and_sign_in'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_dialog_huawei_id_login_btn')
          .fontColor(Color.White)
          .backgroundColor($r('app.color.activity_color'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .margin({ left: 8 })
          .width('50%')
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .id('agreeAndSignInButton')
          .onClick(() => {
            hilog.info(domainId, logTag, 'AgreementDialog confirm');
            AvoidRepeatClick.avoidRepeatClick(() => {
              this.confirm();
            });
          })
      }
      .margin({
        top: 8,
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        bottom: 16
      })
    }.backgroundColor($r('sys.color.ohos_id_color_dialog_default_bg'))
  }
}
