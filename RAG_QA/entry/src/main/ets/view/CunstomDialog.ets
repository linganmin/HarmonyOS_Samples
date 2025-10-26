/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import SetUp from '../viewmodel/SetUp';

@CustomDialog
export struct AlertDialogEmail {
  controller?: CustomDialogController;
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.confirm_add_to_db')).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center).height('27vp')
      }
      .justifyContent(FlexAlign.Center)
      .height('56vp')
      .width('100%')

      Row() {
        Button($r('app.string.cancel_word'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close();
            }
          })
          .buttonStyle(ButtonStyleMode.NORMAL)
          .width('176vp')
          .height('40vp')
          .margin({ top: '16vp', bottom: '16vp', left: '16vp' })
          .borderRadius($r('sys.float.corner_radius_level10'))
        Button($r('app.string.confirm_word'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.confirm();
              this.controller.close();
            }
          })
          .buttonStyle(ButtonStyleMode.EMPHASIZED)
          .width('176vp')
          .height('40vp')
          .margin({
            top: '16vp',
            bottom: '16vp',
            left: '16vp',
            right: '16vp'
          })
          .borderRadius($r('sys.float.corner_radius_level10'))
      }
      .width('100%')
      .height('72vp')
    }
    .width('400vp')
    .height('128vp')
  }
}

@CustomDialog
export struct CustomDialogEmailInfo {
  @State toRecipients: Array<string> = [];
  @State ccRecipients: Array<string> = [];
  @State bccRecipients: Array<string> = [];
  @State subject: string = '';
  @State body: string = '';
  @State sender_name: string = '';
  alertDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialogEmail({
      confirm: () => {
        this.onAccept()
      }
    }),
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: '16vp',
    width: '400vp',
    height: '128vp',
    borderWidth: 1,
    borderStyle: BorderStyle.Dashed,
    borderColor: Color.Blue,
    backgroundColor: Color.White,
    shadow: (ShadowStyle.OUTER_FLOATING_SM),
  })

  onAccept() {
    this.insertEmail();
    console.info('Callback when the second button is clicked');
  }

  async insertEmail() {
    let setUp = AppStorage.get<SetUp>("SetUpObject") as SetUp;
    if (setUp) {
      let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
      await setUp.InsertSingleData(this.sender_name, this.toRecipients, this.ccRecipients,
        this.bccRecipients, this.subject, this.body, context);
      this.toRecipients = [];
      this.ccRecipients = [];
      this.bccRecipients = [];
      this.subject = '';
      this.body = '';
      this.sender_name = '';
    }
  }
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  aboutToDisappear() {
    this.alertDialogController = null;
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.add_email')).textAlign(TextAlign.Center).height('27vp')
        Blank()
        Image($r('app.media.close')).onClick(() => {
          if (this.controller != undefined) {
            this.controller.close();
          }
        }).height('40vp')
      }
      .height('56vp')
      .width('100%')
      .margin({ top: '8vp', right: '16vp', left: '16vp' })

      // sender text input
      TextInput({ placeholder: 'sender', text: this.sender_name })
        .onChange((value: string) => {
          this.sender_name = value;
        })


      // receiver text input
      TextInput({ placeholder: 'To', text: this.toRecipients.join(', ') })
        .onChange((value: string) => {
          this.toRecipients = value.split(',');
        })
        .margin({ top: '12vp' })

      // cc input
      TextInput({ placeholder: 'CC', text: this.ccRecipients.join(', ') })
        .onChange((value: string) => {
          this.ccRecipients = value.split(',');
        })
        .margin({ top: '12vp' })

      // bcc input
      TextInput({ placeholder: 'BCC', text: this.bccRecipients.join(', ') })
        .onChange((value: string) => {
          this.bccRecipients = value.split(',');
        })
        .margin({ top: '12vp' })

      // subject input
      TextInput({ placeholder: 'Subject', text: this.subject })
        .onChange((value: string) => {
          this.subject = value;
        })
        .margin({ top: '12vp' })

      // content input
      TextInput({ placeholder: 'Body', text: this.body })
        .onChange((value: string) => {
          this.body = value;
        })
        .margin({ top: 10 })
        .height('100vp')

      Row() {
        Button($r('app.string.add_to_database'))
          .onClick(() => {
            if (this.alertDialogController != null) {
              this.alertDialogController.open();
            }
          })
          .borderRadius($r('sys.float.corner_radius_level10'))
          .margin({ right: '16vp' })
          .width('368vp')
        Button($r('app.string.close_dialog'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close();
            }
          })
          .width('368vp')
          .borderRadius($r('sys.float.corner_radius_level10'))
      }
      .width('100%')
      .margin({ top: '60vp', bottom: '32vp' })
    }.width('752vp')
  }
}

@CustomDialog
export struct AlertDialogHistory {
  controller?: CustomDialogController;
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.clear_all_chat_history'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .height('27vp')
      }
      .justifyContent(FlexAlign.Center)
      .height('56vp')
      .width('100%')

      Row() {
        Button($r('app.string.cancel_word'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close();
            }
          })
          .buttonStyle(ButtonStyleMode.NORMAL)
          .width('176vp')
          .height('40vp')
          .margin({ top: '16vp', bottom: '16vp', left: '16vp' })
          .borderRadius($r('sys.float.corner_radius_level10'))
        Button($r('app.string.confirm_word'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.confirm();
              this.controller.close();
            }
          })
          .buttonStyle(ButtonStyleMode.EMPHASIZED)
          .width('176vp')
          .height('40vp')
          .margin({
            top: '16vp',
            bottom: '16vp',
            left: '16vp',
            right: '16vp'
          })
          .borderRadius($r('sys.float.corner_radius_level10'))
      }
      .width('100%')
      .height('72vp')
    }
    .width('400vp')
    .height('128vp')
  }
}