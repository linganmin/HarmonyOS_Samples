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

import { AccountLogin } from './AccountLogin';
import Constants from '../../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct CaptchaLogin {
  // Controlling the Presentation of Half-Modalities
  @Link isPresent: boolean;
  // Controlling Full-Modal Presentation
  @Link isPresentInLoginView: boolean;
  // Controlling the Display of the Verification Code for Login
  @State isDefaultLogin: boolean = true;
  // Transparency of the login button
  @State op: number = Constants.HALF_OPACITY;
  // Determine whether to agree with the agreement
  isConfirmed: boolean = false;
  // Specifies the transition type. The value is false when the component is redirected from the semi-modal component to the mobile verification code component
  // and the value is true when the component is redirected from the account password component to the mobile verification code component.
  @Link isShowTransition: boolean;
  // 1: Define the entry effect of the semi-modal transition to this component and the transition effect of the subsequent switching between components.
  //    There is no effect when entering the site, and the transition is pushed from the left
  // 1.1. Define the transition effect of the verification code login page
  private effect1: TransitionEffect =
    TransitionEffect.asymmetric(
      TransitionEffect.IDENTITY,
      TransitionEffect.move(TransitionEdge.START)
        .animation({ duration: Constants.EFFECT_DURATION, curve: Curve.Linear }));
  // 1.2. Define the transition effect of the verification code login page
  // It is used for the transition effect when the subsequent component is switched to this component, which is pushed from the left.
  private effect3: TransitionEffect =
    TransitionEffect
      .move(TransitionEdge.START).animation({ duration: Constants.EFFECT_DURATION, curve: Curve.Linear });
  // 2. Define the transition effect of the account login page and push it from the right.
  private effect2: TransitionEffect =
    TransitionEffect
      .move(TransitionEdge.END).animation({ duration: Constants.EFFECT_DURATION, curve: Curve.Linear });
  @Consume('NavPathStack') pageInfos: NavPathStack;

  aboutToAppear(): void {
    this.isPresent = false;
  }

  aboutToDisappear(): void {
    this.pageInfos.pop();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.isDefaultLogin) {
        Column({ space: Constants.SPACE_FIFTEEN }) {
          Row({ space: Constants.SPACE_FIFTEEN }) {
            Column({ space: Constants.SPACE_FIFTEEN }) {
              Text($r('app.string.multimodaltransion_phone_back'))
                .fontSize($r('app.integer.multimodaltransion_font_size_middle'))
                .fontWeight(Constants.FONT_WEIGHT_SEVENTY)
                .fontColor(Color.Black)
              Text($r('app.string.multimodaltransion_auto_after_login'))
                .fontColor($r('app.color.multimodaltransion_grey_3'))
                .fontWeight(Constants.FONT_WEIGHT_NORMAL)
                .opacity(Constants.HALF_OPACITY)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(VerticalAlign.Top)
          .width($r('app.string.multimodaltransion_size_eighty_percent'))
          .padding({ bottom: $r('app.integer.multimodaltransion_check_box_size') })

          Row() {
            Text($r('app.string.multimodaltransion_86'))
            Image($r('app.media.multimodaltransion_arrow_right'))
              .size({
                width: $r('app.integer.multimodaltransion_arrow_right_height'),
                height: $r('app.integer.multimodaltransion_arrow_right_height')
              })
              .margin({
                top: $r('app.integer.multimodaltransion_margin_default'),
                left: $r('app.integer.multimodaltransion_margin_default'),
                bottom: $r('app.integer.multimodaltransion_margin_default')
              })
              .onClick(() => {
                try {
                  this.getUIContext().getPromptAction()
                    .showToast({ message: $r('app.string.multimodaltransion_only_show_ui') });
                } catch (err) {
                  let error = err as BusinessError;
                  hilog.error(0x0000, 'CaptchaLogin',
                    `back showtoast failed. error code=${error.code}, message=${error.message}`);
                }
              })
            TextInput({ placeholder: $r('app.string.multimodaltransion_input_phone_number') })
              .type(InputType.PhoneNumber)
              .backgroundColor(Color.Transparent)
              .caretColor(Color.Grey)
              .width($r('app.string.multimodaltransion_size_full'))
              .maxLength(Constants.PHONE_NUMBER_LENGTH)
              .onChange((value: string) => {
                if (value.length === Constants.PHONE_NUMBER_LENGTH) {
                  this.op = Constants.DEFAULT_ONE;
                } else {
                  this.op = Constants.HALF_OPACITY;
                }
              })
          }
          .height($r('app.integer.multimodaltransion_user_image_height'))
          .width($r('app.string.multimodaltransion_size_eighty_percent'))

          Text($r('app.string.multimodaltransion_captcha_change_title_text'))
            .fontColor($r('app.color.multimodaltransion_note_color'))
            .fontSize($r('app.integer.multimodaltransion_height_fifty_five'))
            .backgroundColor($r('app.color.multimodaltransion_transparent_7'))
            .width($r('app.string.multimodaltransion_size_eighty_percent'))
            .padding({ bottom: $r('app.integer.multimodaltransion_margin_default') })
            .onClick(() => {
              // Log in to the account.
              this.isDefaultLogin = false;
            })

          Button($r('app.string.multimodaltransion_captcha_get'))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Normal)
            .borderRadius($r('app.integer.multimodaltransion_border_radius'))
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.multimodaltransion_red'))
            .opacity(this.op)
            .onClick(() => {
              try {
                if (this.isConfirmed) {
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: $r('app.string.multimodaltransion_captcha_sent') });
                } else {
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: $r('app.string.multimodaltransion_please_read_and_agree') });
                }
              } catch (err) {
                let error = err as BusinessError;
                hilog.error(0x0000, 'CaptchaLogin', `error code=${error.code}, message=${error.message}`);
              }
            })
            .width($r('app.string.multimodaltransion_size_eighty_percent'))
          Row() {
            Checkbox({ name: Constants.CHECK_BOX_NAME1 })
              .select(this.isConfirmed)
              .size({
                width: $r('app.integer.multimodaltransion_check_box_size'),
                height: $r('app.integer.multimodaltransion_check_box_size')
              })
              .onChange((value: boolean) => {
                this.isConfirmed = value;
              })
            Text() {
              Span($r('app.string.multimodaltransion_read_and_agree'))
                .fontColor($r('app.color.multimodaltransion_grey_9'))
              Span($r('app.string.multimodaltransion_server_proxy_rule_detail'))
                .fontColor($r('app.color.multimodaltransion_note_color'))
                .onClick(() => {
                  try {
                    this.getUIContext()
                      .getPromptAction()
                      .showToast({ message: $r('app.string.multimodaltransion_only_show_ui') });
                  } catch (err) {
                    let error = err as BusinessError;
                    hilog.error(0x0000, 'xxx', `error code=${error.code}, message=${error.message}`);
                  }
                })
            }
            .fontSize($r('app.integer.font_size_xm'))
            .flexShrink(Constants.DEFAULT_ONE) // After flexShrink is set, if the component exceeds the parent component, the component will be compressed
          }
          .alignItems(VerticalAlign.Center)
          .padding({ bottom: $r('app.integer.multimodaltransion_margin_default') })
          .width($r('app.string.multimodaltransion_size_eighty_two_percent'))

          Blank()
        }
        .transition(this.isShowTransition ? this.effect3 : this.effect1)
        .width($r('app.string.multimodaltransion_size_full'))
        .height($r('app.string.multimodaltransion_size_full'))
        .backgroundColor(Color.White)
        .padding({
          bottom: $r('app.integer.multimodaltransion_padding_mid'),
          top: $r('app.integer.multimodaltransion_padding_top')
        })
        .justifyContent(FlexAlign.Center)
      } else {
        AccountLogin({ isDefaultLogin: $isDefaultLogin, isShowTransition: $isShowTransition })
          .transition(this.effect2)
      }
      Image($r('app.media.multimodaltransion_close'))
        .width($r('app.integer.multimodaltransion_height_fifty_five'))
        .height($r('app.integer.multimodaltransion_height_fifty_five'))
        .margin({
          top: $r('app.integer.multimodaltransion_margin_close_top'),
          left: $r('app.integer.multimodaltransion_margin_close_left')
        })
        .onClick(() => {
          this.isPresentInLoginView = false;
        })
    }
    .size({
      width: $r('app.string.multimodaltransion_size_full'),
      height: $r('app.string.multimodaltransion_size_full')
    })
  }
}