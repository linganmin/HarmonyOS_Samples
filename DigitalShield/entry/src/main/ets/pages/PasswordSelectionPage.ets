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
import { hilog } from '@kit.PerformanceAnalysisKit';
import TrustedAuth from '../model/TrustedAuthentication';

const TUI_PIN_SET = 1
const TUI_PIN_MODIFY = 2
const TUI_PIN_SET_MIX = 9
const TUI_PIN_MODIFY_MIX = 10
const DOMAIN = 0x0000

@Builder
export function PasswordSelectionPageBuilder() {
  PasswordSelectionPage()
}

@Component
export struct PasswordSelectionPage {
  @State onlyNum: boolean = true;
  @State message: string = '';
  @State type: number = 0;
  @Consume hasShield: boolean;
  @Consume pageInfos: NavPathStack;
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();
  context: Context = this.uiContext.getHostContext() as Context;
  resourceManager = this.context.resourceManager;

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.PlzSetVerificationWay'))
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
          Checkbox().margin({ left: 18 }).select(this.onlyNum!!)
          Text($r('app.string.PureNumber')).textAlign(TextAlign.Start).margin({ left: 8 })
        }
        .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({
          left: 16,
          right: 16
        })
        .margin({ bottom: 6 })

        Row() {
          Checkbox().margin({ left: 18 }).select(!this.onlyNum).onClick(() => {
            this.onlyNum = !this.onlyNum
          })
          Text($r('app.string.NumberPlusAlphabet')).textAlign(TextAlign.Start).margin({ left: 8 })
        }
        .width('calc(100% - 32vp)') // 100% stand for whole element and vp stand for margin
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({
          left: 16,
          right: 16
        })

        Blank()
        if (this.hasShield) {
          Button($r('app.string.ModifyPassword')).width('calc(100% - 32vp)').onClick(async () => {
            this.message = '';
            if (this.onlyNum) {
              this.type = TUI_PIN_MODIFY;
            } else {
              this.type = TUI_PIN_MODIFY_MIX;
            }
            try {
              await TrustedAuth.TestGenKeyForTuiPinSign();
              hilog.info(DOMAIN, 'testTag', 'Generate Key Success');
              let session = await TrustedAuth.SignInit();
              hilog.info(DOMAIN, 'testTag', 'Signature Initialization success');
              let indata: string = 'placeholder';
              await TrustedAuth.UserAuthTUIPINBeforeSign(indata, session, this.type, 'pin_label1');
              this.message += this.resourceManager.getStringSync($r('app.string.ModifyPwSuccess'));
              this.hasShield = true;
            } catch (error) {
              // catch error
              hilog.error(DOMAIN, 'testTag', 'Modify Pw Fail:', error);
              this.message += this.resourceManager.getStringSync($r('app.string.ModifyPwFail')) + `: ${error}`;
            }
            this.promptAction.openToast({
              message: this.message,
              duration: 100,
            }).catch(() => {
              hilog.error(DOMAIN, 'testTag', 'toast open failed');
            })
            this.pageInfos.pop();
          }).margin({ bottom: 16 })
        } else {
          Button($r('app.string.OpenWord')).width('calc(100% - 32vp)').onClick(async () => {
            this.message = '';
            if (this.onlyNum) {
              this.type = TUI_PIN_SET;
            } else {
              this.type = TUI_PIN_SET_MIX;
            }
            try {
              await TrustedAuth.TestGenKeyForTuiPinSign();
              hilog.info(DOMAIN, 'testTag', 'GenerateKeySuccess');
              let session = await TrustedAuth.SignInit();
              hilog.info(DOMAIN, 'testTag', 'Signature Initialization success');
              let indata: string = 'placeholder';
              await TrustedAuth.UserAuthTUIPINBeforeSign(indata, session, this.type, 'pin_label1');
              this.message += this.resourceManager.getStringSync($r('app.string.OpenShieldSuccess'));
              this.hasShield = true;
            } catch (error) {
              // catch error
              hilog.error(DOMAIN, 'testTag', 'OpenShield Fail:', error);
              this.message += this.resourceManager.getStringSync($r('app.string.OpenShieldFail')) + `: ${error}`;
            }
            this.promptAction.openToast({
              message: this.message,
              duration: 100,
            }).catch(() => {
              hilog.error(DOMAIN, 'testTag', 'toast open failed');
            })
            this.pageInfos.pop();
          }).margin({ bottom: 16 })
        }
      }.width('100%').height('100%')
    }
    .title($r('app.string.DigitalShield'))
    .backgroundColor('#F1F3F5')
  }
}