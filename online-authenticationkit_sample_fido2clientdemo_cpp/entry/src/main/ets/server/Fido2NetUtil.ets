/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { http } from '@kit.NetworkKit'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

const DOMAIN = 0x0000;
const TAG = '[fido2ndk]';

export class Fido2NetUtil{
  // FIDO server address configured by the developer.
  public static url: string = 'xxx.xxx.xxx';
  public static regChallengeReq = 'attestation/options'
  public static regChallengeResp = 'attestation/result'
  public static authChallengeReq = 'assertion/options'
  public static authChallengeResp = 'assertion/result'
  public static authChallenge = 'authChallenge'
  public static textUrl = 'https://www.baidu.com'

  public static Base64UrlDec(input:string): Uint8Array{
    let helper = new util.Base64Helper()
    let uArray = helper.decodeSync(input, util.Type.BASIC_URL_SAFE)
    return uArray
  }

  public static  base64UrlEncByBytes(input: Uint8Array|undefined): string{
    let result = new util.Base64Helper().encodeToStringSync(input,util.Type.BASIC_URL_SAFE);
    return result;
  }

  public static urlSafeBase64Dec(base64url: string): Uint8Array {
    let base64: string = base64url.replace(/-/g, '+').replace(/_/g, '/');
    while (base64.length % 4) {
      base64 += '=';
    }
    return new util.Base64Helper().decodeSync(base64);
  }

  public static connectFidoServer(url: string, data: string): Promise<string>  {
    return new Promise((resolve) => {
      if (url != null && url.length > 0) {
        let httpRequest = http.createHttp()
        httpRequest.request(
          url,
          {
            // Optional.The default value is http.RequestMethod.GET.
            method: http.RequestMethod.POST,

            // Developers can add header fields according to their business needs.
            header: {
              'Content-Type': 'application/json'
            },
            // Optional.The default value is 1.
            priority: 1,
            // Optional.The default value is 60000ms.
            connectTimeout: 60000,
            // Optional.The default value is 60000ms.
            readTimeout: 60000,
            // This field is used to pass content when using POST requests.
            extraData: data,

          }, (err, data) => {
            if (err) {
              hilog.info(DOMAIN, TAG, 'response error: ' + JSON.stringify(err));
            }
            if (!err) {
              hilog.info(DOMAIN, TAG, 'response data: ' + JSON.stringify(data));
              let result = data.result.toString()
              let fido2Response: Fido2Response = JSON.parse(result)
              if (fido2Response.status === 'OK') {
                httpRequest.destroy();
                resolve(fido2Response.fido2Response);
              } else {
                promptAction.openToast({
                  message: `请求失败, ${fido2Response.status}! `,
                  duration: 2000
                });
              }
            } else {
              promptAction.openToast({
                message: `服务器域名错误!, ${JSON.stringify(err)}! `,
                duration: 2000
              });
            }
         })
      }
    })
  }

  public static getRegRequest(name: string, displayName: string): AdapterServerRequest{
    let authenticatorSelection: AuthenticatorSelection = {
      userVerification: 'preferred',
      residentKey: "preferred",
      requireResidentKey: true,
      authenticatorAttachment: 'platform'
    };

    let fido2CredentialCreationOptions:Fido2CredentialCreationOptions= {
      username: name,
      displayName: displayName,
      attestation: 'direct',
      authenticatorSelection:authenticatorSelection
    }

    let adapterServerRequest: AdapterServerRequest = {
      username: name,
      displayName: displayName,
      fido2CredentialCreationOptions: JSON.stringify(fido2CredentialCreationOptions)
    };

    return adapterServerRequest;
  }
}

interface Fido2CredentialCreationOptions{
  username: string;
  displayName: string;
  extensions?: Map<String, Object> ;
  authenticatorSelection?: AuthenticatorSelection;
  attestation: string;
}

interface AdapterServerRequest {
  username: string;
  displayName: string;
  fido2CredentialCreationOptions:string
}

interface AuthenticatorSelection {
  userVerification: string;
  residentKey: string;
  authenticatorAttachment: string;
  requireResidentKey: boolean;
}

interface Fido2Response {
  status: string;
  errorMessage: string;
  fido2Response: string;
}














