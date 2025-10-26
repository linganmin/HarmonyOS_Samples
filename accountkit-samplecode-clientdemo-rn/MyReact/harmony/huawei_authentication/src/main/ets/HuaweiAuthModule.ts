/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { UITurboModule } from '@rnoh/react-native-openharmony/ts';
import { TM } from "@rnoh/react-native-openharmony/generated/ts"
import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication } from '@kit.AccountKit';

export const logTag: string = 'AccountDemo';

export const domainId: number = 0x0000;

export class HuaweiAuthModule extends UITurboModule implements TM.HuaweiAuthTurboModule.Spec {
  getQuickLoginAnonymousPhone(): Promise<TM.HuaweiAuthTurboModule.HuaweiAuthRequestResponse> {
    hilog.info(domainId, logTag, "GetQuickLoginAnonymousPhone");
    let result: Promise<TM.HuaweiAuthTurboModule.HuaweiAuthRequestResponse> = this.getAnonymousPhone();
    return result;
  }

  async getAnonymousPhone(): Promise<TM.HuaweiAuthTurboModule.HuaweiAuthRequestResponse> {
    let result: TM.HuaweiAuthTurboModule.HuaweiAuthRequestResponse = {
      data: {
        authorizedScopes: [],
        extraInfo: {
          localNumberConsistency: false,
          quickLoginAnonymousPhone: ''
        }
      },
      errorCode: '',
      errorMessage: ''
    };
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    authRequest.forceAuthorization = false;
    let controller = new authentication.AuthenticationController();
    try {
      const authResponse = await controller.executeRequest(authRequest);
      let response = authResponse as authentication.AuthorizationWithHuaweiIDResponse;
      result.data.authorizedScopes = authRequest.scopes;
      result.data.extraInfo.localNumberConsistency = response.data?.extraInfo?.localNumberConsistency as boolean;
      result.data.extraInfo.quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
      hilog.info(domainId, logTag, `Succeeded in getQuickLoginAnonymousPhone`);
      return result;
    } catch (error) {
      hilog.error(domainId, logTag, `Failed to getQuickLoginAnonymousPhone, error: ${JSON.stringify(error)}`);
      result.errorCode = error.code.toString();
      result.errorMessage = error.message;
      return result;
    }
  }
}
