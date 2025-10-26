/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';
import { ErrorCode } from '../common/ErrorCodeEntity';
import { UserInfo } from '../common/UserInfo';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { AgreementDialog } from '../components/AgreementDialog';
import { UserAgreement } from '../components/UserAgreement';
import { getWhiteSpaceWidthByDisplayWidth } from '../common/Utils';

const logTag: string = 'QuickLoginPage';
const domainId: number = 0x0000;

const storage: LocalStorage = new LocalStorage();

const PRIVACY_URL = 'privacy_url'; // Key value of the link to the HUAWEI ID User Authentication Agreement.

@Component
export struct QuickLoginPage {
  @LocalStorageLink('isLogin') isLogin: boolean = false;
  @StorageLink('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>();
  // Specify whether the current screen is the one-tap sign-in screen.
  @State isSelected: boolean = false; // Specify whether the agreements are accepted.
  @LocalStorageLink('quickLoginAnonymousPhone') quickLoginAnonymousPhone?: string = undefined;
  @StorageProp('aiBarHeight') aiBarHeight: number = 0;
  @StorageProp('isFullMode') isFullMode: boolean =
    true; // This parameter indicates whether the full-screen mode is used.
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  // File used to configure the link to the HUAWEI ID User Authentication Agreement.
  private readonly srcPath = 'data.json';
  error?: BusinessError;
  response: loginComponentManager.HuaweiIDCredential = {} as loginComponentManager.HuaweiIDCredential;
  // Variable that determines whether the agreement and checkbox are unavailable for tapping during the sign-in process.
  @State enableStatus: boolean = true;
  pageInfos: NavPathStack = new NavPathStack();
  params?: Record<string, Object>;
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
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.and'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.huaweiId_user_authentication_protocol'),
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: this.getProtocolUrl(PRIVACY_URL)
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }
  ];
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    /*
     * Users need to accept relevant agreements before they can sign in wth HUAWEI IDs.
     * Set the agreement status to NOT_ACCEPTED first.
     * Once the user accepts the agreements, change the agreement status to ACCEPTED to complete HUAWEI ID sign-in.
     * */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // Process the logic of a tap on the one-tap sign-in button.
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent(() => {
        /*
         * After a tap on the one-tap sign-in button, set the button of other ways to sign in,
         * check box of the agreements, and agreement links to be unavailable.
         * */
        this.enableStatus = false;
        this.controller.setEnabled(false);
      })
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.enableStatus = true;
        this.agreementDialog.close();
        // Set the agreement status to NOT_ACCEPTED.
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.enableStatus = false;
        this.agreementDialog.close();
        this.isSelected = true;
        // Set the agreement status to ACCEPTED.
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        /*
         * Call this method to complete accepting the agreements and signing in at the same time.
         * There is no need to tap the sign-in button again.
         * */
        this.controller.continueLogin((error: BusinessError) => {
          if (error) {
            hilog.error(domainId, logTag,
              `Failed to login with agreementDialog. errCode is ${error.code}, message is ${error.message}`);
          } else {
            hilog.info(domainId, logTag, 'Succeeded in clicking agreementDialog continueLogin.');
            // After the sign-in is successful, the server processes the response result.
            // ...
          }
        });
      },
      openDialog: () => {
        this.agreementDialog.open();
      },
      closeDialog: () => {
        this.agreementDialog.close();
      },
      pageInfos: this.pageInfos
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;
  @LocalStorageProp('isBigDisplay') isBigDisplay: boolean = false;
  @LocalStorageProp('isDevice2in1') isDevice2in1: boolean = false;
  @StorageLink('unionID') unionID?: string = undefined;
  @LocalStorageLink('isUserSelected') isUserSelected: boolean = false;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'QuickLoginPage aboutToAppear');
    // Obtain the passed anonymous mobile number.
    if (this.params && this.params !== null) {
      this.quickLoginAnonymousPhone = (this.params['quickLoginAnonymousPhone'] ?? '') as string;
    }
  }

  async getQuickLoginAnonymousPhone(): Promise<string> {
    // Create an authorization request.
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // User information requested by the app.
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // In the one-tap sign-in scenario, forceAuthorization must be set to false.
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    let quickLoginAnonymousPhone: string = '';
    let unionID: string = '';
    try {
      const response: authentication.AuthorizationWithHuaweiIDResponse = await controller.executeRequest(authRequest);
      unionID = response.data?.unionID as string;
      quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string ?? '';
      hilog.info(domainId, logTag,
        `Succeeded in authorizing. unionID is ${unionID}, quickLoginAnonymousPhone is ${quickLoginAnonymousPhone}`);
      const userInfo = (this.silentLoginMap.get(unionID) ?? { isSilentLogin: false }) as UserInfo;
      if (quickLoginAnonymousPhone !== '') {
        // Save the anonymous mobile number to LocalStorage.
        storage.setOrCreate('quickLoginAnonymousPhone', quickLoginAnonymousPhone);
        userInfo.quickLoginAnonymousPhone = quickLoginAnonymousPhone;
      }
      // Update persistently stored data silentLoginMap.
      this.silentLoginMap.set(unionID, userInfo);
      return quickLoginAnonymousPhone;
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to authorize. errCode is ${error.code}, message is ${error.message}`);
      this.dealAllError(error);
      return quickLoginAnonymousPhone;
    }
  }

  // Implement timeout handling for obtaining an anonymous mobile number.
  getQuickLoginAnonymousPhoneTimer(): number {
    // Set the wait time based on actual requirements, with 5 seconds recommended.
    const waitTime: number = 5000;
    // Handle the timeout to avoid prolonged waiting.
    return setTimeout(() => {
      hilog.error(domainId, logTag, `getQuickLoginAnonymousPhone failed due to timeout: ${waitTime}`);
      this.jumpToOtherLoginPage();
    }, waitTime);
  }

  dealAllError(error: BusinessError): void {
    /*
     * In app sign-in scenarios involving UI interactions,
     * it is recommended to guide users with the following error code prompts:
     * */
    if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
      /*
       * The user has not signed in with a HUAWEI ID.
       * Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
       * */
    } else if (error.code === ErrorCode.AUTHENTICATION_NETWORK_ERROR) {
      // Network exception. Check the current network status and try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
      // Sign-in failed. Try another sign-in option.
    } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
      // System service exception. Try again later or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
      // Repeated request. No further action is needed.
    } else {
      // Sign-in failed. Try another sign-in option.
    }
  }

  // The user changes the agreement acceptance status.
  checkboxChange(value: boolean) {
    if (value) {
      // The user accepts the agreements.
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
    } else {
      // The user does not accept the agreements.
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
    }
  }

  // Method that processes a tap on the one-tap sign-in button.
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      hilog.error(domainId, logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      this.error = error;
      if (error.code === authentication.AuthenticationErrorCode.NETWORK_ERROR) {
        // A message is displayed, indicating that the network is not connected.
        this.getUIContext().showAlertDialog(
          {
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
          }
        );
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        /*
         * If a user does not accept the agreements,
         * an agreement dialog box will be displayed. This callback method is recommended.
         * */
        this.agreementDialog.open();
      } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // An message is displayed, indicating that no HUAWEI ID is signed in.
        this.showToast($r('app.string.not_login_in'));
      } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // Unsupported scope or permission.
        this.showToast($r('app.string.scope_not_supported'));
      } else if (error.code === ErrorCode.AUTHENTICATION_USER_CANCELED) {
        // Sign-in operation canceled. No further action is required.
      } else {
        // The system or service is abnormal. Handle the problem based on the site requirements.
        this.showToast($r('app.string.service_error'));
        // To handle other error codes, please refer to the error code part in the Account Kit API Reference.

      }
      this.enableStatus = true;
      this.controller.setEnabled(true);
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(domainId, logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          if (!this.response.unionID) {
            this.response = response;
          }
          const authCode = response.authorizationCode;
          const unionID = response.unionID;

          // Process code.
          // After sign-in to the app is successful, process the server sign-in execution logic here.
          // ...

          // After sign-in on the server is successful, the data to be displayed on the main screen is returned.
          // ...

          // In this example, the sign-in status is directly changed and PrepareLoginPage is displayed.
          this.isLogin = true;
          const userInfo = this.silentLoginMap.get(unionID as string);
          storage.setOrCreate('avatar', userInfo?.avatar);
          storage.setOrCreate('nickName', userInfo?.nickName);
          storage.setOrCreate('quickLoginAnonymousPhone', userInfo?.quickLoginAnonymousPhone);
          storage.setOrCreate('isSilentLogin', userInfo?.isSilentLogin ?? false);
          this.pageInfos?.popToName('PrepareLoginPage', true);
        }
      } else {
        this.agreementDialog.open();
      }
    } catch (error) {
      hilog.info(domainId, logTag,
        `Failed to login with LoginWithHuaweiIDButton, errCode: ${error.code}, errMessage: ${error.message}`);
      this.getUIContext().showAlertDialog(
        {
          message: $r('app.string.service_error'),
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Center,
          autoCancel: false,
          confirm: {
            value: $r('app.string.hwid_text_button_known'),
            action: () => {
            }
          }
        }
      );
    } finally {
      this.enableStatus = true;
      this.controller.setEnabled(true);
    }
  }

  // Toast message.
  showToast(resource: Resource) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      const message = (error as BusinessError).message;
      const code = (error as BusinessError).code;
      hilog.error(domainId, logTag, `Failed to showToast, errCode is ${code}, errMessage is ${message}`);
    }
  }

  // Redirect to the screen for another way to sign in.
  jumpToOtherLoginPage(isUserSelected: boolean = false) {
    // Redirect to the screen for another way to sign in.
    this.isUserSelected = isUserSelected;
    if (isUserSelected) {
      this.pageInfos?.pushPathByName('OtherLoginPage', null, true);
    } else {
      this.pageInfos?.replacePathByName('OtherLoginPage', null, false);
    }
  }

  // Obtain the privacy policy address from rawfile.
  getProtocolUrl(privacyUrl: string): string {
    try {
      // Read files from /AppScope/resources/rawfile.
      const value: Uint8Array | undefined =
        this.getUIContext().getHostContext()?.resourceManager?.getRawFileContentSync(this.srcPath);
      // Return the link to the HUAWEI ID User Authentication Agreement.
      return JSON.parse(buffer.from(value?.buffer).toString())[privacyUrl] as string;
    } catch (error) {
      hilog.error(domainId, logTag, `getProtocolUrl Error, errCode: ${error.code}, Message: ${error.message}`);
      return ''
    }
  }

  // This parameter indicates whether to display the content in two columns.
  isNeedDoubleColumn(): boolean {
    return this.isPhone && this.isLandScape && this.isFullMode;
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
        .id('quickLoginAppBackButton')
        .onClick(() => {
          AvoidRepeatClick.avoidRepeatClick(() => {
            if (this.pageInfos && this.pageInfos.size() > 0) {
              this.pageInfos.pop();
            }
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
        top: 56 + (this.isNeedDoubleColumn() || this.isDevice2in1 ? 0 : this.getUIContext().px2vp(this.statusBarHeight))
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
              .height(this.isNeedDoubleColumn() ? 80 : '100%')

              // Mobile number and its description.
              Column() {
                Text(this.quickLoginAnonymousPhone)
                  .fontSize(36)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(48)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%', minHeight: 48 })

                Text($r('app.string.bind_huaweiId_number'))
                  .fontSize(12)
                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(16)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%' })
                  .margin({ top: 8 })
              }
              .margin({ top: this.isNeedDoubleColumn() ? 32 : -36 })
            }
            .width(this.isNeedDoubleColumn() ? '50%' : '100%')
            .height(this.isNeedDoubleColumn() ? '100%' : this.isBigDisplay ? '50%' : '40%')
            .justifyContent(this.isNeedDoubleColumn() ? FlexAlign.Center : FlexAlign.SpaceBetween);

            Column() {
              // Two sign-in buttons.
              Column() {
                // One-tap sign-in.
                Column() {
                  LoginWithHuaweiIDButton({
                    params: {
                      // Custom button style.
                      style: loginComponentManager.Style.BUTTON_CUSTOM,
                      extraStyle: {
                        buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                          show: true
                        })
                      },
                      loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                      supportDarkMode: true,
                    },
                    controller: this.controller
                  }).id('login_with_huaweiId_button')
                }
                .height(40)
                .width('100%')
                .constraintSize({
                  minHeight: 40,
                  maxWidth: 448
                })

                // Other ways to sign in.
                Column() {
                  Button({
                    type: ButtonType.Capsule,
                    stateEffect: true
                  }) {
                    Text($r('app.string.other_login_models'))
                      .fontColor($r('sys.color.ohos_id_color_focused_content_primary'))
                      .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_button1'))
                      .focusable(true)
                      .focusOnTouch(true)
                      .id('loginPanel_huawei_id_other_login_btn_text')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .padding({ left: 8, right: 8 })
                  }
                  .id('loginPanel_other_login_btn')
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .focusable(true)
                  .focusOnTouch(true)
                  .enabled(this.enableStatus)
                  .width('100%')
                  .constraintSize({
                    minHeight: 40,
                    maxWidth: 448
                  })
                  .onClick(() => {
                    // Redirect to the screen for another way to sign in.
                    AvoidRepeatClick.avoidRepeatClick(() => {
                      // Redirect to the custom sign-in screen.
                      if (this.enableStatus) {
                        this.jumpToOtherLoginPage(true);
                      }
                    }, 200);
                  })
                }.margin({ top: 16 })
              }
              .margin({ top: this.isNeedDoubleColumn() ? 0 : 92 })

              // Agreement.
              Row() {
                UserAgreement({
                  isSelected: this.isSelected,
                  privacyText: this.privacyText,
                  enableStatus: this.enableStatus,
                  pageInfos: this.pageInfos,
                  onChange: (value) => {
                    this.checkboxChange(value);
                  }
                })
              }
              .margin({
                top: 24,
                bottom: this.isNeedDoubleColumn() ? 0 :
                  (this.isDevice2in1 ? 16 : this.getUIContext().px2vp(this.aiBarHeight) + 16)
              })
            }
            .height(this.isNeedDoubleColumn() ? '100%' : (this.isBigDisplay ? '50%' : '60%'))
            .width(this.isNeedDoubleColumn() ? '50%' : '100%')
            .margin({
              left: this.isNeedDoubleColumn() ? 40 : 0
            })
            .justifyContent(this.isNeedDoubleColumn() ? FlexAlign.Center : FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height('100%')
          .constraintSize({ minHeight: this.isNeedDoubleColumn() ? undefined : 600 })
        }
        .padding({
          left: this.isNeedDoubleColumn() ? 40 : 16,
          right: this.isNeedDoubleColumn() ? 40 : 16
        })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width('100%')
    }
    .hideTitleBar(true)
    .onShown(async () => {
      hilog.info(domainId, logTag, 'QuickLoginPage onShown');
      try {
        // Set the timeout handling strategy for obtaining an anonymous mobile number.
        const timer: number = this.getQuickLoginAnonymousPhoneTimer();
        this.quickLoginAnonymousPhone = await this.getQuickLoginAnonymousPhone();
        if (timer !== undefined) {
          clearTimeout(timer);
        }
        if (!this.quickLoginAnonymousPhone) {
          /*
           * If the newly signed-in HUAWEI ID is not bound to a mobile number,
           * the user will be redirected to the screen for another way to sign in.
           * */
          this.jumpToOtherLoginPage();
        }
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to authorize, errorCode: ${error.code}, errorMsg: ${error.message}`);
        this.jumpToOtherLoginPage();
      }
    })
  }
}
