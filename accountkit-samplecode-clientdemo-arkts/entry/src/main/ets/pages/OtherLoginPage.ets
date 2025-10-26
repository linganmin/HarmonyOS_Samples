/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { loginComponentManager } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { UserInfo } from '../common/UserInfo';
import { getUnionID, getWhiteSpaceWidthByDisplayWidth } from '../common/Utils';
import { UserAgreement } from '../components/UserAgreement';

const logTag: string = 'OtherLoginPage';
const domainId: number = 0x0000;
const storage: LocalStorage = new LocalStorage();

@Component
export struct OtherLoginPage {
  // Specify whether to accept the agreements.
  @State isSelected: boolean = false;
  // Specify whether the button can be tapped.
  @State allowClick: boolean = false;
  private inputContent: string = '';
  pageInfos: NavPathStack = new NavPathStack();
  @LocalStorageLink('isLogin') isLogin: boolean = false;
  @StorageProp('aiBarHeight') aiBarHeight: number = 0;
  @StorageProp('isFullMode') isFullMode: boolean =
    true; // This parameter indicates whether the full-screen mode is used.
  @StorageProp('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>([]);
  params?: Record<string, Object>;
  // This parameter indicates whether the user selects other sign-in options.
  @LocalStorageLink('isUserSelected') isUserSelected: boolean = false;
  privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: $r('app.string.agree'),
      type: loginComponentManager.TextType.PLAIN_TEXT
    }, {
    text: $r('app.string.shopping_user_agreement'),
    type: loginComponentManager.TextType.RICH_TEXT,
    // Change the link to that of your own privacy policy.
    // ...
    tag: ''
  }, {
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.shopping_privacy_policy'),
    type: loginComponentManager.TextType.RICH_TEXT,
    // Change the link to that of your own privacy policy.
    // ...
    tag: ''
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }
  ];
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;
  @LocalStorageProp('isBigDisplay') isBigDisplay: boolean = false;
  @LocalStorageProp('isDevice2in1') isDevice2in1: boolean = false;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'OtherLoginPage aboutToAppear');
  }

  aboutToDisappear(): void {
    hilog.info(domainId, logTag, 'OtherLoginPage aboutToDisappear');
    this.isUserSelected = false;
  }

  // Redirect to the privacy policy page.
  jumpToPrivacyWebView(isFromDialog: boolean, protocolUrl?: string) {
    const params: Record<string, Object> = {
      'isFromDialog': isFromDialog,
      'protocolUrl': protocolUrl ?? ''
    };
    this.pageInfos?.pushPathByName('ProtocolWebView', params, true);
  }

  // Indicate whether the content needs to be displayed in two columns.
  isNeedDoubleColumn(): boolean {
    return this.isPhone && this.isLandScape && this.isFullMode;
  }

  // Callback for the back button event or back swipe gesture event.
  onBackPressed(): void {
    if (!this.pageInfos || this.pageInfos === null) {
      return;
    }
    this.pageInfos.pop();
  }

  @Builder
  Star() {
    Row() {
      Image($r('app.media.ic_collected'))
        .fillColor($r('sys.color.ohos_id_color_tertiary'))
        .width(20)
        .height(20)
        .draggable(false)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(36)
    .height(36)
    .borderRadius(20)
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
  }

  build() {
    NavDestination() {
      // Back button.
      Row() {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.hwid_next_ic_appback'))
            .backgroundColor(Color.Transparent)
            .borderRadius(20)
            .width(40)
            .height(40)
            .draggable(false)
            .autoResize(false)
            .focusable(true)
            .fillColor($r('sys.color.ohos_id_color_titlebar_icon'))
            .matchTextDirection(true)
        }
        .alignSelf(ItemAlign.Start)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius(20)
        .width(40)
        .height(40)
        .id('otherLoginAppBackButton')
        .onClick(() => {
          AvoidRepeatClick.avoidRepeatClick(() => {
            this.onBackPressed();
          })
        })
      }
      .height(56)
      .padding({
        top: 8,
        bottom: 8,
        left: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
        right: getWhiteSpaceWidthByDisplayWidth(this.displayWidth)
      })
      .width('100%')
      .margin({
        top: -56,
        left: this.isNeedDoubleColumn() ? 40 : 16,
        right: this.isNeedDoubleColumn() ? 40 : 16
      })
      .offset({
        top: 56 + (this.isNeedDoubleColumn() || this.isDevice2in1 ? 0 :
          this.getUIContext().px2vp(this.statusBarHeight))
      })
      .zIndex(2024);

      Scroll() {
        Column() {
          Flex({
            direction: this.isNeedDoubleColumn() ? FlexDirection.Row : FlexDirection.Column,
            alignItems: ItemAlign.Center
          }) {
            Column() {
              // App icon.
              Row() {
                Image($r('app.media.appmarket'))
                  .width(this.isPhone ? 80 : 96)
                  .height(this.isPhone ? 80 : 96)
                  .draggable(false)
                  .copyOption(CopyOptions.None)
                  .borderRadius(20)
                  .onComplete(() => {
                    hilog.info(domainId, logTag, 'Succeeded in loading appIcon.');
                  })
                  .onError(() => {
                    hilog.error(domainId, logTag, 'Failed to load appIcon.');
                  })
              }
              .height(this.isNeedDoubleColumn() ? 80 : '100%');

              // Mobile number input box.
              Row() {
                Column() {
                  Stack({ alignContent: Alignment.End }) {
                    // Mobile number input box.
                    TextInput({
                      placeholder: $r('app.string.phone'),
                    })
                      .id('inp_hwid_bind_phone')
                      .type(InputType.PhoneNumber)
                      .enterKeyType(EnterKeyType.Next)
                      .enableKeyboardOnFocus(true)
                      .defaultFocus(true)
                      .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
                      .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
                      .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .maxLength(24)
                      .constraintSize({ minHeight: 56 })
                      .padding({ left: 82 })
                      .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
                      .borderColor($r('sys.color.ohos_id_color_warning'))
                      .inputFilter('^[0-9*]{0,11}$')
                      .onChange((value: string) => {
                        this.inputContent = value;
                        this.allowClick = (this.inputContent.length === 11 ? true : false);
                      })

                    // Prefix.
                    Row() {
                      Text('+' + 86)
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontSize($r('sys.float.ohos_id_text_size_body1'))
                        .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                        .margin({
                          left: 12,
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                        })
                        .id('text_hwid_bind_phone_area_code')
                        .direction(Direction.Ltr)
                      // Drop-down arrow.
                      Image($r('app.media.hwid_ic_public_spinner'))
                        .width(12)
                        .margin({
                          right: 12
                        })
                        .draggable(false)
                      // Divider.
                      Divider()
                        .vertical(true)
                        .height(22)
                        .color($r('sys.color.ohos_id_color_list_separator'))
                    }.width('100%')
                    .enabled(false)
                    .constraintSize({
                      minHeight: 56
                    })

                  }.width('100%')
                }.width('100%')
              }
              .id('row_hwid_bind_phone')
              .padding({
                top: 8,
                bottom: 8
              })
              .width('100%')
              .height(72)
              .constraintSize({
                maxWidth: 448
              })
              .margin({
                top: this.isNeedDoubleColumn() ? 32 : -36
              })
            }
            .width(this.isNeedDoubleColumn() ? '50%' : '100%')
            .height(this.isNeedDoubleColumn() ? '100%' : this.isBigDisplay ? '50%' : '40%')
            .justifyContent(this.isNeedDoubleColumn() ? FlexAlign.Center : FlexAlign.SpaceBetween)

            Column() {
              Column() {
                // Next step.
                Column() {
                  Button({ type: ButtonType.Capsule, stateEffect: true }) {
                    Text($r('app.string.next_step'))
                      .fontColor(Color.White)
                      .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                      .focusable(true)
                      .focusOnTouch(true)
                      .id('loginPanel_huawei_id_next_step_btn_text')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .padding({ left: 4, right: 4 })
                      .textAlign(TextAlign.Center)
                  }
                  .enabled(this.allowClick)
                  .focusable(true)
                  .focusOnTouch(true)
                  .backgroundColor($r('app.color.activity_color'))
                  .constraintSize({ minHeight: 40 })
                  .width('100%')
                  .id('prepareLoginPageButton')
                  .onClick(async () => {
                    this.isLogin = true;
                    // Return to PrepareLoginPage.
                    let unionID = '';
                    try {
                      unionID = await getUnionID(this.getUIContext().getHostContext());
                    } catch (error) {
                      hilog.error(domainId, logTag,
                        `Failed to authorize, errorCode: ${error.code}, errorMsg: ${error.message}`);
                    }
                    const userInfo = this.silentLoginMap.get(unionID as string);
                    storage.setOrCreate('avatar', userInfo?.avatar);
                    storage.setOrCreate('nickName', userInfo?.nickName);
                    storage.setOrCreate('quickLoginAnonymousPhone', userInfo?.quickLoginAnonymousPhone);
                    storage.setOrCreate('isSilentLogin', userInfo?.isSilentLogin ?? false);
                    this.pageInfos?.popToName('PrepareLoginPage', true);
                  })
                }
                .height(40)
                .width('100%')
                .constraintSize({ maxWidth: 448 })

                // Sign in with the password.
                Column() {
                  LoginButton($r('app.string.pwd_login'), $r('sys.color.ohos_id_color_button_normal'),
                    $r('sys.color.ohos_id_color_text_primary'))
                }.margin({ top: 16 });

                Text($r('app.string.other_login_models'))
                  .fontSize($r('sys.float.ohos_id_text_size_body3'))
                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Center)
                  .constraintSize({ maxWidth: '100%' })
                  .textAlign(TextAlign.Center)
                  .margin({
                    top: 24,
                    bottom: 12
                  })

                Row() {
                  this.Star()
                  this.Star()
                  this.Star()
                  this.Star()
                  this.Star()
                }.alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
                .width(324)
                .padding({
                  left: 16,
                  right: 16
                })
              }
              .margin({ top: this.isNeedDoubleColumn() ? 40 : 68 })

              Row() {
                UserAgreement({
                  isSelected: this.isSelected,
                  privacyText: this.privacyText,
                  enableStatus: true,
                  pageInfos: this.pageInfos
                })
              }
              .margin({ top: 24 })
            }
            .height(this.isNeedDoubleColumn() ? '100%' : (this.isBigDisplay ? '50%' : '60%'))
            .width(this.isNeedDoubleColumn() ? '50%' : '100%')
            .margin({ left: this.isNeedDoubleColumn() ? 40 : 0 })
            .justifyContent(this.isNeedDoubleColumn() ? FlexAlign.Center : FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height('100%')
          .constraintSize({ minHeight: this.isNeedDoubleColumn() ? undefined : 600 })
        }
        .justifyContent(FlexAlign.SpaceBetween)

        .padding({
          left: this.isNeedDoubleColumn() ? 40 : 16,
          right: this.isNeedDoubleColumn() ? 40 : 16,
          bottom: this.isNeedDoubleColumn() ? 0 :
            (this.isDevice2in1 ? 16 : this.getUIContext().px2vp(this.aiBarHeight) + 16)
        })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .onBackPressed(() => {
      this.onBackPressed();
      return true;
    })
  }
}

@Builder
function LoginButton(text: Resource, bgColor: ResourceColor, fontsColor: ResourceColor, allowClick?: boolean) {
  Button({ type: ButtonType.Capsule, stateEffect: true }) {
    Text(text)
      .fontColor(fontsColor)
      .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
      .fontWeight(FontWeight.Medium)
      .fontSize(16)
      .focusable(true)
      .focusOnTouch(true)
      .id('loginPanel_huawei_id_login_btn_text')
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .padding({ left: 4, right: 4 })
  }
  .enabled(allowClick ?? true)
  .focusable(true)
  .focusOnTouch(true)
  .backgroundColor(bgColor)
  .constraintSize({ minHeight: 40, maxWidth: 448 })
  .width('100%')
}
