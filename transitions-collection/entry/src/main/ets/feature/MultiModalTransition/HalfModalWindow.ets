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

import { display } from '@kit.ArkUI';
import { CaptchaLogin } from './CaptchaLogin';
import Constants from '../../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function MultiModalPageBuilder() {
  HalfModalWindow();
}
// [Start full_modal]
// [Start half_modal]
@Component
export struct HalfModalWindow {
  @Consume('NavPathStack') pageInfos: NavPathStack;
  // Whether to display the half-screen modal page.
  @State isPresent: boolean = false;
  // half-mode height
  @State sheetHeight: number = Constants.FONT_WEIGHT;
  // Whether to display the control bar
  @State showDragBar: boolean = true;
  // Determine whether to agree with the agreement
  @State isConfirmed: boolean = false;
  // Controlling Full-Modal Presentation
  @State isPresentInLoginView: boolean = false;
  // Transparency of the button for sending a verification code
  @State op: number = Constants.HALF_OPACITY;
  // Specifies the transition type
  // The value is false when the component is redirected from the semi-modal component to the mobile verification code component
  // and the value is true when the component is redirected from the account password component to the mobile verification code component
  @State isShowTransition: boolean = false;
  @State isCenter: boolean = true;
  @State screenW: number = 0;
  // According to the mode attribute description of Navigation
  // if Auto is used and the window width is greater than or equal to 600 vp, the Split mode is used for display
  curFoldStatus: display.FoldStatus | undefined = undefined;
  // Folded state of the current screen (valid only for devices with folded screens)
  // When the window width is less than 600 vp, the window is displayed in stack mode
  private deviceSize: number = Constants.DEFAULT_DEVICE_SIZE;

  // [StartExclude full_modal]
  // [StartExclude half_modal]
  aboutToAppear(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      this.isPresent =
        true; // When isPresent is set to true, the semi-modal page is displayed. Otherwise, the semi-modal page is not displayed
      try {
        this.screenW = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
        if (display.isFoldable()) {
          this.regDisplayListener();
        } else {
          if (this.screenW >= this.deviceSize) {
            this.isCenter = true;
          } else {
            this.isCenter = false;
          }
        }
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'HalfModalWindow', `error code=${error.code}, message=${error.message}`);
      }
    }
  }

  /**
   * Register screen status listening
   * @returns {void}
   */
  regDisplayListener(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        this.changePreferType(display.getFoldStatus());
        display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
          // Repeated triggering of the same status is not processed
          if (this.curFoldStatus === curFoldStatus) {
            return;
          }
          // Cache Current Collapse State
          this.curFoldStatus = curFoldStatus;
          this.changePreferType(this.curFoldStatus);
        })
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'HalfModalWindow',
          `regDisplayListener failed error code=${error.code}, message=${error.message}`);
      }
    }
  }

  changePreferType(status: number): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (status === display.FoldStatus.FOLD_STATUS_FOLDED) {
        this.isCenter = false;
      } else {
        this.isCenter = true;
      }
    }
  }
  // [EndExclude half_modal]
  // [EndExclude full_modal]

  @Builder
  defaultLogin() {
    Column() {
      // CheckBox to control, semi-modal, full-modal, and semi-modal confirmations in the login page
      CaptchaLogin({
        isPresent: $isPresent,
        isPresentInLoginView: $isPresentInLoginView,
        isShowTransition: $isShowTransition
      })
    }
  }

  // [StartExclude full_modal]
  @Builder
  halfModalLogin() {
    // semi-modal window page
    Column() {
      Text($r('app.string.multimodaltransion_after_login_more_service'))
        .fontColor(Color.Black)
        .fontSize($r('app.integer.font_size_normal'))
        .padding({ top: $r('app.integer.padding_top_large') })

      Text($r('app.string.multimodaltransion_user_phone_number'))
        .fontColor(Color.Black)
        .fontSize($r('app.integer.font_size_large'))
        .fontWeight(Constants.FONT_WEIGHT_SM)
        .padding({
          top: $r('app.integer.font_size_large'),
          bottom: $r('app.integer.multimodaltransion_margin_default')
        })

      Text($r('app.string.multimodaltransion_get_service'))
        .fontColor($r('app.color.multimodaltransion_grey_9'))
        .fontSize($r('app.integer.multimodaltransion_row_text_font_size'))
        .padding({ bottom: $r('app.integer.multimodaltransion_height_fifty') })

      Button($r('app.string.multimodaltransion_phone_start_login'))
        .fontColor(Color.White)
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.multimodaltransion_red'))
        .onClick(() => {
          try {
            if (this.isConfirmed) {
              this.getUIContext()
                .getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_login_success') });
              AppStorage.set('login', true);
              this.pageInfos.pop();
            } else {
              this.getUIContext()
                .getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_please_read_and_agree') });
            }
          } catch (err) {
            let error = err as BusinessError;
            hilog.error(0x0000, 'HalfModalWindow', `login failed. error code=${error.code}, message=${error.message}`);
          }
        })
        .width($r('app.string.multimodaltransion_size_ninety_percent'))
        .height($r('app.integer.multimodaltransion_height_fifty'))
        .margin({
          left: $r('app.integer.main_page_padding2'),
          right: $r('app.integer.main_page_padding2'),
          bottom: $r('app.integer.multimodaltransion_row_padding_bottom')
        })

      Button($r('app.string.multimodaltransion_captcha_login_text'))
        .fontColor(Color.Black)
        .borderRadius($r('app.integer.multimodaltransion_border_radius'))
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.multimodaltransion_btn_bgc'))
        .border({
          color: $r('app.color.multimodaltransion_half_modal_btn_bgc'),
          width: Constants.DEFAULT_ONE
        })
        .onClick(() => {
          if (this.isConfirmed) {
            this.isPresentInLoginView = true;
            this.isConfirmed = false;
            this.isShowTransition = false;
          } else {
            try {
              this.getUIContext()
                .getPromptAction()
                .showToast({ message: $r('app.string.multimodaltransion_please_read_and_agree') });
            } catch (err) {
              let error = err as BusinessError;
              hilog.error(0x0000, 'HalfModalWindow',
                `code login failed. error code=${error.code}, message=${error.message}`);
            }
          }
        })
        .width($r('app.string.multimodaltransion_size_ninety_percent'))
        .height($r('app.integer.multimodaltransion_height_fifty'))
        .margin({ bottom: $r('app.integer.font_size_large') })
      Blank()

      Row() {
        Checkbox({ name: Constants.CHECK_BOX_NAME1 })
          .select(this.isConfirmed)
          .width($r('app.integer.font_size_sm'))
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
                hilog.error(0x0000, 'HalfModalWindow',
                  `rule detail. error code=${error.code}, message=${error.message}`);
              }
            })
        }.fontSize($r('app.integer.font_size_sm'))
      }
      .margin({ left: $r('app.integer.multimodaltransion_other_ways_icon_height') })
      .width($r('app.string.multimodaltransion_size_full'))
    }
  }
  // [EndExclude full_modal]

  build() {
    NavDestination() {
      Column() {
        //The Text component is bound for semi-modal display
        // [StartExclude full_modal]
        Text()
          .bindSheet($$this.isPresent, this.halfModalLogin(), {
            height: this.sheetHeight,
            dragBar: this.showDragBar,
            preferType: this.isCenter ? SheetType.CENTER : SheetType.POPUP,
            backgroundColor: $r('app.color.multimodaltransion_btn_bgc'),
            showClose: true,
            shouldDismiss: ((sheetDismiss: SheetDismiss) => {
              sheetDismiss.dismiss();
              this.pageInfos.pop();
            })
          })
        // [EndExclude full_modal]
        // [StartExclude half_modal]
        //The Text component is bound as the full-screen modal display of the mobile phone verification code component and the account and password component
        Text()
          .bindContentCover($$this.isPresentInLoginView, this.defaultLogin())
        // [StartExclude half_modal]
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.Center)
      .size({
        width: $r('app.string.multimodaltransion_size_full'),
        height: $r('app.string.multimodaltransion_size_full')
      })
      .padding($r('app.integer.multimodaltransion_padding_default'))
    }
  }
}
// [End half_modal]
// [End full_modal]