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
* FAQ:如何自定义弹窗的弹出动画和关闭动画
*/

// [Start customize_pop_up_and_close_animations]
@CustomDialog
struct CustomDialogExample {
  controller: CustomDialogController;
  @State showFlag: Visibility = Visibility.Visible;

  build() {
    Column() {
      Button('Close the pop-up window')
    }
    .width('100%')
    .height(400)
    .backgroundColor(Color.Gray)
    .onClick(() => {
      this.cancel();
    })
    .visibility(this.showFlag)
    //Set the animation event to 200ms in the core code, and set the starting point and ending point for component transitions to 100vp below the screen
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }).combine(TransitionEffect.translate({ y: 100 })))
  }

  //When deleting, it should be noted that if the pop-up window is closed directly, there will be no transition effect. You can first use explicit and implicit control,
  //Set the pop-up window to be hidden, and the downward exit animation will take effect. Then set a delay to close the pop-up window.
  cancel() {
    this.showFlag = Visibility.Hidden;
    setTimeout(() => {
      this.controller.close();
    }, 200)
  }
}

@Entry
@Component
struct CustomDialogUser {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample(),
    autoCancel: false,
    customStyle: true
  })

  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          this.dialogController.open();
        })
    }
    .width('100%')
    .height('100%')
  }
}
// [End customize_pop_up_and_close_animations]