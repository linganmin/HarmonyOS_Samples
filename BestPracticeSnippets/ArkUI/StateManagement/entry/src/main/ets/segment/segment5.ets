/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
@Builder
export function Segment05Builder() {
  NavDestination(){
    UnnecessaryState2()
  }
}
// [Start Case2_start]
@Entry
@Component
struct UnnecessaryState2 {
  @State message: string = '';
  // Define methods for changing state variables (intermediate variables are manipulated during method execution, state variables are modified only once)
  appendMsg(newMsg: string) {
    let message = this.message;
    message += newMsg;
    message += ';';
    message += '<br/>';
    this.message = message;
  }
  build() {
    Column() {
      Button('Click Print Log')
        .onClick(() => {
          this.appendMsg('Manipulating Temporary Variables'); // Calling encapsulated methods for changing state variables
        })
        .width('90%')
        .backgroundColor(Color.Blue)
        .fontColor(Color.White)
        .margin({ top: 10 })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 15 })
  }
}
// [End Case2_start]