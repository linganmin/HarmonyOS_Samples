/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */

import { hilog } from "@kit.PerformanceAnalysisKit";
import { ErrorCode } from "./ErrorCodeEntity";
import { BusinessError } from "@kit.BasicServicesKit";
import { authentication } from "@kit.AccountKit";

const domainId = 0x0000;
const logTag = 'Utils';

export function dealAllError(error: BusinessError): void {
  const showErrorCode = error.code ? `errorCode: ${error.code}, ` : '';
  const showErrorMessage = error.message ? `errorMsg: ${error.message}` : '';
  hilog.error(domainId, logTag, `${showErrorCode}${showErrorMessage}`);
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
    showNetWorkError();
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

export function showNetWorkError() {
  const uiContext = AppStorage.get('uiContext') as UIContext;
  uiContext.showAlertDialog({
    message: $r('app.string.hwid_no_internet_connect'),
    offset: { dx: 0, dy: -12 },
    alignment: DialogAlignment.Center,
    autoCancel: false,
    confirm: {
      value: $r('app.string.hwid_text_button_known'),
      action: () => {
      }
    }
  })
}

// Obtain the anonymous mobile number.
export async function getQuickLoginAnonymousPhone(waitTime = 5000): Promise<string> {
  // Create an authorization request.
  const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
  // User information requested by the app.
  authRequest.scopes = ['quickLoginAnonymousPhone'];
  // In the one-tap sign-in scenario, forceAuthorization must be set to false.
  authRequest.forceAuthorization = false;
  const controller = new authentication.AuthenticationController();
  return new Promise((resolve: (str: string) => void, reject: (err: BusinessError) => void) => {
    controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
      /*
       * If code obfuscation is enabled,
       * configure a trustlist for the quickLoginAnonymousPhone attribute to prevent it from being obfuscated.
       * */
      const quickLoginAnonymousPhone = response?.data?.extraInfo?.quickLoginAnonymousPhone as string ?? '';
      if (quickLoginAnonymousPhone !== '') {
        AppStorage.setOrCreate('quickLoginAnonymousPhone', quickLoginAnonymousPhone);
      }
      resolve(quickLoginAnonymousPhone);
    }).catch(reject);

    // Set the timeout interval. If the timeout interval is exceeded, a network error will be returned.
    setTimeout(reject, waitTime, {
      code: ErrorCode.AUTHENTICATION_NETWORK_ERROR,
      message: 'Network error.'
    });
  });
}

export class AvoidRepeatClick {
  static lastClickTime: number = 0; // Record the time of the last repeated tap.
  public static avoidRepeatClick(callback: VoidCallback, interval: number = 400) {
    const currentTime = Date.now();
    if (Math.abs(currentTime - AvoidRepeatClick.lastClickTime) > interval) {
      AvoidRepeatClick.lastClickTime = currentTime;
      hilog.info(domainId, logTag, 'Effective click');
      callback();
    } else {
      hilog.info(domainId, logTag, 'Invalid click');
    }
  }
}
