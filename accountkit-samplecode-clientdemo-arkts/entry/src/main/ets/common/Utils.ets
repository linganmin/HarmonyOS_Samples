/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { ErrorCode } from '../common/ErrorCodeEntity';

const domainId: number = 0x0000;
const logTag: string = 'Utils';

// Show error information.
export function showErrorMessage(context: UIContext, error: BusinessError): void {
  const userCanceled: number[] = [
    ErrorCode.SHIPPING_ADDRESS_USER_CANCELED, // The operation for obtaining the shipping address is canceled.
    ErrorCode.INVOICE_ASSISTANT_USER_CANCELED, // The operation for obtaining the invoice title is canceled.
    ErrorCode.AUTHENTICATION_USER_CANCELED// Authorization revoking is performed.
  ];

  const networkError: number[] = [
    // A network exception occurred in the API for obtaining the shipping address.
    ErrorCode.SHIPPING_ADDRESS_NETWORK_ERROR,
    // A network exception occurs in the authorization API.
    ErrorCode.AUTHENTICATION_NETWORK_ERROR,
    // A network exception occurred in the API for obtaining the invoice title.
    ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR
  ];
  hilog.error(domainId, logTag,
    `Failed to authorize. BusinessError errCode: ${error.code}, message: ${error.message}`);
  if (networkError.includes(error.code)) {
    // AlertDialog is used to indicate network exceptions.
    context.showAlertDialog({
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
  } else if (!userCanceled.includes(error.code)) {
    try {
      // Use showToast to notify other errors that are not caused by user cancellation.
      context.getPromptAction().showToast({ message: error.message, duration: 2000 });
    } catch (error) {
      const message = (error as BusinessError).message;
      const code = (error as BusinessError).code;
      hilog.error(domainId, logTag, `Failed to showToast, errCode is ${code}, errMessage is ${message}`);
    }
  }
}

// Revoke authorization.
export function cancelAuthorization(): Promise<void> {
  return new Promise((resolve, reject) => {
    // Create an authorization revoking request and set parameters.
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    cancelRequest.state = util.generateRandomUUID();
    // Execute the request.
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state: string = cancelAuthorizationResponse.state!;
        if (cancelRequest.state !== state) {
          hilog.error(domainId, logTag, 'Failed to cancel. The state is different');
          reject({ message: 'The state is different' });
        }
        resolve();
      }).catch((err: BusinessError) => {
        hilog.error(domainId, logTag,
          `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
        reject(err);
      })
    } catch (err) {
      hilog.error(domainId, logTag, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      reject(err);
    }
  })
}

// Call the authorization API to obtain the UnionID of the user who has signed in with the HUAWEI ID.
export function getUnionID(context: Context | undefined): Promise<string> {
  return new Promise((resolve, reject) => {
    const authRequest: authentication.AuthorizationWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // Set scope to openid. The openid scope is available by default. No application is needed.
    authRequest.scopes = ['openid'];
    // The forceAuthorization parameter specifies whether to display the authorization screen.
    authRequest.forceAuthorization = false;
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    authRequest.state = util.generateRandomUUID();

    // Execute the authorization request.
    new authentication.AuthenticationController(context).executeRequest(authRequest)
      .then((data: authentication.AuthenticationResponse) => {
        const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        const state: string = authorizationWithHuaweiIDResponse.state!;
        if (authRequest.state !== state) {
          hilog.error(domainId, logTag, 'Failed to authorize. The state is different');
          reject({ message: 'The state is different', code: 0 } as BusinessError);
        } else {
          const unionID = authorizationWithHuaweiIDResponse.data?.unionID as string;
          resolve(unionID);
        }
      })
      .catch((error: BusinessError) => {
        hilog.error(domainId, logTag, `Failed to authorize. errCode: ${error.code}, errMessage: ${error.message}`);
        reject(error);
      });
  });
}

// Adjust the page margins based on the screen width.
export function getWhiteSpaceWidthByDisplayWidth(displayWidth: number): number {
  // Constant used to define page margins.
  const FIRST_PADDING: number = 16;
  const SECOND_PADDING: number = 24;
  const THIRD_PADDING: number = 32;

  // Define the screen area.
  const FIRST_DISPLAY_WIDTH: number = 400;
  const SECOND_DISPLAY_WIDTH: number = 800;

  if (displayWidth <= FIRST_DISPLAY_WIDTH) {
    return FIRST_PADDING;
  } else if (displayWidth > FIRST_DISPLAY_WIDTH && displayWidth <= SECOND_DISPLAY_WIDTH) {
    return SECOND_PADDING;
  } else {
    return THIRD_PADDING;
  }
}
