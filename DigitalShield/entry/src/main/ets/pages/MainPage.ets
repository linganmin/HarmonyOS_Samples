/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { trustedAuthentication } from '@kit.DeviceSecurityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { userAuth } from '@kit.UserAuthenticationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PromptAction } from '@kit.ArkUI';
import AssetUtils from '../utils/AssetUtils';
import TrustedAuth from '../model/TrustedAuthentication';

const TUI_PIN_DISABLE = 3
const TUI_BIND_FACE = 7
const TUI_BIND_FINGERPRINT = 8
const DOMAIN = 0x0000
const NOT_ENROLLED_ERROR = 12500010

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component
export struct MainPage {
  @State message: string = '';
  @State bioState: number = 2;
  @State hasFaceAbility: boolean = true;
  @State hasFingerprintAbility: boolean = true;
  @Consume hasShield: boolean;
  @Consume faceBind: boolean;
  @Consume fingerprintBind: boolean;
  @Consume pageInfos: NavPathStack;
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();
  context: Context = this.uiContext.getHostContext() as Context;
  resourceManager = this.context.resourceManager;

  async aboutToAppear(): Promise<void> {
    const bytes = [0x00, 0x00, 0x00, 0x80, 0x80, 0xd2, 0x41, 0x40];
    const buffer = new ArrayBuffer(bytes.length);
    const uint8View = new Uint8Array(buffer);
    for (let i = 0; i < bytes.length; i++) {
      uint8View[i] = bytes[i];
    }
    const dataView = new DataView(buffer);
    const doubleValue = dataView.getFloat64(0, true);
    this.message += `result = ${doubleValue.toString()}\n`;
    let v = 40.054015247234702;
    this.message += `result = ${v.toFixed(15)}\n`;
    let resArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore('pin_label1')
    if (resArray.length != 0) {
      this.hasShield = true;
    }
    let resFaceArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore('face_credentialID')
    if (resFaceArray.length != 0) {
      this.faceBind = true;
    }
    let resFingerArray: Uint8Array = await AssetUtils.QueryDataFromAssetStore('finger_credentialID')
    if (resFingerArray.length != 0) {
      this.fingerprintBind = true;
    }
    if (this.hasFingerprintAbility) {
      try {
        userAuth.getAvailableStatus(userAuth.UserAuthType.FINGERPRINT, userAuth.AuthTrustLevel.ATL3);
        hilog.info(DOMAIN, 'testTag', 'current auth trust level supported');
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        if (error.code === NOT_ENROLLED_ERROR) {
          hilog.error(DOMAIN, 'testTag',
            `Authentication bio is not enrolled. Code is ${err?.code}, message is ${err?.message}`);
        } else {
          hilog.error(DOMAIN, 'testTag',
            `current auth trust level not supported. Code is ${err?.code}, message is ${err?.message}`);
          this.hasFingerprintAbility = false;
          this.bioState--;
        }
      }
    }
    if (this.hasFaceAbility) {
      try {
        userAuth.getAvailableStatus(userAuth.UserAuthType.FACE, userAuth.AuthTrustLevel.ATL4);
        hilog.info(DOMAIN, 'testTag', 'current auth trust level supported');
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        if (error.code === NOT_ENROLLED_ERROR) {
          hilog.error(DOMAIN, 'testTag',
            `Authentication bio is not enrolled. Code is ${err?.code}, message is ${err?.message}`);
        } else {
          hilog.error(DOMAIN, 'testTag',
            `current auth trust level not supported. Code is ${err?.code}, message is ${err?.message}`);
          this.hasFaceAbility = false;
          this.bioState--;
        }
      }
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Text($r('app.string.IDSetting'))
              .width('100%')
              .fontSize(500)
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 28, bottom: 8 })
          }
          .width('calc(100% - 56vp)') // 100% stand for whole element and vp stand for margin
          .margin({
            left: 28,
            right: 28
          })

          Row() {
            Text($r('app.string.DigitalShield')).textAlign(TextAlign.Start).margin({ left: 12 })
            Blank()
            if (this.hasShield) {
              Button($r('app.string.ModifyWord'))
                .buttonStyle(ButtonStyleMode.NORMAL)
                .margin({ top: 14, bottom: 14, right: 12 })
                .onClick(async () => {
                  this.pageInfos.pushPath({ name: 'PasswordSelectionPage' })
                });
            } else {
              Button($r('app.string.OpenWord'))
                .buttonStyle(ButtonStyleMode.NORMAL)
                .margin({ top: 14, bottom: 14, right: 12 })
                .onClick(() => {
                  this.pageInfos.pushPath({ name: 'PasswordSelectionPage' })
                })
            }
          }
          .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .margin({
            left: 16,
            right: 16
          })

          if (this.hasShield) {
            Column() {
              Text($r('app.string.CloseShield'))
                .width('100%')
                .fontSize(500)
                .fontSize(14)
                .textAlign(TextAlign.Start)
                .margin({ top: 28, bottom: 8 })
            }
            .width('calc(100% - 56vp)') // 100% stand for whole element and vp stand for margin
            .margin({
              left: 28,
              right: 28
            })

            Column() {
              Row() {
                Text($r('app.string.CloseShieldWithVerification')).textAlign(TextAlign.Start).margin({ left: 12 })
                Blank()
                Button($r('app.string.CloseWord'))
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .margin({ top: 14, bottom: 14, right: 12 })
                  .onClick(async () => {
                    this.message = '';
                    try {
                      let session = await TrustedAuth.SignInit();
                      hilog.info(DOMAIN, 'testTag', 'Finish Signature Initialization');
                      let indata: string = 'placeholder';
                      await TrustedAuth.UserAuthTUIPINBeforeSign(indata, session, TUI_PIN_DISABLE, 'pin_label1');
                      this.message += this.resourceManager.getStringSync($r('app.string.CloseShieldSuccess'));
                      this.hasShield = false;
                      this.fingerprintBind = false;
                      this.faceBind = false;
                    } catch (error) {
                      hilog.error(DOMAIN, 'testTag', 'Close Shield Fail:', error);
                      this.message += this.resourceManager.getStringSync($r('app.string.CloseShieldFail')) +
                        `: ${error}`;
                    }
                    this.promptAction.openToast({
                      message: this.message,
                      duration: 100,
                    }).catch(() => {
                      hilog.error(DOMAIN, 'testTag', 'toast open failed');
                    })
                  });
              }
              .width('100%')
              .height(56)

              Divider().width('93%')
              Row() {
                Text($r('app.string.CloseShieldWithoutVerification')).textAlign(TextAlign.Start).margin({ left: 12 })
                Blank()
                Button($r('app.string.CloseWord'))
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .margin({ top: 14, bottom: 14, right: 12 })
                  .onClick(async () => {
                    this.message = '';
                    try {
                      const rand = cryptoFramework.createRandom();
                      const len: number = 32;
                      const challenge: Uint8Array = rand?.generateRandomSync(len)?.data;
                      const authToken = await TrustedAuth.disablePwdWithoutAuth(challenge, 'pin_label1');
                      hilog.info(DOMAIN, 'testTag', 'Close Shield Success:', authToken);
                      this.message += this.resourceManager.getStringSync($r('app.string.CloseShieldSuccess'));
                      this.hasShield = false;
                      this.fingerprintBind = false;
                      this.faceBind = false;
                    } catch (error) {
                      hilog.error(DOMAIN, 'testTag', 'Close Shield Fail:', error);
                      this.message += this.resourceManager.getStringSync($r('app.string.CloseShieldFail')) +
                        `: ${error}`;
                    }
                    this.promptAction.openToast({
                      message: this.message,
                      duration: 100,
                    }).catch(() => {
                      hilog.error(DOMAIN, 'testTag', 'toast open failed');
                    })
                  });
              }
              .width('100%')
              .height(56)
            }
            .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
            .height(112)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({
              left: 16,
              right: 16
            })

            if (this.bioState != 0) {
              Column() {
                Text($r('app.string.BioFeatureVerification'))
                  .width('100%')
                  .fontSize(500)
                  .fontSize(14)
                  .textAlign(TextAlign.Start)
                  .margin({ top: 28, bottom: 8 })
              }
              .width('calc(100% - 56vp)') // 100% stand for whole element and vp stand for margin
              .margin({
                left: 28,
                right: 28
              })
            }

            Column() {
              if (this.hasFingerprintAbility) {
                if (!this.fingerprintBind) {
                  Row() {
                    Text($r('app.string.Fingerprint')).textAlign(TextAlign.Start).margin({ left: 12 })
                    Blank()
                    Button($r('app.string.Bind'))
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .margin({ top: 14, bottom: 14, right: 12 })
                      .onClick(async () => {
                        this.message = '';
                        try {
                          let session = await TrustedAuth.SignInit();
                          hilog.info(DOMAIN, 'testTag', 'Finish Signature Initialization');
                          const tuiAuthToken: Uint8Array =
                            await TrustedAuth.GetTUIAuthTokenBeforeBioVerify('placeholder', session, TUI_BIND_FINGERPRINT,
                              'pin_label1');
                          let bioAuthToken: Uint8Array =
                            await TrustedAuth.UserAuthBeforeSign(session, TUI_BIND_FINGERPRINT);
                          let operType = trustedAuthentication.OperateType.OPERATE_TYPE_BIOMETRIC_AUTH;
                          let resignAuthToken =
                            await trustedAuthentication.getBiometricAuthToken(operType, tuiAuthToken, bioAuthToken);
                          let inputdata = 'placeholder';
                          await TrustedAuth.bindFingerID(session.handle, resignAuthToken.authToken, inputdata)
                          this.message += this.resourceManager.getStringSync($r('app.string.BindFingerprintSuccess'));
                          this.fingerprintBind = true;
                        } catch (error) {
                          hilog.error(DOMAIN, 'testTag', 'Bind Fingerprint Fail:', error);
                          if (error.message === 'Authentication template has not been enrolled.') {
                            this.message += this.resourceManager.getStringSync($r('app.string.BindFingerprintFailWithNotification'));
                          } else {
                            this.message += this.resourceManager.getStringSync($r('app.string.BindFingerprintFail')) +
                              `: ${error}`;
                          }
                        }
                        this.promptAction.openToast({
                          message: this.message,
                          duration: 100,
                        }).catch(() => {
                          hilog.error(DOMAIN, 'testTag', 'toast open failed');
                        })
                      });
                  }
                  .width('100%')
                  .height(56)
                } else {
                  Row() {
                    Text($r('app.string.FingerprintBound')).textAlign(TextAlign.Start).margin({ left: 12 })
                    Blank()
                    Button($r('app.string.UnBound'))
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .margin({ top: 14, bottom: 14, right: 12 })
                      .onClick(async () => {
                        this.message = '';
                        try {
                          let authType = trustedAuthentication.AuthType.AUTH_TYPE_FINGERPRINT;
                          await TrustedAuth.disableTrustedBioAuthentication('pin_label1', authType);
                          this.message += this.resourceManager.getStringSync($r('app.string.UnBoundFingerprintSuccess'));
                          this.fingerprintBind = false;
                        } catch (error) {
                          // 捕获错误并处理
                          hilog.error(DOMAIN, 'testTag', 'UnBound Fingerprint Fail:', error);
                          this.message += this.resourceManager.getStringSync($r('app.string.UnBoundFingerprintFail')) +
                            `: ${error}`;
                        }
                        this.promptAction.openToast({
                          message: this.message,
                          duration: 100,
                        }).catch(() => {
                          hilog.error(DOMAIN, 'testTag', 'toast open failed');
                        })
                      });
                  }.width('100%')
                  .height(56)
                }
              }
              if (this.bioState === 2) {
                Divider().width('93%')
              }
              if (this.hasFaceAbility) {
                if (!this.faceBind) {
                  Row() {
                    Text($r('app.string.Face')).textAlign(TextAlign.Start).margin({ left: 12 })
                    Blank()
                    Button($r('app.string.Bind'))
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .margin({ top: 14, bottom: 14, right: 12 })
                      .onClick(async () => {
                        this.message = '';
                        try {
                          let session = await TrustedAuth.SignInit();
                          hilog.info(DOMAIN, 'testTag', 'Finish Signature Initialization');
                          const tuiAuthToken: Uint8Array =
                            await TrustedAuth.GetTUIAuthTokenBeforeBioVerify('placeholder', session, TUI_BIND_FACE, 'pin_label1');
                          let bioAuthToken: Uint8Array =
                            await TrustedAuth.UserAuthBeforeSign(session, TUI_BIND_FACE);
                          let operType = trustedAuthentication.OperateType.OPERATE_TYPE_BIOMETRIC_AUTH;
                          let resignAuthToken =
                            await trustedAuthentication.getBiometricAuthToken(operType, tuiAuthToken, bioAuthToken);
                          let inputdata = 'placeholder';
                          await TrustedAuth.bindFaceID(session.handle, resignAuthToken.authToken, inputdata)
                          this.message += this.resourceManager.getStringSync($r('app.string.BindFaceSuccess'));
                          this.faceBind = true;
                        } catch (error) {
                          hilog.error(DOMAIN, 'testTag', 'Bind Face Fail:', error);
                          if (error.message === 'Authentication template has not been enrolled.') {
                            this.message += this.resourceManager.getStringSync($r('app.string.BindFaceFailWithNotification'))
                          } else {
                            this.message += this.resourceManager.getStringSync($r('app.string.BindFaceFail')) +
                              ` : ${error}`;
                          }
                        }
                        this.promptAction.openToast({
                          message: this.message,
                          duration: 100,
                        }).catch(() => {
                          hilog.error(DOMAIN, 'testTag', 'toast open failed');
                        })
                      });
                  }.width('100%')
                  .height(56)
                } else {
                  Row() {
                    Text($r('app.string.FaceBound')).textAlign(TextAlign.Start).margin({ left: 12 })
                    Blank()
                    Button($r('app.string.UnBound'))
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .margin({ top: 14, bottom: 14, right: 12 })
                      .onClick(async () => {
                        this.message = '';
                        try {
                          let authType = trustedAuthentication.AuthType.AUTH_TYPE_FACE;
                          await TrustedAuth.disableTrustedBioAuthentication('pin_label1', authType);
                          this.message += this.resourceManager.getStringSync($r('app.string.UnBoundFaceSuccess'));
                          this.faceBind = false;
                        } catch (error) {
                          // 捕获错误并处理
                          hilog.error(DOMAIN, 'testTag', 'UnBound Face Fail:', error);
                          this.message += this.resourceManager.getStringSync($r('app.string.UnBoundFaceFail')) +
                            `: ${error}`;
                        }
                        this.promptAction.openToast({
                          message: this.message,
                          duration: 100,
                        }).catch(() => {
                          hilog.error(DOMAIN, 'testTag', 'toast open failed');
                        })
                      });
                  }
                  .width('100%')
                  .height(56)
                }
              }
            }
            .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
            .height(`calc(56vp * ${this.bioState})`)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({
              left: 16,
              right: 16,
              bottom: 16
            })
          }
        }
        .justifyContent(FlexAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .width('100%')
      }.height('calc(100% - 56vp)') // 100% stand for whole element and vp stand for margin

      Button($r('app.string.Trade')).width('calc(100% - 32vp)').onClick(() => {
        this.pageInfos.pushPath({ name: 'TradingPage' })
      }).margin({ bottom: 16 })
    }
    .title($r('app.string.FinDigitalShield'))
    .hideBackButton(true)
    .backgroundColor('#F1F3F5')
    .width('100%')
    .height('100%')
  }
}