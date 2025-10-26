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

import { HashMap } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit'
import ParamPassing from 'libentry.so';
import { InputArea, InputField, OutputArea } from '../model/IOModel';

@Builder
export function hashMapPage(_entry: string, param: string) {
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
        label: 'Student ' + i,
        inputStr: '',
        inputType: InputType.Number,
        maxLength: 1,
        placeholder: $r('app.string.input_hint_nums_0_9')
      }
    }
  }

  // [Start hash_map2_rec]
  // entry\src\main\cpp\napi_init.cpp
  hashMap2Rec(map: HashMap<string, Object>): Record<string, Object> {
    let Rec: Record<string, Object> = {}

    try {
      map.forEach((value: Object, key: string) => {
        // value may also be HashMap
        if (value instanceof HashMap) {
          let vRec: Record<string, Object> = this.hashMap2Rec(value);
          value = vRec;
        }
        Rec[key] = value;
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `forEach fail. code = ${err.code}, message = ${err.message}`);
    }

    return Rec;
  }

  // [End hash_map2_rec]

  paramPassing() {
    let sendMap: HashMap<string, number> = new HashMap();
    try {
      this.inputArray.forEach((inputField) => {
        if (inputField.inputStr.length > 0) {
          sendMap.set(inputField.label, Number(inputField.inputStr));
        }
      })
      // Serialized
      let sendStr: string = JSON.stringify(this.hashMap2Rec(sendMap));
      let receiveStr: string = ParamPassing.hashMapPassing(sendStr);
      // NonSerialized

      // [Start receive_obj]
      // entry/src/main/ets/pages/HashMapPage.ets
      let receiveObj: object = JSON.parse(receiveStr);
      let receiveMap: HashMap<string, number> = new HashMap();
      Object.entries(receiveObj).forEach((value: [string, number]) => {
        receiveMap.set(value[0], value[1]);
      })
      // [End receive_obj]

      this.printStr = JSON.stringify(this.hashMap2Rec(receiveMap));
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