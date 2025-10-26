/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import common from '@ohos.app.ability.common';
import { fido2 } from '@kit.OnlineAuthenticationKit'
import { PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import { util } from '@kit.ArkTS';
import { Fido2NetUtil } from '../server/Fido2NetUtil';
import { ServerPublicKeyCredentialCreationOptions } from '../server/ServerPublicKeyCredentialCreationOptions';
import { ServerPublicKeyCredentialCreation } from '../server/ServerPublicKeyCredentialCreation';
import { ServerAuthenticatorAttestationResponse } from '../server/ServerAuthenticatorAttestationResponse';
import { ServerPublicKeyCredentialRequest } from '../server/ServerPublicKeyCredentialRequest';
import { ServerAuthenticatorAssertionResponse } from '../server/ServerAuthenticatorAssertionResponse';
import { ServerPublicKeyCredentialRequestOptions } from '../server/ServerPublicKeyCredentialRequestOptions';

import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  uiContext1: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext1.getPromptAction();
  public credentialId: Uint8Array = Base64UrlDec('VxkfFdkG-DBpnzO6NYqwbw');
  uiContext: common.UIAbilityContext = this.uiContext1.getHostContext() as common.UIAbilityContext;

  private MARGIN_BUTTON_TO_BUTTON = 8
  private BUTTON_HEIGHT = 40
  private BUTTON_WIDTH = 328
  private MENU_HEIGHT = 164
  private MENU_WIDTH = 328

  build() {
    Column() {
      Text('Online Authentication Kit示例')
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bolder)
        .margin({ top: 75 })

      Stack() {
        Column() {
          Text('通行密钥服务')
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_S'))
          Text('本示例主要展示通行密钥的移动端的线上快速身份认证能力。')
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_tertiary'))
            .width('80%')
        }
        .justifyContent(FlexAlign.SpaceEvenly)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height(this.MENU_HEIGHT)
        .width(this.MENU_WIDTH)
        .borderRadius(12)
      }
      .margin({ top: 25 })

      Column() {
        Button() {
          Text('获取能力列表')
            .fontFamily('HarmonyHeiTi')
            .fontColor('#0A59F7')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin(this.MARGIN_BUTTON_TO_BUTTON)
        .height(this.BUTTON_HEIGHT)
        .width(this.BUTTON_WIDTH)
        .onClick(async () => {
          try {
            const isLocationAvailable = canIUse('SystemCapability.Security.FIDO2');
            if (isLocationAvailable) {
              console.log('isLocationAvailable=' + `${isLocationAvailable}`);
            } else {
              console.log('Location not by this device.');
            }

            // getClientCapabilities start.
            let data_start = new Date().getTime();
            /*
             * Invoke the getClientCapabilities capability on the client side to check whether the
             * client currently supports the function.True indicates that the function is supported.
             */
            if (canIUse('SystemCapability.Security.FIDO2')) {
              await fido2.getClientCapabilities(this.uiContext);
            } else {
              this.promptAction.openToast({
                message: "获取能力列表失败! 没有权限",
                duration: 2000
              });
              return;
            }

            // getClientCapabilities end.
            let data_end = new Date().getTime();

            try {
              this.promptAction.openToast({
                message: "获取能力列表成功! " + '耗时：' + (data_end - data_start) / 1000 + "秒",
                duration: 2000
              });
            } catch (error) {
              // openToast failure message.
              let message = (error as BusinessError).message;
              // openToast failed error code.
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          } catch (error) {
            // getClientCapabilities Failure error message.
            let message = (error as BusinessError).message;
            // getClientCapabilities Failure error code.
            let code = (error as BusinessError).code;
            try {
              this.promptAction.openToast({
                message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                duration: 5000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          }
        })

        Button() {
          Text('获取平台认证器能力')
            .fontFamily('HarmonyHeiTi')
            .fontColor('#0A59F7')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin(this.MARGIN_BUTTON_TO_BUTTON)
        .height(this.BUTTON_HEIGHT)
        .width(this.BUTTON_WIDTH)
        .onClick(async () => {
          try {
            // getPlatformAuthenticators start.
            let data_start = new Date().getTime();
            /*
             * Invoke the getPlatformAuthenticators capability on the client side
             * to obtain the list of supported platform authenticators.
             */
            if (canIUse('SystemCapability.Security.FIDO2')) {
              let platformAuthenticators: Array<fido2.AuthenticatorMetadata> = await fido2.getPlatformAuthenticators(this.uiContext);
              hilog.info(0x000, 'fido2...', 'ret: ' + JSON.stringify(platformAuthenticators[0].isAvailable));
            } else {
              this.promptAction.openToast({
                message: "获取能力列表失败! 没有权限",
                duration: 2000
              });
              return;
            }
            // getPlatformAuthenticators end.
            let data_end = new Date().getTime();

            try {
              this.promptAction.openToast({
                message: "获取平台认证器能力成功! " + "耗时：" + (data_end - data_start) / 1000 + "秒",
                duration: 2000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          } catch (error) {
            // getPlatformAuthenticators Failure error message.
            let message = (error as BusinessError).message;
            // getPlatformAuthenticators Failure error code.
            let code = (error as BusinessError).code;
            try {
              this.promptAction.openToast({
                message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                duration: 5000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          }
        })

        Button() {
          Text('注册')
            .fontFamily('HarmonyHeiTi')
            .fontColor('#0A59F7')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin(this.MARGIN_BUTTON_TO_BUTTON)
        .height(this.BUTTON_HEIGHT)
        .width(this.BUTTON_WIDTH)
        .onClick(async () => {
          try {
            // register start.
            let data_start = new Date().getTime();

            // Construct the registration request parameters.
            let name: string = 'zhangSan';
            let displayName: string = '张三@zhangSan';
            let request = Fido2NetUtil.getRegRequest(name, displayName);
            // Request the Fido server and return the response data.
            let reg: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.regChallengeReq, JSON.stringify(request));
            // Parse the data returned by the server.
            let serverOption: ServerPublicKeyCredentialCreationOptions = JSON.parse(reg);
            // Base64 encrypt user data.
            if (serverOption.excludeCredentials) {
              for (let i = 0; i < serverOption.excludeCredentials.length; i++) {
                let credentialsId: string = serverOption.excludeCredentials[i].id as string;
                serverOption.excludeCredentials[i].id = Base64UrlDec(credentialsId);
              }
            }
            let challenge: string = serverOption.challenge as string;
            let userId: string = serverOption.user.id as string;
            serverOption.challenge = Base64UrlDec(challenge);
            serverOption.attestation = 'direct' as fido2.AttestationConveyancePreference;
            serverOption.user.id = Base64UrlDec(userId);
            let serverOptionData = JSON.stringify(serverOption);
            // Construct the registration parameter pkOptions.
            let pkOptions: fido2.PublicKeyCredentialCreationOptions = JSON.parse(serverOptionData);
            let regResp: string;
            if (canIUse('SystemCapability.Security.FIDO2')) {
              pkOptions.challenge = new Uint8Array(Object.values(serverOption.challenge));
              pkOptions.user.id = new Uint8Array(Object.values(serverOption.user.id));
              if (pkOptions.excludeCredentials) {
                for (let i = 0; i < pkOptions.excludeCredentials.length; i++) {
                  pkOptions.excludeCredentials[i].id = new Uint8Array(Object.values(pkOptions.excludeCredentials[i].id));
                }
              }
              // Registration message, assembly CredentialCreationOptions.
              let credentialCreationOp: fido2.CredentialCreationOptions = {
                publicKey: pkOptions
              };

              // Use the endpoint-side register capability to register, return PublicKey attestation credential.
              let publicKeyAttestationCredential: fido2.PublicKeyAttestationCredential = await fido2.register(this.uiContext, credentialCreationOp);

              this.credentialId = publicKeyAttestationCredential.rawId;
              let serveCreation: ServerPublicKeyCredentialCreation = getRegRespParam(publicKeyAttestationCredential);
              // Request the Fido server to return the registration result.
              regResp = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.regChallengeResp, JSON.stringify(serveCreation));
            } else {
              this.promptAction.openToast({
                message: "获取能力列表失败! 没有权限",
                duration: 2000
              });
              return;
            }

            // register end.
            let data_end = new Date().getTime();
            try {
              this.promptAction.openToast({
                message: "注册成功! " + '耗时：' + (data_end - data_start) / 1000 + "秒" + 'response len:' + JSON.stringify(regResp).length,
                duration: 2000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          } catch (error) {
            // register Failure error message.
            let message = (error as BusinessError).message;
            // register Failure error code.
            let code = (error as BusinessError).code;
            hilog.info(0x00, 'fido', `1111111 ${message}`);
            try {
              this.promptAction.openToast({
                message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                duration: 5000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          }
        })

        Button() {
          Text('认证')
            .fontFamily('HarmonyHeiTi')
            .fontColor('#0A59F7')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin(this.MARGIN_BUTTON_TO_BUTTON)
        .height(this.BUTTON_HEIGHT)
        .width(this.BUTTON_WIDTH)
        .onClick(async () => {
          try {
            // authenticate start.
            let data_start = new Date().getTime();

            // Construct network request parameters.
            let serverGetOptionsRequest: ServerPublicKeyCredentialGetOptionsRequest = {
              username: 'zhangSan',
              userVerification: 'required'
            };

            // Request to connect to Fido server.
            let authReq: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.authChallengeReq, JSON.stringify(serverGetOptionsRequest));
            // Parse the data returned by the server and construct authentication parameters.
            let authPub: fido2.PublicKeyCredentialRequestOptions = getAuthReqParam(authReq);
            let authCredentialRequestOptions: fido2.CredentialRequestOptions = {
              publicKey: authPub,
              mediation: "conditional" as fido2.CredentialMediationRequirement
            };

            // Invoke the authentication capability on the client side to perform authentication, return PublicKey attestation credential.
            let authResp: string = '';
            if (canIUse('SystemCapability.Security.FIDO2')) {
              let pkAssertionCredential: fido2.PublicKeyAssertionCredential = await fido2.authenticate(this.uiContext, authCredentialRequestOptions);
              // Construct request parameters and connect to the Fido server.
              let authAssertionCredential: ServerPublicKeyCredentialRequest =  getAuthRespParam(pkAssertionCredential);
              authResp = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.authChallengeResp, JSON.stringify(authAssertionCredential));
            }

            // authenticate end.
            let data_end = new Date().getTime();

            try {
              this.promptAction.openToast({
                message: "认证成功! " + '耗时：' + (data_end - data_start) / 1000 + "秒" + ' data：' + authResp,
                duration: 2000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          } catch (error) {
            // authenticate Failure error message.
            let message = (error as BusinessError).message;
            // authenticate Failure error code.
            let code = (error as BusinessError).code;
            try {
              this.promptAction.openToast({
                message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                duration: 5000
              });
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              hilog.error(0x00, 'fido2', `message is ${message}, code is ${code}`)
            };
          }
        })
      }
      .margin({ top: 50 })
    }.width('100%').alignItems(HorizontalAlign.Center)
  }
}

/**
 * base64url decode.
 *
 * @param input The string of input.
 * @return Url safe base64 decode.
 */
export function urlSafeBase64Dec(base64url: string): Uint8Array {
  let base64: string = base64url.replace(/-/g, '+').replace(/_/g, '/');
  while (base64.length % 4) {
    base64 += '=';
  }
  return new util.Base64Helper().decodeSync(base64);
}

/**
 * base64url decode.
 *
 * @param input The string of input.
 * @return base64 decode.
 */
export function Base64UrlDec(input: string): Uint8Array{
  let helper = new util.Base64Helper();
  let uArray = helper.decodeSync(input, util.Type.BASIC_URL_SAFE);
  return uArray;
}

/**
 * Decodes a Base64 encoded input u8 array into a newly-allocated u8 array using the Base64 encoding scheme.
 *
 * @param { Uint8Array } input - A Uint8Array value.
 * @returns { Uint8Array } Return the decoded Uint8Array.
 */
export function base64UrlEncByBytes(input: Uint8Array): string {
  let result = new util.Base64Helper().encodeToStringSync(input, util.Type.BASIC_URL_SAFE);
  return result;
}

/**
 * Obtaining Registration Parameters.
 *
 * @param { fido2.PublicKeyAttestationCredential } publicKeyCredentialCreation.
 * @returns { ServerPublicKeyCredentialCreation } Return the ServerPublicKeyCredentialCreation.
 */
export function getRegRespParam(publicKeyCredentialCreation: fido2.PublicKeyAttestationCredential): ServerPublicKeyCredentialCreation {
  let serveCreation: ServerPublicKeyCredentialCreation = new ServerPublicKeyCredentialCreation();
  if (canIUse('SystemCapability.Security.FIDO2')) {
    serveCreation.rawId = base64UrlEncByBytes(publicKeyCredentialCreation.rawId).replace(/\r?\n/g, '');
    serveCreation.type = publicKeyCredentialCreation.type;
    serveCreation.id = serveCreation.rawId;

    if (publicKeyCredentialCreation.authenticatorAttachment) {
      serveCreation.authenticatorAttachment = publicKeyCredentialCreation.authenticatorAttachment;
    }
    let response: ServerAuthenticatorAttestationResponse = new ServerAuthenticatorAttestationResponse();
    response.attestationObject = base64UrlEncByBytes(publicKeyCredentialCreation.response.attestationObject).replace(/\r?\n/g, '');
    response.clientDataJSON = base64UrlEncByBytes(publicKeyCredentialCreation.response.clientDataJson).replace(/\r?\n/g, '');
    let transports = [
      "internal"
    ];
    response.transports = transports;
    serveCreation.response = response;
  } else {
    hilog.error(0x00, 'fido', '没有权限');
  }
  return serveCreation;
}

/**
 * Obtaining Authentication Request Parameters.
 *
 * @param { string } authReq - A String Value.
 * @returns { PublicKeyCredentialRequestOptions } Return the PublicKeyCredentialRequestOptions.
 */
export function getAuthReqParam(authReq: string): fido2.PublicKeyCredentialRequestOptions {
  let serverAuthOption: ServerPublicKeyCredentialRequestOptions = JSON.parse(authReq) as ServerPublicKeyCredentialRequestOptions;
  let challenge: string = serverAuthOption.challenge as string;
  serverAuthOption.challenge = Base64UrlDec(challenge);

  let allowCredentialList: fido2.PublicKeyCredentialDescriptor[] = [];
  if(serverAuthOption.allowCredentials && serverAuthOption.allowCredentials.length > 0){
    let allowLists = serverAuthOption.allowCredentials;
    for (let i = 0; i < allowLists.length; i++){
      let pkCredentialDescriptor: fido2.PublicKeyCredentialDescriptor = {
        type: "public-key" as fido2.PublicKeyCredentialType,
        id: Base64UrlDec(allowLists[i].id as string),
        transports: [
          "internal" as fido2.AuthenticatorTransport
        ]
      }
      allowCredentialList[i] = pkCredentialDescriptor;
    }
  }

  let userVerification: fido2.UserVerificationRequirement = "preferred" as fido2.UserVerificationRequirement;
  if (serverAuthOption.userVerification) {
    userVerification = serverAuthOption.userVerification as fido2.UserVerificationRequirement;
  }

  let authPub: fido2.PublicKeyCredentialRequestOptions = {
    challenge: serverAuthOption.challenge,
    timeout: serverAuthOption.timeout,
    rpId: serverAuthOption.rpId,
    allowCredentials: allowCredentialList,
    userVerification: userVerification,
    hints: ["security-key" as fido2.PublicKeyCredentialHint]
  };

  if (serverAuthOption.extensions) {
    let map: Map<string, Object>=new  Map<string, Object>();
    let keys = Object.keys(serverAuthOption.extensions);
    let length = keys.length;
    for (let i = 0; i < length; ++i) {
      let key = keys[i];
      map.set(keys[i],(serverAuthOption.extensions[key]));
    }
    if (canIUse('SystemCapability.Security.FIDO2')) {
      authPub.extensions = map;
    }
  }

  return authPub;
}

/**
 * Obtaining Authentication Response Parameters.
 *
 * @param { fido2.PublicKeyAssertionCredential } pkAssertionCredential.
 * @returns { ServerPublicKeyCredentialRequest } Return the ServerPublicKeyCredentialRequest.
 */
export function getAuthRespParam(pkAssertionCredential: fido2.PublicKeyAssertionCredential): ServerPublicKeyCredentialRequest {
  let authAssertionCredential:ServerPublicKeyCredentialRequest =  new ServerPublicKeyCredentialRequest();
  if (canIUse('SystemCapability.Security.FIDO2')) {
    let response = pkAssertionCredential.response;
    let authResponse: ServerAuthenticatorAssertionResponse = new ServerAuthenticatorAssertionResponse();
    authResponse.clientDataJSON = base64UrlEncByBytes(response.clientDataJson);
    authResponse.signature = base64UrlEncByBytes(response.signature);
    authResponse.authenticatorData = base64UrlEncByBytes(response.authenticatorData);
    if (response.userHandle) {
      authResponse.userHandle = base64UrlEncByBytes(response.userHandle);
    }

    let rawId: string = base64UrlEncByBytes(pkAssertionCredential.rawId);
    let authenticatorAttachment: string = 'platform';

    if (pkAssertionCredential.authenticatorAttachment) {
      authenticatorAttachment = pkAssertionCredential.authenticatorAttachment;
    }
    // Certification parameters
    authAssertionCredential.rawId = rawId;
    authAssertionCredential.id = rawId;
    authAssertionCredential.authenticatorAttachment = authenticatorAttachment;
    authAssertionCredential.response = authResponse;
    authAssertionCredential.type = 'public-key';
  }
  return authAssertionCredential;
}

/**
 * The Interface Of ServerPublicKeyCredentialGetOptionsRequest.
 */
export interface ServerPublicKeyCredentialGetOptionsRequest {
  username: string,
  userVerification: string
}
