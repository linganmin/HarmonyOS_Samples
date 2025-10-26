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

import ParamPassing from 'libentry.so';
import { InputArea, InputField, OutputArea } from '../model/IOModel';
import { SampleInputObject, SampleOutputObject } from '../model/SampleObject';

@Builder
export function objectPage(_entry: string, param: string) {
  NavDestination() {
    MainComponent()
  }
  .title(param)
  .backgroundColor($r('app.color.sub_window_background'))
}

@Preview
@Component
struct MainComponent {
  @Provide inputArray: Array<InputField> = Array(2);
  @Provide printStr: string = '';

  aboutToAppear(): void {
    this.inputArray[0] = {
      label: 'Age',
      inputStr: '',
      inputType: InputType.Number,
      maxLength: 4,
    }
    this.inputArray[1] = {
      label: 'Name',
      inputStr: '',
      inputType: InputType.Normal,
    }
  }

  object2String(obj: SampleOutputObject): string {
    return `Type:${obj.isAdult ? 'Adult' : 'Child'} \nNo.:${obj.code} \nAge:${obj.age} \nName:${obj.name}`;
  }

  paramPassing() {
    let age: number;
    let name: string;
    try {
      this.inputArray.forEach((inputField, i) => {
        if (inputField.inputStr.length > 0) {
          if (i === 0) {
            let inputNumber = Number(inputField.inputStr);
            if (isNaN(inputNumber) || inputNumber < 0 || inputNumber > 150) {
              throw new Error('Please enter a reasonable age');
            } else {
              age = inputNumber;
            }
          } else {
            name = inputField.inputStr;
          }
        } else {
          throw new Error('Incomplete input');
        }
      })
      let sendObject: SampleInputObject = {
        age: age!,
        name: name!,
      };
      this.printStr = this.object2String(ParamPassing.objectPassing(sendObject));
    } catch (e) {
      this.printStr = e?.message;
    }
  }

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