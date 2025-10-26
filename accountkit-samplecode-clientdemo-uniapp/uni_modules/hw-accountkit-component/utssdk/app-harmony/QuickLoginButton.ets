/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { dealAllError } from ".";

// Define the data that uni-app passes to the one-tap sign-in page.
interface QuickLoginParams extends NativeEmbedBuilderOptions {
  noNetCnt?: number,
  isUserAgree: boolean,
  isContinueLogin?: boolean
}

// Define the data that the one-tap sign-in page passes to uni-app.
interface onQuickLoginResponseDetail {
  quickLoginResponse?: loginComponentManager.HuaweiIDCredential,
  isUserAgree: boolean,
  isDisabled: boolean
}

// Place all data that the component should return to uni-app within the specified field in detail.
interface onQuickLoginResponseData {
  detail: onQuickLoginResponseDetail
}

const logTag: string = 'QuickLoginPage';
const domainId: number = 0x0000;

@Component
struct QuickLoginButton {
  @Prop @Watch('setAgreementStatus') isUserAgree?: boolean;
  @Prop @Watch('networkChange') noNetCnt?: number = 0;
  @Prop @Watch('needContinueLogin') isContinueLogin?: boolean = false;
  onQuickLoginResponseCallBack?: Function;
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    /**
     * Users need to accept relevant agreements before they can sign in wth HUAWEI IDs.
     * Set the agreement status to NOT_ACCEPTED first.
     * Once the user accepts the agreements, change the agreement status to ACCEPTED to complete HUAWEI ID sign-in.
     */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // Process the logic of a tap on the one-tap sign-in button.
        try {
          if (response) {
            hilog.info(domainId, logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
            if (this.onQuickLoginResponseCallBack) {
              this.onQuickLoginResponseCallBack({
                detail: { quickLoginResponse: response, isUserAgree: !!this.isUserAgree }
              } as onQuickLoginResponseData);
              hilog.info(domainId, logTag, 'Succeeded in executing onQuickLoginResponseCallBack.');
            }
          }
          if (error) {
            hilog.error(domainId, logTag,
              `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
            dealAllError(error, () => {
              if (this.onQuickLoginResponseCallBack) {
                this.onQuickLoginResponseCallBack({ detail: { isDisabled: false } } as onQuickLoginResponseData);
              }
			  const hasNet: boolean = connection.hasDefaultNetSync();
              if (!hasNet) {
                this.showNoNetWork();
              }
            });
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
        }
      })
      .onClickEvent(() => {
        /**
         * After a tap on the one-tap sign-in button, set the button of other ways to sign in,
         * check box of the agreements, and agreement links to be unavailable.
         */
        if (this.isUserAgree) {
          if (this.onQuickLoginResponseCallBack) {
            this.onQuickLoginResponseCallBack({ detail: { isDisabled: true } } as onQuickLoginResponseData);
            hilog.info(domainId, logTag, 'user does not agree the privacy.');
          }
          this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        }
      })

  networkChange() {
    if (this.noNetCnt) {
      this.showNoNetWork();
    }
  }

  setAgreementStatus() {
    if (this.isUserAgree) {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
    } else {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
    }
  }

  showNoNetWork() {
    this.getUIContext().showAlertDialog({
      message: $r('app.string.hwid_no_internet_connect'),
      offset: { dx: 0, dy: -12 },
      alignment: DialogAlignment.Center,
      autoCancel: false,
      confirm: {
        value: $r('app.string.hwid_text_button_known'),
        action: () => {
        }
      }
    });
  }

  needContinueLogin() {
    if (this.isContinueLogin) {
      if (this.onQuickLoginResponseCallBack) {
		  this.onQuickLoginResponseCallBack({
		    detail: { isUserAgree: true, isDisabled: true }
		  } as onQuickLoginResponseData);
	  }
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
      /**
       * Call this method to complete accepting the agreements and signing in at the same time.
       * There is no need to tap the sign-in button again.
       */
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
    }
  }

  build() {
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
      .width('100%')
      .height(40)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}

@Builder
function LoginButtonBuilder(quickloginparams: QuickLoginParams) {
  QuickLoginButton({
    noNetCnt: quickloginparams.noNetCnt ?? 0,
    isUserAgree: quickloginparams.isUserAgree,
    isContinueLogin: quickloginparams.isContinueLogin ?? false,
    onQuickLoginResponseCallBack: quickloginparams?.on?.get('quick_login_response')
  })
    .width(quickloginparams.width)
    .height(quickloginparams.height)
}

// Declare the components that need to be embedded into uni-app.
defineNativeEmbed('quickloginbutton', {
  builder: LoginButtonBuilder
})