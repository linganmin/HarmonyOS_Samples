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

// [Start my_radio]
@Builder
function myRadio() {
  Text($r('app.string.radio'))
    .width('100%')
    .fontColor($r('sys.color.mask_secondary'))
  Row() {
    Radio({ value: '1', group: 'radioGroup' })
      .margin({ right: $r('app.float.margin_right') })
    Text('man')
  }
  .width('100%')

  Row() {
    Radio({ value: '0', group: 'radioGroup' })
      .margin({ right: $r('app.float.margin_right') })
    Text('woman')
  }
  .width('100%')
}

@Builder
function myCheckBox() {
  Text($r('app.string.checkbox'))
    .width('100%')
    .fontColor($r('sys.color.mask_secondary'))
  Row() {
    CheckboxGroup({ group: 'checkboxGroup' })
      .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
    Text('all')
      .margin({ left: $r('app.float.margin_right') })
  }
  .width('100%')

  Row() {
    Checkbox({ name: '1', group: 'checkboxGroup' })
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .margin({ right: $r('app.float.margin_right') })
    Text('text1')
  }
  .width('100%')

  Row() {
    Checkbox({ name: '0', group: 'checkboxGroup' })
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .margin({ right: $r('app.float.margin_right') })
    Text('text2')
  }
  .width('100%')
}
// [End my_radio]

// [Start factory_map]
// Define the component factory Map.
let factoryMap: Map<string, object> = new Map();

// The components that need to be factory stored in the component factory.
factoryMap.set('Radio', wrapBuilder(myRadio));
factoryMap.set('Checkbox', wrapBuilder(myCheckBox));

// Export assembly factory
export { factoryMap };
// [End factory_map]