/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CommonConstants from '../constants/CommonConstants';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.encrypt_sample'))
        .fontSize($r('app.float.text_fontsize'))
        .lineHeight($r('app.float.text_lineHeight'))
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Navigation(this.pageInfos) {
      Column({ space: CommonConstants.COLUMN_SPACE }) {
        Button($r('app.string.encrypt_btn'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pageInfos.pushPathByName('EncryptionAndDecryption', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)

        Button($r('app.string.signature_btn'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pageInfos.pushPathByName('SignatureVerification', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)

        Button($r('app.string.message_btn'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pageInfos.pushPathByName('MessageSummary', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)

        Button($r('app.string.code_btn'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pageInfos.pushPathByName('MessageAuthenticationCode', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
      }
      .justifyContent(FlexAlign.End)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding($r('app.float.medium_padding'))
    }
    .title(this.NavigationTitle)
    .backgroundColor($r('app.color.background_page'))
    .mode(NavigationMode.Stack)
  }
}