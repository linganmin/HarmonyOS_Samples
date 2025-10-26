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

// [Start multiple_properties]
// [Start one_func]
@Component
export struct MultipleProperties {
  @State w:number = 150
  @State h:number = 2
  @State brightNum:number = 1.5
  @State color:Color = Color.Red
  // [StartExclude one_func]
  // Animation closure 1, set width change
  func1() {
    this.getUIContext().animateTo({curve: Curve.Sharp, duration: 1000}, () => {
      this.w = (this.w === 80 ? 150 : 80);
    });
  }
  // Animation Closure 2, Set Color Change
  func2() {
    this.getUIContext().animateTo({curve: Curve.Sharp, duration: 1000}, () => {
      this.color = (this.color === Color.Yellow ? Color.Red : Color.Yellow);
    });
  }
  // Animation closure 3, set height variation
  func3() {
    this.getUIContext().animateTo({curve: Curve.Sharp, duration: 1000}, () => {
      this.h = (this.h === 2 ? 5 : 2);
    });
  }
  // Animation Closure 4, Set Highlight Variation
  func4() {
    this.getUIContext().animateTo({curve: Curve.Sharp, duration: 1000}, () => {
      this.brightNum= (this.brightNum=== 1.5 ? 1 : 1.5);
    });
  }
  // [EndExclude one_func]
  // [StartExclude multiple_properties]
  // Unify animation closures while simultaneously setting changes for four properties
  func() {
    this.getUIContext().animateTo({curve: Curve.Sharp, duration: 1000}, () => {
      this.w = (this.w === 80 ? 150 : 80);
      this.color = (this.color === Color.Yellow ? Color.Red : Color.Yellow);
      this.h = (this.h === 2 ? 5 : 2);
      this.brightNum= (this.brightNum=== 1.5 ? 1 : 1.5);
    });
  }
  // [EndExclude multiple_properties]
  build() {
    Column() {
      Row() {
        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
            .brightness(this.brightNum)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
            .brightness(this.brightNum)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
      }
      .height('25%')
      .width('100%')
      // [StartExclude multiple_properties]
      // [StartExclude one_func]
      Row() {
        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
            .brightness(this.brightNum)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
            .brightness(this.brightNum)
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
            .brightness(this.brightNum)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')

        Row() {
          Row()
            .width(this.w)
            .backgroundColor(this.color)
            .height(this.h)
            .brightness(this.brightNum)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
      }
      .height('25%')
      .width('100%')
      // [EndExclude one_func]
      // [EndExclude multiple_properties]

      Column() {
        // [StartExclude one_func]
        Button("Tap nFunc")
          .width('100%')
          // Key Attribute Settings
          .onClick(() => {
            // Loop animation by play count
            for (let i = 0; i < 10; i++) {
              setTimeout(() => {
                this.func1();
                this.func2();
                this.func3();
                this.func4();
              }, 1000 * i)
            }
          })
        // [EndExclude one_func]
        // [StartExclude multiple_properties]
        Button("Tap oneFunc")
          .width('100%')
          .margin({ top: 12 })
          // Key Attribute Settings
          .onClick(() => {
            // Loop animation by play count
            for (let i = 0; i < 10; i++) {
              setTimeout(() => {
                this.func();
              }, 1000 * i)
            }
          })
        // [EndExclude multiple_properties]
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
// [End one_func]
// [End multiple_properties]