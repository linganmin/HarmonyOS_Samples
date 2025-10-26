/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';
import { BusinessError } from '@kit.BasicServicesKit';
import { Fido2NetUtil } from '../server/Fido2NetUtil';
import fido2 from './fido2api'
import { ServerPublicKeyCredentialCreationOptions } from '../server/ServerPublicKeyCredentialCreationOptions';
import { ServerPublicKeyCredentialRequestOptions } from '../server/ServerPublicKeyCredentialRequestOptions';
import { taskpool } from '@kit.ArkTS';
import { ServerPublicKeyCredentialCreation } from '../server/ServerPublicKeyCredentialCreation';
import { ServerAuthenticatorAttestationResponse } from '../server/ServerAuthenticatorAttestationResponse';
import { PromptAction } from '@kit.ArkUI';
import { ServerPublicKeyCredentialRequest } from '../server/ServerPublicKeyCredentialRequest';
import { ServerAuthenticatorAssertionResponse } from '../server/ServerAuthenticatorAssertionResponse';

const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private MARGIN_BUTTON_TO_BUTTON = 8
  private BUTTON_HEIGHT = 40
  private BUTTON_WIDTH = 328
  private MENU_HEIGHT = 164
  private MENU_WIDTH = 328

  userName:string ="zhangSan";
  displayName:string ="www.@zhangSan.com";
  credentialId:Uint8Array = new Uint8Array();

  uiContext1: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext1.getPromptAction();

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
              let data_start = new Date().getTime();
              let task: taskpool.Task = new taskpool.Task(getClientCapabilities);
              taskpool.execute(task).then(async (res) => {
                hilog.info(DOMAIN, '[fido2ndk]', `getClientCapabilities result is: ${res}`);
                let data_end = new Date().getTime();

                try {
                  this.promptAction.openToast({
                    message: "获取能力列表成功! " + '耗时: ' + (data_end - data_start) / 1000 + '秒！',
                    duration: 3000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.error(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
                }
              });
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
                hilog.error(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
              }
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
          .onClick(async ()=>{
            try {
              let data_start = new Date().getTime();
              let task: taskpool.Task = new taskpool.Task(getPlatformAuthenticators);
              taskpool.execute(task).then(async (res) => {
                hilog.info(DOMAIN, '[fido2ndk]', `getPlatformAuthenticators result is: ${res}`);
                let data_end = new Date().getTime();
                try {
                  this.promptAction.openToast({
                    message: "获取平台认证器能力成功! " + '耗时: ' + (data_end - data_start) / 1000 + '秒！',
                    duration: 3000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.error(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
                }
              });
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
                hilog.error(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
              }
            }
          })

          // TextInput({ placeholder: 'Enter username' })
          //   .textAlign(TextAlign.Center)
          //   .margin(this.MARGIN_BUTTON_TO_BUTTON)
          //   .height(this.BUTTON_HEIGHT)
          //   .width(this.BUTTON_WIDTH)
          //   .onChange((value: string) => {
          //     this.userName = value;
          //     this.displayName = 'www.@' + this.userName + '.com'
          //   })

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
          .onClick(async ()=>{
              try {
                hilog.info(DOMAIN, '[fido2ndk]', "canIUse = " + canIUse('SystemCapability.Security.FIDO2'));
                hilog.debug(DOMAIN, '[fido2ndk]', 'regUserName: ' + this.userName);
                let data_start = new Date().getTime();
                let serveCreation: ServerPublicKeyCredentialCreation = new ServerPublicKeyCredentialCreation()
                let request = Fido2NetUtil.getRegRequest(this.userName, this.displayName)
                let reg: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.regChallengeReq,
                  JSON.stringify(request))
                hilog.info(DOMAIN, '[fido2ndk]', "reg = " + reg)
                let task: taskpool.Task = new taskpool.Task(register, reg);
                taskpool.execute(task).then(async (res) => {
                  let retStr: string = res as string;
                  let publicKeyAttestationCredential: fido2.PublicKeyAttestationCredential = JSON.parse(retStr);

                  hilog.info(DOMAIN, '[fido2ndk]',`register response is ${JSON.stringify(publicKeyAttestationCredential)}`);
                  this.credentialId = publicKeyAttestationCredential.rawId;
                  hilog.debug(DOMAIN, '[fido2ndk]', 'credentialId ' + JSON.stringify(this.credentialId));

                  serveCreation = getRegRespParam(publicKeyAttestationCredential);
                  let regResp: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.regChallengeResp, JSON.stringify(serveCreation));
                  let data_end = new Date().getTime();
                  try {
                    this.promptAction.openToast({
                      message: "注册成功! " + '耗时: ' + (data_end - data_start) / 1000 + '秒！' + 'ResponseLen: ' + JSON.stringify(regResp).length,
                      duration: 3000
                    });
                  } catch (error) {
                    let message = (error as BusinessError).message
                    let code = (error as BusinessError).code
                    console.error(`openToast args error code is ${code}, message is ${message}`);
                  };
                });
              } catch (error) {
                // register Failure error message.
                let message = (error as BusinessError).message;
                // register Failure error code.
                let code = (error as BusinessError).code;
                try {
                  this.promptAction.openToast({
                    message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                    duration: 5000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.error(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
                }
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
          .onClick(async ()=>{
              try {
                hilog.debug(DOMAIN, '[fido2ndk]', 'authUserName: ' + this.userName);

                let data_start = new Date().getTime();
                let serverGetOptionsRequest:ServerPublicKeyCredentialGetOptionsRequest = {
                  username: this.userName,
                  userVerification: 'preferred'
                };

                let authReq: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url+Fido2NetUtil.authChallengeReq,JSON.stringify(serverGetOptionsRequest))

                let authPub: fido2.PublicKeyCredentialRequestOptions = getAuthReqParam(authReq);

                let authCredentialRequestOptions:fido2.CredentialRequestOptions = {
                  publicKey: authPub,
                  mediation:"optional" as fido2.CredentialMediationRequirement
                }
                let inputVal = JSON.stringify(authCredentialRequestOptions)
                let task: taskpool.Task = new taskpool.Task(auth, inputVal);
                taskpool.execute(task).then(async (res) => {
                  console.info("auth result is: " + res);
                  let retStr: string = res as string;
                  let pkAssertionCredential: fido2.PublicKeyAssertionCredential = JSON.parse(retStr)
                  let authAssertionCredential: ServerPublicKeyCredentialRequest = getAuthRespParam(pkAssertionCredential);
                  let authResp: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url+Fido2NetUtil.authChallengeResp,JSON.stringify(authAssertionCredential))
                  hilog.info(DOMAIN, '[fido2ndk]', `1111111111111111${authResp}`);
                  let data_end = new Date().getTime();

                  try {
                    this.promptAction.openToast({
                      message: "认证成功! " + '耗时: ' + (data_end - data_start) / 1000 + '秒！' + ' data: ' + authResp,
                      duration: 3000
                    });
                  } catch (error) {
                    let message = (error as BusinessError).message;
                    let code = (error as BusinessError).code;
                    console.error(`openToast args error code is ${code}, message is ${message}`);
                  }
                });
              } catch (error) {
                try {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  this.promptAction.openToast({
                    message: "发生错误! Message:" + JSON.stringify(message) + "errCode:" + JSON.stringify(code),
                    duration: 5000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.info(DOMAIN, '[fido2ndk]', `openToast args error code is ${code}, message is ${message}`);
                }
              }
            })
        }
        .margin({ top: 50 })
      }.width('100%').alignItems(HorizontalAlign.Center)
  }
}

interface ServerPublicKeyCredentialGetOptionsRequest {
  username: string,
  userVerification: string
}

function getAuthReqParam(authReq:string):fido2.PublicKeyCredentialRequestOptions {
  let serverAuthOption:ServerPublicKeyCredentialRequestOptions = JSON.parse(authReq) as ServerPublicKeyCredentialRequestOptions;
  let challenge:string = serverAuthOption.challenge as string;
  serverAuthOption.challenge = Fido2NetUtil.Base64UrlDec(challenge);

  let allowCredentialList:fido2.PublicKeyCredentialDescriptor[] = [];
  if(serverAuthOption.allowCredentials && serverAuthOption.allowCredentials.length>0){
    let allowlists = serverAuthOption.allowCredentials;
    for (let i=0;i<allowlists.length;i++){
      let pkCredentialDescriptor: fido2.PublicKeyCredentialDescriptor = {
        type: "public-key" as fido2.PublicKeyCredentialType,
        id: Fido2NetUtil.Base64UrlDec(allowlists[i].id as string),
        transports: [
          "internal" as fido2.AuthenticatorTransport
        ]
      }
      allowCredentialList[i] = pkCredentialDescriptor;
    }
  }

  let userVerification: fido2.UserVerificationRequirement ="required" as fido2.UserVerificationRequirement
  if(serverAuthOption.userVerification){
    userVerification = serverAuthOption.userVerification as fido2.UserVerificationRequirement;
  }

  let authPub:fido2.PublicKeyCredentialRequestOptions = {
    challenge: serverAuthOption.challenge,
    timeout: serverAuthOption.timeout,
    rpId: serverAuthOption.rpId,
    allowCredentials: allowCredentialList,
    userVerification: userVerification,
    hints: ["security-key" as fido2.PublicKeyCredentialHint]
  }

  if(serverAuthOption.extensions){
    let map: Map<string, Object>=new  Map<string, Object>()
    let keys = Object.keys(serverAuthOption.extensions);
    let length = keys.length;
    for (let i = 0; i < length; ++i) {
      let key = keys[i];
      map.set(keys[i],(serverAuthOption.extensions[key]));
    }
    authPub.extensions = map;
  }

  return authPub;
}

@Concurrent
function getClientCapabilities() {
  let retCode: number = testNapi.HCTS_ConnectService_getClientCapability();
  if (retCode != 0) {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_getClientCapability returnCode = " + retCode);
  } else {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_getClientCapability success!");
  }
  return retCode;
}

@Concurrent
function getPlatformAuthenticators() {
  let retCode: number = testNapi.HCTS_ConnectService_getPlatformAuthenticator();
  if (retCode != 0) {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_getPlatformAuthenticator returnCode = " + retCode);
  } else {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_getPlatformAuthenticator success!");
  }
  return retCode;
}

@Concurrent
function register(reg: string) {
  let serverOption: ServerPublicKeyCredentialCreationOptions = JSON.parse(reg);
  if (serverOption.excludeCredentials) {
    for(let i = 0; i < serverOption.excludeCredentials.length; i++) {
      let credentialsId: string = serverOption.excludeCredentials[i].id as string;
      serverOption.excludeCredentials[i].id = Fido2NetUtil.Base64UrlDec(credentialsId);
    }
  }
  let challenge: string = serverOption.challenge as string;
  let userId: string = serverOption.user.id as string;
  serverOption.challenge = Fido2NetUtil.Base64UrlDec(challenge)
  serverOption.attestation = 'direct' as fido2.AttestationConveyancePreference;
  serverOption.user.id = Fido2NetUtil.Base64UrlDec(userId)
  let serverOptionData = JSON.stringify(serverOption)
  let pkOptions: fido2.PublicKeyCredentialCreationOptions = JSON.parse(serverOptionData);
  pkOptions.challenge = new Uint8Array(Object.values(serverOption.challenge))
  pkOptions.user.id = new Uint8Array(Object.values(serverOption.user.id))
  if(pkOptions.excludeCredentials){
    for (let i = 0; i < pkOptions.excludeCredentials.length; i++) {
      pkOptions.excludeCredentials[i].id = new Uint8Array(Object.values(pkOptions.excludeCredentials[i].id))
    }
  }
  // Registration message, assembly CredentialCreationOptions.
  let credentialCreationOp: fido2.CredentialCreationOptions = {
    mediation: "optional" as fido2.CredentialMediationRequirement,
    publicKey: pkOptions
  }
  let inputVal = JSON.stringify(credentialCreationOp)
  hilog.info(0x0000, "[fido2ndk]", "credentialCreationOptions = " + inputVal)
  let retStr: string = testNapi.HCTS_ConnectService_Reg(inputVal);
  if (!retStr) {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_Reg error!");
  } else {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_Reg success!");
  }
  return retStr;
}

@Concurrent
function auth(inputVal:string) {
  let ret: string = testNapi.HCTS_ConnectService_Auth(inputVal);
  if (!ret) {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_Auth error!");
  } else {
    hilog.info(0x0000, '[fido2ndk]', "HCTS_ConnectService_Auth success!");
  }
  return ret;
}

function getRegRespParam(publicKeyCredentialCreation:fido2.PublicKeyAttestationCredential):ServerPublicKeyCredentialCreation {
  let serveCreation:ServerPublicKeyCredentialCreation = new ServerPublicKeyCredentialCreation();
  serveCreation.rawId = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(publicKeyCredentialCreation.rawId))).replace(/\r?\n/g, '');
  serveCreation.type = publicKeyCredentialCreation.type;
  serveCreation.id = serveCreation.rawId;

  if(publicKeyCredentialCreation.authenticatorAttachment){
    serveCreation.authenticatorAttachment = publicKeyCredentialCreation.authenticatorAttachment;
  }

  let response: ServerAuthenticatorAttestationResponse = new ServerAuthenticatorAttestationResponse();
  response.attestationObject = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(publicKeyCredentialCreation.response.attestationObject))).replace(/\r?\n/g, '');
  response.clientDataJSON = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(publicKeyCredentialCreation.response.clientDataJson))).replace(/\r?\n/g, '');

  let transports = [
    "internal"
  ]
  response.transports = transports;
  serveCreation.response = response;

  return serveCreation
}

function getAuthRespParam(pkAssertionCredential:fido2.PublicKeyAssertionCredential):ServerPublicKeyCredentialRequest {
  let response = pkAssertionCredential.response;
  let authResponse:ServerAuthenticatorAssertionResponse = new ServerAuthenticatorAssertionResponse();
  authResponse.clientDataJSON = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(response.clientDataJson)))
  authResponse.signature = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(response.signature)))
  authResponse.authenticatorData = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(response.authenticatorData)))
  if (response.userHandle) {
    authResponse.userHandle = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(response.userHandle)))
  }

  let rawId:string = Fido2NetUtil.base64UrlEncByBytes(new Uint8Array(Object.values(pkAssertionCredential.rawId)));

  // let type:string = 'public-key'
  let authenticatorAttachment:string = 'platform'
  if(pkAssertionCredential.authenticatorAttachment){
    authenticatorAttachment = pkAssertionCredential.authenticatorAttachment;
  }

  let authAssertionCredential:ServerPublicKeyCredentialRequest =  new ServerPublicKeyCredentialRequest();
  authAssertionCredential.rawId = rawId;
  authAssertionCredential.id = rawId;
  authAssertionCredential.authenticatorAttachment = authenticatorAttachment;
  authAssertionCredential.response = authResponse;
  authAssertionCredential.type = 'public-key'
  return authAssertionCredential
}
