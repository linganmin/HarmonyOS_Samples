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

import { CommonConstants } from '../common/constants/CommonConstants';
import { decryptData, encryptData, generateKey } from '../common/utils/EncryptAndDecryptUtils';
import { Param } from '../viewmodel/RouterParam';

@Entry
@Component
struct EncryptionDetailPage {
  @State content: string = '';
  @State encryptData: string = '';
  @State decryptData: string = '';
  mode: number = (this.getUIContext().getRouter().getParams() as Param).id;

  aboutToAppear(): void {
    generateKey(this.mode);
  }

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('app.media.back'))
            .width($r('app.float.back_height'))
            .height($r('app.float.back_height'))
        }
        .width($r('app.float.back_height'))
        .height($r('app.float.back_height'))
        .type(ButtonType.Circle)
        .backgroundColor($r('app.color.back_button_backgroundColor'))
        .margin({
          left: $r('app.float.title_margin_left'),
          right: $r('app.float.title_margin_right')
        })
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Text($r('app.string.Details'))
          .font({
            size: $r('app.float.title_font_size'),
            weight: CommonConstants.FONT_WEIGHT_700
          })
      }
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.FULL_PERCENT)

      Column() {
        TextInput({ placeholder: $r('app.string.Text_To_Be_encrypted') })
          .onChange((data: string) => {
            this.content = data;
          })
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_button_margin_bottom') })
        Button(CommonConstants.ENCRYPT_ALGORITHMS[this.mode])
          .onClick(() => {
            if (this.content !== '') {
              encryptData(this.content, this.mode).then(async (res: string) => {
                this.encryptData = res;
              });
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.encrypt_text_null_toast'),
                duration: CommonConstants.TOAST_DURATION
              });
            }
          })
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_textInput_margin_bottom') })
        Text($r('app.string.After_encryption'))
          .font({
            size: $r('app.float.encrypt_text_fontSize'),
            weight: CommonConstants.FONT_WEIGHT_700
          })
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_button_margin_bottom') })
        TextInput({ placeholder: $r('app.string.Encrypted_Text'), text: this.encryptData })
          .focusable(false)
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_button_margin_bottom') })
        Button(CommonConstants.DECRYPT_ALGORITHMS[this.mode])
          .onClick(() => {
            decryptData(this.mode).then(async (res: string) => {
              this.decryptData = res;
            });
          })
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_textInput_margin_bottom') })
        TextInput({ placeholder: $r('app.string.Decrypted_Text'), text: this.decryptData })
          .focusable(false)
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.encrypt_button_margin_bottom') })
      }
      .width($r('app.float.button_width'))
      .margin({ top: $r('app.float.encrypt_block_margin_top') })
    }
    .alignItems(HorizontalAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}