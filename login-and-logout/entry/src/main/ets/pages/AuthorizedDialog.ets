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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NetJudge } from '../util/JudgeHasNet';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct AuthorizedDialog {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @StorageProp('NetJudge.currNet.isUseful') isHasNetwork: boolean = false;
  @Prop inputContent: string = '';
  @Prop password: string = '';
  @Prop isChecked: boolean = false;
  @Prop allowClick: boolean = false;
  @State isShowSheet: boolean = false;
  @State center: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  private customDialogComponentId: number = CommonConstants.CUSTOM_DIALOG_COMPONENT_ID;

  aboutToAppear(): void {
    let netJudge = new NetJudge();
    netJudge.register();
    if (this.curBp === 'lg' || this.curBp === 'md') {
      this.center = true;
    }
  }

  loginVerification() {
    if (!this.inputContent || !this.password) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.input_phone_number_or_password'),
          duration: 2000
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'AuthorizedDialog', `showToast failed. code=${err.code}, message=${err.message}`);
      }
    } else if (this.inputContent && this.password && !this.allowClick) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.incorrect_mobile_number_format'),
          duration: 2000
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'AuthorizedDialog', `showToast failed. code=${err.code}, message=${err.message}`);
      }
    } else {
      if (!this.isHasNetwork) {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.network_error'),
            duration: 2000
          });
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'AuthorizedDialog', `showToast failed. code=${err.code}, message=${err.message}`);
        }
      } else {
        if (!this.isChecked) {
          this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
              this.customDialogComponent();
            },
            autoCancel: true,
            showInSubWindow: false,
            offset: { dx: CommonConstants.PROMPT_ACTION_X, dy: CommonConstants.PROMPT_ACTION_Y },
            cornerRadius: CommonConstants.CORNER_RADIUS,
            width: $r('app.float.promptAction_width'),
            height: $r('app.float.promptAction_height'),
            shadow: ({
              radius: CommonConstants.SHADOW_RADIUS,
              color: Color.Gray,
              offsetX: CommonConstants.SHADOW_X,
              offsetY: CommonConstants.SHADOW_Y
            }),
            backgroundColor: Color.White
          }).then((dialogId: number) => {
            this.customDialogComponentId = dialogId;
          }).catch((error: BusinessError)=>{
            hilog.error(0x0000, 'AuthorizedDialog', `openCustomDialog failed. code=${error.code}, message=${error.message}`);
          })
        } else {
          AppStorage.setOrCreate('isLogin', true);
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/Index'
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'AuthorizedDialog', `pushUrl failed. code=${error.code}, message=${error.message}`);
          });
        }
      }
    }
  }

  @Builder
  customDialogComponent() {
    Column() {
      Text($r('app.string.agreement_tips'))
        .fontSize($r('app.float.customDialog_text_font_size'))
        .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
      Row({ space: CommonConstants.CUSTOM_DIALOG_ROW_SPACE }) {
        Text($r('app.string.sign_in_and_agree'))
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
      }
      .width(CommonConstants.FULL_SCREEN)
      .margin({
        top: $r('app.float.customDialog_row_margin_top'),
        bottom: $r('app.float.customDialog_row_margin_bottom')
      })
      .justifyContent(FlexAlign.Start)
      .padding({ left: $r('app.float.padding') })

      Row() {
        Text($r('app.string.rejected'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor(Color.Blue)
          .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
          .textAlign(TextAlign.Center)
          .width($r('app.float.customDialog_bottom_row_width'))
          .height($r('app.float.customDialog_bottom_row_height'))
          .lineHeight($r('app.float.line_height'))
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              let err = error as BusinessError;
              hilog.error(0x0000, 'AuthorizedDialog', `closeCustomDialog failed. code=${err.code}, message=${err.message}`);
            }
          })

        Text($r('app.string.confirm_login'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor(Color.Blue)
          .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
          .textAlign(TextAlign.Center)
          .width($r('app.float.customDialog_bottom_row_width'))
          .height($r('app.float.customDialog_bottom_row_height'))
          .lineHeight($r('app.float.line_height'))
          .onClick(() => {
            AppStorage.setOrCreate('isLogin', true);
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/Index'
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, 'AuthorizedDialog', `pushUrl failed. code=${error.code}, message=${error.message}`);
            });
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId);
            } catch (error) {
              let err = error as BusinessError;
              hilog.error(0x0000, 'AuthorizedDialog', `closeCustomDialog failed. code=${err.code}, message=${err.message}`);
            }
          })
      }
      .height($r('app.float.customDialog_bottom_row_height'))
      .width(CommonConstants.FULL_SCREEN)
    }
    .width(CommonConstants.FULL_SCREEN)
    .height($r('app.float.customDialog_column_height'))
    .justifyContent(FlexAlign.SpaceAround)
    .padding($r('app.float.padding') )
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
    Button({
      type: ButtonType.Normal,
      stateEffect: true
    }) {
      Row() {
        Text($r('app.string.login'))
          .fontSize($r('app.float.login_text_font_size'))
          .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .width(CommonConstants.FULL_SCREEN)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .borderRadius($r('app.float.button_border_radius'))
    .width(CommonConstants.FULL_SCREEN)
    .backgroundColor(Color.Blue)
    .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.button_row_margin_bottom') })
    .height($r('app.float.button_height'))
    .stateEffect(this.allowClick && this.password ? true : false)
    .onClick(() => {
      this.loginVerification();
    })
  }
}