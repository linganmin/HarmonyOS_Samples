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
* FAQ:如何实现类似keyframes的效果
*/

// [Start animate_to_example]
@Entry
@Component
struct AnimateToExample {
  @State widthSize: number = 250;
  @State heightSize: number = 100;
  @State rotateAngle: number = 0;
  private flag: boolean = true;
  @State opacityValue: number = 1;

  build() {
    Column() {
      Button('change size')
        .width(this.widthSize)
        .height(this.heightSize)
        .margin(30)
        .opacity(this.opacityValue)
        .onClick(() => {
          if (this.flag) {
            // Implement multi-stage animations by animateTo
            this.getUIContext().animateTo({
              duration: 2000,
              curve: Curve.EaseOut,
              iterations: 1,
              playMode: PlayMode.Normal,
              onFinish: () => {
                this.getUIContext().animateTo({
                  duration: 2000,
                  curve: Curve.EaseOut,
                  iterations: 1,
                  playMode: PlayMode.Normal,
                  onFinish: () => {
                  }
                }, () => {
                  // Second stage, opacityValue becomes 0.2
                  this.opacityValue = 0.2;
                })
              }
            }, () => {
              // First stage, opacityValue becomes 0.5 
              this.opacityValue = 0.5;
            })
          }
        })
    }.width('100%').margin({ top: 5 })
  }
}
// [End animate_to_example]