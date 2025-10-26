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

// [Start click_error]
@Entry
@Component
struct ClickError {
  @State scaleValue: number = 0.5; // Pantograph ratio
  @State animated: boolean = true; // Control zoom

  build() {
    Stack() {
      Stack() {
        Text('click')
          .fontSize(45)
          .fontColor(Color.White)
      }
      .borderRadius(50)
      .width(100)
      .height(100)
      .backgroundColor('#e6cfe6')
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .onClick(() => {
        // When the animation is delivered, the count is increased by 1
        this.getUIContext().animateTo({
          curve: Curve.EaseInOut,
          duration: 350,
          onFinish: () => {
            // At the end of the animation, the count is reduced by 1
            // A count of 0 indicates the end of the last animation
              // Determine the final zoom size at the end of the animation
              const EPSILON: number = 1e-6;
              if (Math.abs(this.scaleValue - 0.5) < EPSILON) {
                this.scaleValue = 1;
              } else {
                this.scaleValue = 2;
              }
          },
        }, () => {
          this.animated = !this.animated;
          this.scaleValue = this.animated ? 0.5 : 2.5;
        })
      })
    }
    .height('100%')
    .width('100%')
  }
}
// [End click_error]