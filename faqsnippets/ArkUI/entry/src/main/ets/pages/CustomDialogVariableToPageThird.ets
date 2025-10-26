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
* FAQ:自定义弹窗中的变量如何传递给页面
*/

// [Start dialog_demo_third]
let storage = LocalStorage.getShared();
@CustomDialog
struct CustomDialog03 {
  @LocalStorageLink('inputVal') inputValue: string = '';
  controller: CustomDialogController;

  build() {
    Column() {
      Text('Change text')
        .fontSize(20)
        .margin({ top: 10, bottom: 10 })
      TextInput({ placeholder: '', text: this.inputValue })
        .height(60)
        .width('90%')
        .onChange((value: string) => {
          this.inputValue = value;
        })
    }
  }
}

@Entry(storage)
@Component
struct DialogDemo03 {
  @LocalStorageLink('inputVal') inputValue: string = 'click me';
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialog03()
  });

  build() {
    Column() {
      Button(this.inputValue)
        .onClick(() => {
          this.dialogController.open();
        })
        .backgroundColor(0x317aff)
    }
    .width('100%')
    .margin({ top: 5 })
  }
}
// [End dialog_demo_third]