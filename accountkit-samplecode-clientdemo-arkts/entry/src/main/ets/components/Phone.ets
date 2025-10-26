/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { cancelAuthorization, showErrorMessage } from '../common/Utils';
import { ErrorCode } from '../common/ErrorCodeEntity';

const storage: LocalStorage = new LocalStorage();

const domainId: number = 0x0000;
const logTag: string = 'Phone';

@Component
export struct Phone {
  @Link quickLoginAnonymousPhone: string;
  onChange?: (unionID: string) => void; // Callback for updating user information after authorization.

  // Use the authorization API to obtain the user's mobile number.
  private async getPhone() {
    try {
      /*
       * This example is a pop-up window for demonstrating the authorization scenario.
       * Authorization needs to be performed again after authorization revoking.
       * This is not required for actual development.
       * */
      await cancelAuthorization();
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to cacelAuthorize. errCode: ${error.code}, errMessage: ${error.message}`);
    }
    // Create an authorization request and set parameters.
    const authRequest: authentication.AuthorizationWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    /*
     * To obtain the mobile number, the phone scope must be passed. Before this,
     * you first need to apply for the phone scope.
     * */
    authRequest.scopes = ['phone'];
    // To obtain the authorization code, pass the following permission.
    authRequest.permissions = ['serviceauthcode'];
    // The forceAuthorization parameter specifies whether to display the authorization screen.
    authRequest.forceAuthorization = true;
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    authRequest.state = util.generateRandomUUID();

    try {
      const controller: authentication.AuthenticationController =
        new authentication.AuthenticationController(this.getUIContext().getHostContext());
      controller.executeRequest(authRequest)
        .then((data: authentication.AuthenticationResponse) => {
          const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
          const state: string = authorizationWithHuaweiIDResponse.state!;
          if (state && authRequest.state !== state) {
            hilog.error(domainId, logTag, 'Failed to authorize. The state is different');
            return;
          }
          const authorizationWithHuaweiIDCredential: authentication.AuthorizationWithHuaweiIDCredential =
            authorizationWithHuaweiIDResponse.data!;
          const code: string = authorizationWithHuaweiIDCredential.authorizationCode!;

          /*
           * After obtaining the authorization code, send it to the app server.
           * The app server calls the Account Kit server API to obtain an access token,
           * and then use the access token to obtain the user's mobile number.
           * */
          // ...

          /*
           * This example is for illustrative purposes only and shows the result once authorization has been granted.
           * The actual phone number is not obtained.
           * */
          const quickLoginAnonymousPhone = storage.get('quickLoginAnonymousPhone') as string ?? '';
          this.quickLoginAnonymousPhone = quickLoginAnonymousPhone !== '' ? quickLoginAnonymousPhone : '180******00';
          // Update persistently stored data.
          if (this.onChange) {
            this.onChange(authorizationWithHuaweiIDResponse.data?.unionID as string);
          }
        })
        .catch((error: BusinessError) => {
          showErrorMessage(this.getUIContext(), error);
          this.dealAllError(error);
        })
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to authorize. errCode: ${error.code}, errMessage: ${error.message}`);
    }
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
    } else if (error.code === ErrorCode.ERROR_CODE_USER_CANCEL) {
      // The user cancels the authorization.
    } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
      // System service exception. Try again later or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
      // Repeated request. No further action is needed.
    } else {
      // Sign-in failed. Try another sign-in option.
    }
  }

  build() {
    Row() {
      Text($r('app.string.phone'))
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .fontWeight(FontWeight.Medium)
        .height('100%')
      Row() {
        Text(this.quickLoginAnonymousPhone)
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .height(19)
          .width(100)
          .padding({ left: 20 })
        Image($r('app.media.ic_public_arrow_right'))
          .fillColor($r('sys.color.ohos_id_color_foreground'))
          .opacity(0.2)
          .width(12)
          .height(24)
          .margin({ left: 4 })
          .draggable(false)
      }
      .width(115)
    }
    .width('100%')
    .height(56)
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
    .justifyContent(FlexAlign.SpaceBetween)
    .id('phoneRow')
    .onClick(() => {
      AvoidRepeatClick.avoidRepeatClick(() => {
        this.getPhone();
      });
    })
  }
}
