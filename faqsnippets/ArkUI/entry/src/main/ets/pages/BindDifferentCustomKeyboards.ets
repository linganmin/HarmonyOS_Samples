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
* FAQ:如何给不同输入框绑定不同的自定义键盘
*/

// [Start bind_different_custom_keyboards]
@Entry
@Component
struct TextInputExample {
  controller: TextInputController = new TextInputController();
  @State inputValue: string = '';
  controller1: TextInputController = new TextInputController();
  @State inputValue1: string = '';
  controller2: TextInputController = new TextInputController();
  @State inputValue2: string = '';


  build() {
    Column() {
      this.input({ inputValue: this.inputValue, controller: this.controller, index: 0 });
      this.input({ inputValue: this.inputValue1, controller: this.controller1, index: 1 });
      this.input({ inputValue: this.inputValue2, controller: this.controller2, index: 2 });
    }
  }


  @Builder
  input(tmp: Tmp) {
    if (tmp.index === 0) {
      TextInput({ controller: tmp.controller, text: tmp.inputValue })
        .customKeyboard(this.keyboard())
        .margin(10)
        .border({ width: 1 })
        .height('48vp')
    } else if (tmp.index === 1) {
      TextInput({ controller: tmp.controller, text: tmp.inputValue })
        .customKeyboard(this.keyboard1())
        .margin(10)
        .border({ width: 1 })
        .height('48vp')
    } else {
      TextInput({ controller: tmp.controller, text: tmp.inputValue })
        .customKeyboard(this.keyboard2())
        .margin(10)
        .border({ width: 1 })
        .height('48vp')
    }
  }


  @Builder
  keyboard() {
    CustomKeyboardBuilder({ inputValue: this.inputValue, controller: this.controller, index: 0 });
  }


  @Builder
  keyboard1() {
    CustomKeyboardBuilder({ inputValue: this.inputValue1, controller: this.controller1, index: 1 });
  }


  @Builder
  keyboard2() {
    CustomKeyboardBuilder({ inputValue: this.inputValue2, controller: this.controller2, index: 2 });
  }
}


class Tmp {
  inputValue?: string;
  controller?: TextInputController;
  index?: number;
}


// Customize keyboard components
@Component
export struct CustomKeyboardBuilder {
  controller?: TextInputController = new TextInputController();
  index: number = 0;
  @Link inputValue: string;


  build() {
    Column() {
      Button('x').onClick(() => {
        // Turn off custom keyboard
        this.controller?.stopEditing();
      })
      Grid() {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, '*', 0, '#'], (item: number | string) => {
          GridItem() {
            Button(item + '')
              .backgroundColor(this.index === 0 ? Color.Blue :
                (this.index === 1 ? Color.Green : Color.Red))
              .width(110)
              .onClick(() => {
                this.inputValue += item;
              })
          }
        })
      }
      .maxCount(3)
      .columnsGap(10)
      .rowsGap(10)
      .padding(5)
    }
    .backgroundColor(Color.Gray)
  }
}
// [End bind_different_custom_keyboards]