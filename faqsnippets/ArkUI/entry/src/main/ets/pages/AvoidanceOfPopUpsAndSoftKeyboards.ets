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
* FAQ:如何实现弹窗和软键盘的避让
*/

// [Start avoidance_of_pop_ups_and_soft_keyboards]
@Entry
@Component
struct AvoidDialogPage {
  @State message: string = 'Open pop up window';
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample()
  })

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.dialogController.open();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}

@CustomDialog
struct CustomDialogExample {
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({})
  })

  build() {
    Column() {
      TextInput({})
        .fontSize(20)
        .margin({ top: 10, bottom: 10 })
        .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
        .borderWidth(0.5)
        .borderRadius(4)
        .height(40)
        .defaultFocus(true)
        .margin({
          top: 30,
          left: 16,
          right: 16,
          bottom: 30
        })
    }
  }
}

// [End avoidance_of_pop_ups_and_soft_keyboards]