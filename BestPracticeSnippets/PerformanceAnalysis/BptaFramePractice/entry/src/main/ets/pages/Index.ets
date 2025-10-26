/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

// [Start animationdemo1]
@Entry
@Component
struct AnimationDemo1 {
  @State widthSize: number = 200;
  @State heightSize: number = 100;
  @State flag: boolean = true;

  computeSize() {
    let duration = 2000;
    let period = 16;
    let widthSizeEnd = 0;
    let heightSizeEnd = 0;
    if (this.flag) {
      widthSizeEnd = 100;
      heightSizeEnd = 50;
    } else {
      widthSizeEnd = 200;
      heightSizeEnd = 100;
    }
    let doTimes = duration / period;
    let deltaHeight = (heightSizeEnd - this.heightSize) / doTimes;
    let deltaWeight = (widthSizeEnd - this.widthSize) / doTimes;
    for (let i = 1; i <= doTimes; i++) {
      let t = period * (i);
      setTimeout(() => {
        this.heightSize = this.heightSize + deltaHeight;
        this.widthSize = this.widthSize + deltaWeight;
      }, t);
    }
    this.flag = !this.flag;
  }


  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          let delay = 500;
          setTimeout(() => {
            this.computeSize();
          }, delay);
        })
        .width(this.widthSize)
        .height(this.heightSize)
        .backgroundColor(0x317aff)
    }.width('100%')
    .margin({ top: 5 })
  }
}
// [End animationdemo1]