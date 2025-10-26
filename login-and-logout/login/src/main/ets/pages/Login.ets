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

import { CommonConstants } from '../common/CommonConstants';
import { AuthorizedDialog } from './AuthorizedDialog';

@Builder
export function LoginBuilder() {
  Login()
}

@Entry
@Component
export  struct Login {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @State inputContent: string = '';
  @State password: string = '';
  @State isChecked: boolean = false;
  @State allowClick: boolean = false;
  @State isShowSheet: boolean = false;
  @State center: boolean = false;

  aboutToAppear(): void {
    if (this.curBp === 'lg' || this.curBp === 'md') {
      this.center = true;
    }
  }

  @Builder
  mySheet() {
    Column() {
      Blank()
      .width(CommonConstants.FULL_SCREEN)
      .height($r('app.float.mySheet_row_height'))

      Column() {
        Image($r('app.media.privacy'))
          .width($r('app.float.mySheet_image_width'))
          .height($r('app.float.mySheet_image_height'))
        Text($r('app.string.privacy_title'))
          .fontSize($r('app.float.account_text_size'))
          .margin({ top: $r('app.float.md_padding_margin') })
          .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
          .height($r('app.float.account_height'))

        Text($r('app.string.update_date'))
          .fontSize($r('app.float.update_text_font_size'))
          .margin({ top: $r('app.float.update_text_margin_top') })
          .fontColor(Color.Gray)
          .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
          .height($r('app.float.account_height'))

        Column() {
          Text($r('app.string.introductory_1'))
            .lineHeight($r('app.float.line_height'))
        }
        .width(CommonConstants.FULL_SCREEN)
        .margin({ top: $r('app.float.mySheet_column_text_margin_top') })

        Column() {
          Text($r('app.string.introductory_2'))
            .margin({ bottom: $r('app.float.mySheet_text_margin_bottom') })
          Text($r('app.string.introductory_3'))
            .lineHeight($r('app.float.line_height'))
        }
        .width(CommonConstants.FULL_SCREEN)
        .margin({ top: $r('app.float.mySheet_column_text_margin_top') })
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text($r('app.string.introductory_4'))
            .lineHeight($r('app.float.line_height'))
          Text($r('app.string.introductory_5'))
            .lineHeight($r('app.float.line_height'))
        }
        .width(CommonConstants.FULL_SCREEN)
        .margin({ top: $r('app.float.mySheet_column_text_margin_top') })
        .alignItems(HorizontalAlign.Start)
      }
      .width(CommonConstants.FULL_SCREEN)
      .height(CommonConstants.FULL_SCREEN)
      .margin({ bottom: $r('app.float.mySheet_margin_bottom') })
      .padding({
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
    }
    .width(CommonConstants.FULL_SCREEN)
    .height(CommonConstants.FULL_SCREEN)
    .backgroundColor(Color.White)
    .padding($r('app.float.padding'))
  }

  build() {
    Stack() {
      GridRow({
        columns: {
          sm: CommonConstants.LOGIN_COLUMN_SM,
          md: CommonConstants.LOGIN_COLUMN_MD,
          lg: CommonConstants.LOGIN_COLUMN_LG
        }
      }) {
        GridCol({
          span: {
            sm: CommonConstants.LOGIN_SPAN_SM,
            md: CommonConstants.LOGIN_SPAN_MD,
            lg: CommonConstants.LOGIN_SPAN_LG
          },
          offset: {
            sm: CommonConstants.LOGIN_OFFSET_SM,
            md: CommonConstants.LOGIN_OFFSET_MD,
            lg: CommonConstants.LOGIN_OFFSET_LG
          }
        }) {
          Column() {
            Image($r('app.media.login_user'))
              .width($r('app.float.portrait_width'))
              .height($r('app.float.portrait_height'))
              .margin({ top: $r('app.float.portrait_margin_top') })
            Text($r('app.string.login_account'))
              .fontSize($r('app.float.account_text_size'))
              .margin({ top: $r('app.float.md_padding_margin') })
              .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
              .height($r('app.float.account_height'))
            TextInput({
              placeholder: $r('app.string.mobile_number')
            })
              .type(InputType.PhoneNumber)
              .enterKeyType(EnterKeyType.Next)
              .enableKeyboardOnFocus(true)
              .defaultFocus(true)
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
              .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
              .maxLength(CommonConstants.TEXT_INPUT_MAX_LENGTH)
              .width(CommonConstants.FULL_SCREEN)
              .constraintSize({ minHeight: $r('app.float.textInput_constraintSize') })
              .padding({
                left: $r('app.float.textInput_padding_left')
              })
              .borderRadius($r('app.float.textInput_borderRadius'))
              .borderColor($r('sys.color.ohos_id_color_warning'))
              .inputFilter('^[0-9*]+$')
              .onChange((value: string) => {
                this.inputContent = value;
                this.allowClick = (this.inputContent.length === 11 ? true : false);
              })
              .margin({ top: $r('app.float.textInput_margin_top'), bottom: $r('app.float.textInput_margin_bottom') })
            TextInput({
              placeholder: $r('app.string.password')
            })
              .type(InputType.Password)
              .enterKeyType(EnterKeyType.Next)
              .enableKeyboardOnFocus(true)
              .defaultFocus(true)
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
              .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .maxLength(CommonConstants.PASSWORD_MAX_LENGTH)
              .width(CommonConstants.FULL_SCREEN)
              .constraintSize({ minHeight: $r('app.float.password_constraintSize') })
              .padding({
                left: $r('app.float.password_padding_left')
              })
              .borderRadius($r('app.float.password_borderRadius'))
              .borderColor($r('sys.color.ohos_id_color_warning'))
              .margin({ bottom: $r('app.float.password_margin_bottom') })
              .onChange((value: string) => {
                this.password = value;
              })
            Row() {
              Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
                .select(false)
                .selectedColor(Color.Blue)
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  this.isChecked = value;
                })
              Text($r('app.string.read_and_agreed'))
                .fontSize($r('app.float.agreements_font_size'))
                .margin({ right: $r('app.float.agreements_margin_right') })
                .fontColor(Color.Grey)
              Text($r('app.string.user_authentication_protocol'))
                .fontColor(Color.Blue)
                .onClick(() => {
                  this.isShowSheet = !this.isShowSheet;
                })
                .bindSheet(this.isShowSheet, this.mySheet(), {
                  height: this.center ? $r('app.float.bindSheet_height_widescreen') : $r('app.float.bindSheet_height'),
                  dragBar: false,
                  preferType: this.center ? SheetType.CENTER : SheetType.BOTTOM,
                  onDisappear: () => {
                    this.isShowSheet = !this.isShowSheet;
                  }
                })
                .fontSize($r('app.float.agreements_font_size'))
            }
            .width(CommonConstants.FULL_SCREEN)
            .justifyContent(FlexAlign.Start)

            Blank()
              .width(CommonConstants.FULL_SCREEN)
              .height($r('app.float.mySheet_row_height_login'))

            AuthorizedDialog({
              inputContent: this.inputContent,
              password: this.password,
              isChecked: this.isChecked,
              isShowSheet: this.isShowSheet,
              allowClick: this.allowClick
            })

            Row() {
              Text($r('app.string.register_account'))
                .fontSize($r('app.float.normal_text_size'))
                .fontColor(Color.Blue)
                .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
                .textAlign(TextAlign.Center)

              Text($r('app.string.forgot_password'))
                .fontSize($r('app.float.normal_text_size'))
                .fontColor(Color.Blue)
                .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
                .textAlign(TextAlign.Center)
            }
            .width(CommonConstants.FULL_SCREEN)
            .margin({ bottom: $r('app.float.button_row_margin_bottom') })
          }
          .width(CommonConstants.FULL_SCREEN)
          .height(CommonConstants.FULL_SCREEN)
          .padding({
            left: $r('app.float.md_padding_margin'),
            right: $r('app.float.md_padding_margin')
          })
        }
      }
      .padding({
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
    }
    .width(CommonConstants.FULL_SCREEN)
    .height(CommonConstants.FULL_SCREEN)
    .backgroundColor($r('app.color.login_page_background'))
  }
}