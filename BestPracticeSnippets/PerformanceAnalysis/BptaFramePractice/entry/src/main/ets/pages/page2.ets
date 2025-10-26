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

// [Start animationdemo2]
@Entry
@Component
struct AnimationDemo2 {
  @State widthSize: number = 200;
  @State heightSize: number = 100;
  @State flag: boolean = true;

  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          if (this.flag) {
            this.widthSize = 100;
            this.heightSize = 50;
          } else {
            this.widthSize = 200;
            this.heightSize = 100;
          }
          this.flag = !this.flag;
        })
        .width(this.widthSize)
        .height(this.heightSize)
        .backgroundColor(0x317aff)
        .animation({
          duration: 2000,
          curve: Curve.Linear,
          delay: 500,
          iterations: 1,
          playMode: PlayMode.Normal
        })
    }
    .width('100%')
    .margin({ top: 5 })
  }
}
// [End animationdemo2]