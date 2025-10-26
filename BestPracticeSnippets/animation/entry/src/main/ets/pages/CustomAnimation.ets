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

// [Start custom_animation]
@Component
export struct CustomAnimation {
  @State widthSize: number = 80
  @State heightSize: number = 40
  @State flag: boolean = true

  // Custom animation function
  computeSize() {
    let duration = 2000
    // Set the loop cycle
    let period = 1
    let widthSizeEnd = 0
    let heightSizeEnd = 0
    if (this.flag) {
      widthSizeEnd = 50
      heightSizeEnd = 25
    } else {
      widthSizeEnd = 80
      heightSizeEnd = 40
    }
    // Calculate loop count
    let doTimes = duration / period
    // Calculate the variation per cycle
    let deltaHeight = (heightSizeEnd - this.heightSize) / doTimes
    let deltaWeight = (widthSizeEnd - this.widthSize) / doTimes
    // Loop, with each cycle the component increases in width and height by a portion.
    for (let i = 1; i <= doTimes; i++) {
      let t = period * (i);
      setTimeout(() => {
        this.heightSize = this.heightSize + deltaHeight
        this.widthSize = this.widthSize + deltaWeight
      }, t)
    }
    this.flag = !this.flag
  }

  build() {
    Column() {
      Column() {
        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }
        // [StartExclude custom_animation]
        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }

        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }

        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }

        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }

        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }

        Row() {
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
          Button()
            .width(this.widthSize)
            .height(this.heightSize)
            .margin(20)
        }
        // [EndExclude custom_animation]
      }
      .height('85%')

      Column() {
        Button('Tap me')
          .width('100%')
          .onClick(() => {
            setTimeout(() => {
              this.computeSize()
            }, 500)
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('15%')
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
// [End custom_animation]