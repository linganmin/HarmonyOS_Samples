/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:CustomDialog自定义弹窗组件如何进行物理返回拦截
*/

// [Start custom_pop_up_physical_return_interception]
@CustomDialog
struct CustomDialogExample {
  cancel?: () => void;
  confirm?: () => void;
  controller: CustomDialogController;

  build() {
    Column() {
      Text('Are you sure?')
        .fontSize(20)
        .margin({
          top: 10,
          bottom: 10
        })
      Row() {
        Button('cancel')
          .onClick(() => {
            this.controller.close();
            if (this.cancel) {
              this.cancel();
            }
          })
          .backgroundColor(0xffffff)
          .fontColor(Color.Black)
        Button('confirm')
          .onClick(() => {
            this.controller.close();
            if (this.confirm) {
              this.confirm();
            }
          })
          .backgroundColor(0xffffff)
          .fontColor(Color.Red)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 10 })
    }
  }
}

@Component
export struct InterceptCustomDialog {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.onCancel();
      },
      confirm: () => {
        this.onAccept();
      }
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.log('dialog onWillDismiss reason: ' + dismissDialogAction.reason);
      // 1、PRESS_BACK    Click the back button, swipe left/right, and ESC on the keyboard.
      // 2、TOUCH_OUTSIDE    When clicking on the barrier layer
      // 3、CLOSE_BUTTON    Click the close button
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        // After processing the business logic, actively close the dialog box through 'dismiss'
        // dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 }
  })

  onCancel() {
    console.info('Callback when the first button is clicked');
  }

  onAccept() {
    console.info('Callback when the second button is clicked');
  }

  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          this.dialogController.open();
        })
    }
    .width('100%')
  }
}
// [End custom_pop_up_physical_return_interception]