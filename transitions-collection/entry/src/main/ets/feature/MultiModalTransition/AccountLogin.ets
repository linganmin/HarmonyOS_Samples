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

import Constants from '../../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct AccountLogin {
  // Check whether to read and agree to the service agreement and personal information processing rules
  @State isAgree: boolean = false;
  // Login Button Transparency
  @State op: number = Constants.HALF_OPACITY;
  // User input validation
  @State userIsblank: boolean = true;
  // Password input verification
  @State pwdIsblank: boolean = true;
  // This variable is used to display the verification code or account for login
  // The link and parent component are bidirectionally bound.
  @Link isDefaultLogin: boolean;
  @Link isShowTransition: boolean;
  @Consume('NavPathStack') pageInfos: NavPathStack;

  build() {
    Column({ space: Constants.SPACE_TEN }) {
      Text($r('app.string.multimodaltransion_account_login_text'))
        .fontSize($r('app.integer.multimodaltransion_font_size_middle'))
        .fontWeight(Constants.FONT_WEIGHT_SEVENTY)
        .width($r('app.string.multimodaltransion_size_eighty_percent'))
      TextInput({ placeholder: $r('app.string.multimodaltransion_place_holder') })
        .showUnderline(true)
        .type(InputType.Normal)
        .backgroundColor(Color.Transparent)
        .caretColor(Color.Grey)
        .width($r('app.string.multimodaltransion_size_account_width'))
        .margin({ top: $r('app.integer.main_page_padding2') })
        .maxLength(Constants.PHONE_NUMBER_LENGTH) // Set the maximum number of input characters
        .onChange((value: string) => {
          // When the user has input, the value of userIsblank is false
          this.userIsblank = value.length === Constants.DEFAULT_ZERO;
        })
      TextInput({ placeholder: $r('app.string.multimodaltransion_text_input_place_holder') })
        .showUnderline(true) // Show Underline
        .type(InputType.Password)
        .backgroundColor(Color.Transparent)
        .caretColor(Color.Grey)
        .width($r('app.string.multimodaltransion_size_eighty_five_percent'))
        .margin({ top: $r('app.integer.main_page_padding2') })
        .maxLength(Constants.PHONE_NUMBER_LENGTH) // Set the maximum number of input characters
        .onChange((value: string) => {
          // When a user enters a value, the value of pwdIsblank is false
          this.pwdIsblank = value.length === Constants.DEFAULT_ZERO;
        })
      Row() {
        Text($r('app.string.multimodaltransion_row_text'))
          .fontSize($r('app.integer.multimodaltransion_row_text_font_size'))
          .fontColor($r('app.color.multimodaltransion_note_color'))
          .backgroundColor($r('app.color.multimodaltransion_transparent_7'))
          .onClick(() => {
            // Switch to the verification code login mode
            this.isDefaultLogin = true;
            this.isShowTransition = true;
          })
      }
      .width($r('app.string.multimodaltransion_size_eighty_percent'))
      .padding({
        bottom: $r('app.integer.multimodaltransion_row_padding_bottom'),
        top: $r('app.integer.multimodaltransion_row_padding_top')
      })

      Button($r('app.string.multimodaltransion_account_btn_text'))
        .type(ButtonType.Normal)
        .border({ radius: $r('app.integer.multimodaltransion_border_radius') })
        .width($r('app.string.multimodaltransion_size_eighty_percent'))
        .backgroundColor($r('app.color.multimodaltransion_red'))
        .opacity(this.userIsblank || this.pwdIsblank ? Constants.HALF_OPACITY : Constants.DEFAULT_ONE)
        .onClick(() => {
          try {
            // The login button can be clicked only after the user and account information is entered
            if (this.userIsblank || this.pwdIsblank) {
              this.getUIContext().getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_please_input_account_and_pwd') });
            } else if (!this.isAgree) {
              this.getUIContext().getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_please_read_and_agree') });
            } else {
              this.getUIContext().getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_login_success') });
            }
          } catch (err) {
            let error = err as BusinessError;
            hilog.error(0x0000, 'AccountLogin',
              `login showToast failed. error code=${error.code}, message=${error.message}`);
          }
        })
      Row() {
        Checkbox({ name: Constants.CHECK_BOX_NAME })
        // The $$ operator provides references to TS variables for system built-in components
        // so that the TS variables are synchronized with the internal state of the system built-in components
          .select($$this.isAgree)
          .size({
            width: $r('app.integer.multimodaltransion_check_box_size'),
            height: $r('app.integer.multimodaltransion_check_box_size')
          })
        Text() {
          Span($r('app.string.multimodaltransion_read_and_agree'))
            .fontColor($r('app.color.multimodaltransion_grey_9'))
          Span($r('app.string.multimodaltransion_server_proxy_rule_detail'))
            .fontColor($r('app.color.multimodaltransion_note_color'))
            .onClick(() => {
              try {
                this.getUIContext().getPromptAction()
                  .showToast({ message: $r('app.string.multimodaltransion_only_show_ui') });
              } catch (err) {
                let error = err as BusinessError;
                hilog.error(0x0000, 'AccountLogin', `error code=${error.code}, message=${error.message}`);
              }
            })
        }
        .fontSize($r('app.integer.font_size_xm'))
        .textAlign(TextAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width($r('app.string.multimodaltransion_size_eighty_two_percent'))
    }
    .width($r('app.string.multimodaltransion_size_full'))
    .height($r('app.string.multimodaltransion_size_full'))
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .padding({ top: $r('app.integer.multimodaltransion_padding_top_size') })
  }
}