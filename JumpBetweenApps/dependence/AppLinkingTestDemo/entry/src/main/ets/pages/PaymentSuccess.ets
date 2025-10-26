/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { common, Want } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Preview
// [Start Payment_success_part]
@Component
export struct PaymentSuccess {
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  backToApp() {
    const want: Want = {};
    const resultCode = 200;
    const abilityResult: common.AbilityResult = {
      want,
      resultCode
    };
    this.context.backToCallerAbilityWithResult(abilityResult, null);
  }

  aboutToAppear(): void {
    this.getUIContext().getPromptAction().showToast({
      message: "This page will automatically redirect in 3 seconds",
      duration: 3000
    })

    setTimeout(() => {
      this.backToApp()
    }, 3000)
  }

  // [StartExclude Payment_success_part]
  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.success_icon'))
          .width(72)
          .height(40.52)
        Column() {
          Text($r('app.string.payment_success'))
            .fontColor($r('app.color.color11'))
            .fontFamily('鸿蒙黑体')
            .fontSize(30)
            .lineHeight(40)
            .letterSpacing(0)
            .textAlign(TextAlign.Center)
          Text($r('app.string.payment_amount'))
            .fontColor($r('app.color.color13'))
            .fontFamily('鸿蒙黑体')
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(19)
            .letterSpacing(0)
            .textAlign(TextAlign.Center)
        }
        .height(78)

        Button($r('app.string.return_to_previous'))
          .fontSize(16)
          .fontWeight(500)
          .width(120)
          .height(40)
          .onClick(this.backToApp)
          .backgroundColor($r('app.color.color12'))
      }
      .width('100%')
      .height(223)
      .margin({ top: 139 })
      .padding({ top: 16, bottom: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title('支付成功')
  }
  // [EndExclude Payment_success_part]
}
// [End Payment_success_part]