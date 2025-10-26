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

// [Start libentry]
import ParamPassing from 'libentry.so';
// [End libentry]
import { InputArea, InputField, OutputArea } from '../model/IOModel';

@Builder
export function uint8ArrayPage(_entry: string, param: string) {
  NavDestination() {
    MainComponent()
  }
  .title(param)
  .backgroundColor($r('app.color.sub_window_background'))
}

@Preview
@Component
struct MainComponent {
  @Provide inputArray: Array<InputField> = Array(5);
  @Provide printStr: string = '';

  aboutToAppear(): void {
    for (let i = 0; i < 5; i++) {
      this.inputArray[i] = {
        label: 'Num ' + i.toString(),
        inputStr: '',
        inputType: InputType.Number,
        maxLength: 3,
        placeholder: $r('app.string.input_hint_nums_0_255'),
      }
    }
  }

  // [Start param_passing]
  // entry/src/main/ets/pages/Uint8ArrayPage.ets
  paramPassing() {
    let sendArray: number[] = [];
    try {
      this.inputArray.forEach((inputField) => {
        if (inputField.inputStr.length > 0) {
          if (Number(inputField.inputStr) <= 0xff) {
            sendArray.push(Number(inputField.inputStr));
          } else {
            throw new Error('Invalid data type.');
          }
        }
      })
      this.printStr = `Array: [${ParamPassing.uint8ArrayPassing(new Uint8Array(sendArray))}]`;
    } catch (e) {
      this.printStr = e?.message;
    }
  }
  // [End param_passing]

  build() {
    Column() {
      InputArea()
      OutputArea()
      Blank()
      Button($r('app.string.button_text_execute'))
        .onClick(() => {
          this.paramPassing();
        })
        .width($r('app.string.100percent'))
    }
    .padding($r("app.string.margin_l"))
    .width($r('app.string.100percent'))
    .height($r('app.string.100percent'))
  }
}