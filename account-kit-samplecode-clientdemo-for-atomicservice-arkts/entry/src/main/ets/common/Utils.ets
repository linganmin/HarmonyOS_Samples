/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { ErrorCode } from './ErrorCodeEntity';
import { bundleManager } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

const domainId: number = 0x0000;
const logTag: string = 'Utils';

// Revoke authorization.
export function cancelAuthorization() {
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
        return;
      }
    }).catch((err: BusinessError) => {
      hilog.error(domainId, logTag,
        `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      dealAllError(err);
    })
  } catch (err) {
    hilog.error(domainId, logTag, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
  }
}

export function dealAllError(error: BusinessError): void {
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

// Show the error message.
export function showErrorMessage(context: UIContext, error: BusinessError) {
  const userCanceled: number[] = [
    ErrorCode.SHIPPING_ADDRESS_USER_CANCELED, // The operation for obtaining the shipping address is canceled.
    ErrorCode.INVOICE_ASSISTANT_USER_CANCELED, // The operation for obtaining the invoice title is canceled.
    ErrorCode.AUTHENTICATION_USER_CANCELED, // Authorization revoking is performed.
    ErrorCode.EXTEND_SERVICE_USER_CANCELED// The operation for obtaining the avatar is canceled.
  ];

  const networkError: number[] = [
    ErrorCode.SHIPPING_ADDRESS_NETWORK_ERROR,
    // A network exception occurred in the API for obtaining the shipping address.
    ErrorCode.AUTHENTICATION_NETWORK_ERROR, // A network exception occurs in the authorization API.
    ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR,
    // A network exception occurred in the API for obtaining the invoice title.
    ErrorCode.EXTEND_SERVICE_NETWORK_ERROR// A network exception occurred in the API for obtaining the avatar.
  ];
  hilog.error(domainId, logTag,
    `Failed to obtain data. BusinessError errCode: ${error.code}, Message: ${error.message}`);

  // Network exception.
  if (networkError.includes(error.code)) {
    if (error.code === ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR) {
      // The network exception that occurred in the API for obtaining the avatar has been handled in the FunctionalButton component.
      return;
    }
    context.showAlertDialog({
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
  } else if (!userCanceled.includes(error.code)) {
    // Other exceptions not caused by user cancellations.
    try {
      context.getPromptAction().showToast({ message: error.message, duration: 2000 });
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to show toast. BusinessError errCode: ${error?.code}, Message: ${error?.message}`);
    }
  }
}

// Copy the file.
export function copyFile(context: UIContext, fileUri: string): string | undefined {
  // Obtain the file name.
  const fileName = fileUri.split('/').pop();
  // Obtain ApplicationContext.
  const appContext = context.getHostContext()?.getApplicationContext();
  // Select tempDir as the file storage location.
  const dest = `${appContext?.tempDir}/${fileName}`;
  try {
    // Obtain bundle name, which is used to concatenate the file sandbox address.
    const bundleName = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT).name;
    hilog.info(domainId, logTag, `Succeeded in obtaining bundleName: ${bundleName}`);

    // Use the read-only mode to obtain the file object to which fileUri points.
    const srcFile = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
    hilog.info(domainId, logTag, `Succeeded in reading srcFile, srcFile.fd: ${srcFile.fd}`);

    // Use the write or create method to obtain the target file object.
    const destFile = fileIo.openSync(dest, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
    hilog.info(domainId, logTag, `Succeeded in reading destFile, srcFile.fd: ${destFile.fd}`);

    // Copy the file.
    fileIo.copyFileSync(srcFile.fd, destFile.fd);
    hilog.info(domainId, logTag, 'Succeeded in copying file');

    // Concatenate and return the address.
    return `file://${bundleName}/${dest}`;
  } catch (error) {
    hilog.error(domainId, logTag, `Failed to do file operations errCode: ${error.code}, errMessage: ${error.message}`);
    return fileUri;
  }
}
