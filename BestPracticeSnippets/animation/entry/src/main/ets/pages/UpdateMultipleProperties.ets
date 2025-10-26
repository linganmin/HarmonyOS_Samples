/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

// [Start update_multiple_properties1]
// [Start update_multiple_properties2]
// [Start update_multiple_properties3]
@Component
export struct UpdateMultipleProperties {
  @State w: number = 100
  @State h: number = 2
  @State color: Color = Color.Red

  build() {
    Column() {
      Row() {
        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
      }
      .height('25%')
      .width('100%')

      // [StartExclude update_multiple_properties1]
      // [StartExclude update_multiple_properties2]
      // [StartExclude update_multiple_properties3]
      Row() {
        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)

        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)

        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
      }
      .height('25%')
      .width('100%')

      Row() {
        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)

        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)

        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
      }
      .height('25%')
      .width('100%')
      // [EndExclude update_multiple_properties3]
      // [EndExclude update_multiple_properties2]
      // [EndExclude update_multiple_properties1]
      Column() {
        // [StartExclude update_multiple_properties2]
        // [StartExclude update_multiple_properties3]
        Button('Tap1')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            let doTimes = 5;
            for (let i = 0; i < doTimes; i++) {
              setTimeout(() => {
                this.w = 80
                this.h = 4
                this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 1000 }, () => {
                  this.w = (this.w === 80 ? 150 : 80);
                });
                // Updating state variables between two animateTo calls
                this.color = Color.Yellow
                this.getUIContext().animateTo({ curve: Curve.Linear, duration: 2000 }, () => {
                  this.color = (this.color === Color.Yellow ? Color.Red : Color.Yellow);
                });
              }, 2000 * i)
            }
          })
        // [EndExclude update_multiple_properties2]
        // [StartExclude update_multiple_properties1]
        Button('Tap2')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            let doTimes = 5;
            for (let i = 0; i < doTimes; i++) {
              setTimeout(() => {
                // Explicitly specify the initial values of all properties to be animated before the animation.
                this.w = 80
                this.color = Color.Yellow
                this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 1000 }, () => {
                  this.w = (this.w === 80 ? 150 : 80);
                });
                this.getUIContext().animateTo({ curve: Curve.Linear, duration: 2000 }, () => {
                  this.color = (this.color === Color.Yellow ? Color.Red : Color.Yellow);
                });
                // Refresh non-animated properties after animation completes
                this.h = 5
              }, 2000 * i)
            }
          })
        // [StartExclude update_multiple_properties2]
        // [StartExclude update_multiple_properties3]
        Button('Tap3')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            let doTimes = 5;
            for (let i = 0; i < doTimes; i++) {
              setTimeout(() => {
                this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 1000 }, () => {
                  this.w = (this.w === 80 ? 150 : 80);
                });
                this.getUIContext().animateTo({ curve: Curve.Linear, duration: 2000 }, () => {
                  this.color = (this.color === Color.Yellow ? Color.Red : Color.Yellow);
                });
              }, 2000 * i)
            }
          })
        // [EndExclude update_multiple_properties2]
        // [EndExclude update_multiple_properties1]
      }
      .justifyContent(FlexAlign.End)
      .height('25%')
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}
// [Start update_multiple_properties1]
// [Start update_multiple_properties2]
// [Start update_multiple_properties3]