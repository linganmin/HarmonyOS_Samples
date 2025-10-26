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

import { PromptAction } from '@kit.ArkUI';
import { trustedAuthentication } from '@kit.DeviceSecurityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import TrustedAuth from '../model/TrustedAuthentication';

const TUI_CONTENT_PWD_VERIFY = 4
const TUI_CONTENT_FACE_VERIFY = 5
const TUI_CONTENT_FINGERPRINT_VERIFY = 6
const DOMAIN = 0x0000

@Builder
export function TradingPageBuilder() {
  TradingPage()
}

@Builder
export function BindSheetBuilder() {
  BindSheetTemp()
}

@Component
export struct BindSheetTemp {
  @State message: string = '';
  @Consume receiver: string;
  @Consume receiveAccount: string;
  @Consume tradingAmount: string;
  @Consume faceBind: boolean;
  @Consume fingerprintBind: boolean;
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();
  context: Context = this.uiContext.getHostContext() as Context;
  resourceManager = this.context.resourceManager;

  build() {
    Column({ space: 12 }) {
      Button($r('app.string.PINVerification'))
        .width('calc(100% - 32vp)')
        .buttonStyle(ButtonStyleMode.NORMAL)
        .onClick(async () => {
          this.message = '';
          try {
            let session = await TrustedAuth.SignInit();
            hilog.info(DOMAIN, 'testTag', 'Signature Initialization success');
            let indata: string =
              this.resourceManager.getStringSync($r('app.string.Recipient')) + ':' + this.receiver + '\n' +
              this.resourceManager.getStringSync($r('app.string.AccountNumber')) + ':' + this.receiveAccount + '\n' +
              this.resourceManager.getStringSync($r('app.string.TradingAmount')) + ':' + this.tradingAmount;
            await TrustedAuth.UserAuthTUIPINBeforeSign(indata, session, TUI_CONTENT_PWD_VERIFY, 'pin_label1');
            this.message += this.resourceManager.getStringSync($r('app.string.PINVerificationSuccess'));
          } catch (error) {
            hilog.error(DOMAIN, 'testTag', 'PIN Verification Fail:', error);
            this.message += this.resourceManager.getStringSync($r('app.string.PINVerificationFail')) + `: ${error}`;
          }
          this.promptAction.openToast({
            message: this.message,
            duration: 100,
          }).catch(() => {
            hilog.error(DOMAIN, 'testTag', 'toast open failed');
          })
        });
      if (this.fingerprintBind) {
        Button($r('app.string.FingerprintVerification'))
          .width('calc(100% - 32vp)')
          .buttonStyle(ButtonStyleMode.NORMAL)
          .onClick(async () => {
            this.message = '';
            try {
              let session = await TrustedAuth.SignInit();
              hilog.info(DOMAIN, 'testTag', 'Signature Initialization success');
              let indata: string =
                this.resourceManager.getStringSync($r('app.string.Recipient')) + ':' + this.receiver + '\n' +
                this.resourceManager.getStringSync($r('app.string.AccountNumber')) + ':' + this.receiveAccount + '\n' +
                this.resourceManager.getStringSync($r('app.string.TradingAmount')) + ':' + this.tradingAmount;
              const tuiAuthToken: Uint8Array =
                await TrustedAuth.GetTUIAuthTokenBeforeBioVerify(indata, session, TUI_CONTENT_FINGERPRINT_VERIFY, 'pin_label1');
              let bioAuthToken: Uint8Array =
                await TrustedAuth.UserAuthBeforeSign(session, TUI_CONTENT_FINGERPRINT_VERIFY);
              let operType = trustedAuthentication.OperateType.OPERATE_TYPE_CONTENT_AUTH;
              let resignAuthToken =
                await trustedAuthentication.getBiometricAuthToken(operType, tuiAuthToken, bioAuthToken);
              await TrustedAuth.HuksSignAndVerify(indata, session, resignAuthToken.authToken)
              this.message += this.resourceManager.getStringSync($r('app.string.FingerprintVerificationSuccess'));
            } catch (error) {
              hilog.error(DOMAIN, 'testTag', 'Fingerprint Verification Fail:', error);
              if (error.code === 1019100019) {
                this.message += this.resourceManager.getStringSync($r('app.string.FingerprintVerificationFailWithNotification'));
              } else {
                this.message += this.resourceManager.getStringSync($r('app.string.FingerprintVerificationFail')) +
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
      if (this.faceBind) {
        Button($r('app.string.FaceVerification'))
          .width('calc(100% - 32vp)')
          .buttonStyle(ButtonStyleMode.NORMAL)
          .onClick(async () => {
            this.message = '';
            try {
              let session = await TrustedAuth.SignInit();
              hilog.info(DOMAIN, 'testTag', 'Signature Initialization success');
              let indata: string =
                this.resourceManager.getStringSync($r('app.string.Recipient')) + ':' + this.receiver + '\n' +
                this.resourceManager.getStringSync($r('app.string.AccountNumber')) + ':' + this.receiveAccount + '\n' +
                this.resourceManager.getStringSync($r('app.string.TradingAmount')) + ':' + this.tradingAmount;
              const tuiAuthToken: Uint8Array =
                await TrustedAuth.GetTUIAuthTokenBeforeBioVerify(indata, session, TUI_CONTENT_FACE_VERIFY, 'pin_label1');
              let bioAuthToken: Uint8Array =
                await TrustedAuth.UserAuthBeforeSign(session, TUI_CONTENT_FACE_VERIFY);
              let operType = trustedAuthentication.OperateType.OPERATE_TYPE_CONTENT_AUTH;
              let resignAuthToken =
                await trustedAuthentication.getBiometricAuthToken(operType, tuiAuthToken, bioAuthToken);
              await TrustedAuth.HuksSignAndVerify(indata, session, resignAuthToken.authToken)
              this.message += this.resourceManager.getStringSync($r('app.string.FaceVerificationSuccess'));
            } catch (error) {
              hilog.error(DOMAIN, 'testTag', 'Face Verification Fail:', error);
              if (error.code === 1019100019) {
                this.message += this.resourceManager.getStringSync($r('app.string.FaceVerificationFailWithNotification'));
              } else {
                this.message += this.resourceManager.getStringSync($r('app.string.FaceVerificationFail')) +
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
    }.margin({ top: 24, bottom: 24 })
  }
}

@Component
export struct TradingPage {
  @State onlyNum: boolean = true;
  @Provide receiver: string = '';
  @Provide receiveAccount: string = '';
  @Provide tradingAmount: string = '';
  @State bindSheetShow: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  sheetTitleOption: SheetTitleOptions = { title: $r('app.string.ChooseVerificationMethod') }
  sheetOption: SheetOptions = { height: SheetSize.FIT_CONTENT, title: this.sheetTitleOption }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Blank().height(4)
          Row() {
            Text($r('app.string.Recipient')).width('20%').fontSize(14).textAlign(TextAlign.Start).margin({ left: 12 })
            TextArea({ placeholder: $r('app.string.MRZhang'), text: this.receiver })
              .width('75%')
              .fontSize(16)
              .backgroundColor(Color.White)
              .onChange((value) => {
                this.receiver = value;
              })
          }.width('100%').height(48)

          Divider().width('93%')
          Row() {
            Text($r('app.string.AccountNumber'))
              .width('20%')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ left: 12 })
            TextArea({ placeholder: '6666 1234 **** **** 888', text: this.receiveAccount })
              .width('75%')
              .fontSize(16)
              .backgroundColor(Color.White)
              .onChange((value) => {
                this.receiveAccount = value;
              })
          }.width('100%').height(48)

          Divider().width('93%')
          Row() {
            Text($r('app.string.TradingAmount'))
              .width('20%')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ left: 12 })
            TextArea({ placeholder: '0.0', text: this.tradingAmount })
              .width('75%')
              .fontSize(16)
              .backgroundColor(Color.White)
              .onChange((value) => {
                this.tradingAmount = value;
              })
          }.width('100%').height(48)

          Blank().height(4)
        }
        .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({
          left: 16,
          right: 16,
          top: 8,
          bottom: 24
        })

        Button($r('app.string.NextWord'))
          .width('calc(100% - 32vp)')// 100% stand for whole element and vp stand for margin
          .onClick(() => {
            this.bindSheetShow = true;
          })
          .bindSheet(this.bindSheetShow!!, BindSheetBuilder(), this.sheetOption);
      }
    }
    .title($r('app.string.TransactionWord'))
    .backgroundColor('#F1F3F5')
  }
}