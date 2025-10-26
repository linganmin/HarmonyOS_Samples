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
export function Segment03Builder() {
  NavDestination(){
    UnnecessaryState1()
  }
}
// [Start Case1_start]
@Observed
class Translate {
  translateX: number = 20;
}

@Component
struct UnnecessaryState1 {
  @State translateObj: Translate = new Translate(); // If there are both read and write operations and a Button component is associated with it, it is recommended to use state variables.
  buttonMsg = 'I am button'; // Only read the value of the variable buttonMsg, without any write operations, just use the general variables directly
  build() {
    Column() {
      Button(this.buttonMsg)
        .onClick(() => {
          this.getUIContext().animateTo({
            duration: 50
          }, () => {
            this.translateObj.translateX = (this.translateObj.translateX + 50) % 150; // Reassign value to variable translateObj when clicked.
          })
        })
    }
    .translate({
      x: this.translateObj.translateX // Retrieve the value in translateObj.
    })
  }
}
// [End Case1_start]