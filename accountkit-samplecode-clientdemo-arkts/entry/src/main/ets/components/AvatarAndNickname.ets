/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { cancelAuthorization, showErrorMessage } from '../common/Utils';
import { ErrorCode } from '../common/ErrorCodeEntity';

const domainId: number = 0x0000;
const logTag: string = 'AvatarAndNickname';

@Component
export struct AvatarAndNickname {
  @Link avatar: string;
  @Link nickName: string;
  onChange?: (unionID: string) => void; // Callback for updating user information after authorization.

  // Obtain the avatar and nickname.
  private async getAvatarAndNickName() {
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
    // To obtain the avatar and nickname, pass the following scope:
    authRequest.scopes = ['profile'];
    // The forceAuthorization parameter specifies whether to display the authorization screen.
    authRequest.forceAuthorization = true;
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    authRequest.state = util.generateRandomUUID();

    // Execute the authorization request.
    try {
      const controller: authentication.AuthenticationController =
        new authentication.AuthenticationController(this.getUIContext().getHostContext());
      controller.executeRequest(authRequest)
        .then((data: authentication.AuthenticationResponse) => {
          const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
          const state: string = authorizationWithHuaweiIDResponse.state!;
          if (authRequest.state !== state) {
            hilog.error(domainId, logTag, 'Failed to authorize. The state is different');
            return;
          }
          const authorizationWithHuaweiIDCredential: authentication.AuthorizationWithHuaweiIDCredential =
            authorizationWithHuaweiIDResponse.data!;
          this.avatar = authorizationWithHuaweiIDCredential.avatarUri!;
          this.nickName = authorizationWithHuaweiIDCredential.nickName!;
          const unionID = authorizationWithHuaweiIDResponse.data?.unionID as string;
          if (this.onChange) {
            this.onChange(unionID);
          }
        })
        .catch((error: BusinessError) => {
          showErrorMessage(this.getUIContext(), error);
          this.dealAllError(error);
        });
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
    // Avatar and nickname.
    Row() {
      Row() {
        Image(this.avatar ? this.avatar : $r('app.media.dear_user'))
          .borderRadius(20)
          .draggable(false)
          .height(40)
          .width(40)
          .margin({
            left: 4,
            right: 12
          })

        Text(this.nickName ? this.nickName : $r('app.string.dearUser'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)
      }

      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(0.2)
        .width(12)
        .height(24)
        .draggable(false)
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 12 })
    .border({
      width: 2,
      color: AppStorage.get('colorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
        $r('sys.color.ohos_fa_list_card_bg') : Color.Transparent,
      radius: 20
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .id('dearUserRow')
    .onClick(() => {
      AvoidRepeatClick.avoidRepeatClick(() => {
        this.getAvatarAndNickName();
      });
    })
  }
}
