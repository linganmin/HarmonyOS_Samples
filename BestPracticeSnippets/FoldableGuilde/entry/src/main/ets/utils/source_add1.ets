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

@Component
// [Start ScrollTest]
export struct ScrollTest {
  // Height of fixed area
  @State barHeight: number = 56;
  // Transparency of fixed area
  @State barOpacity: number = 1;
  // Current y-axis sliding offset
  @State currentYOffset: number = 0;

  build() {
    List() {
      // [StartExclude ScrollTest]
      ForEach(new Array(100).fill(''), () => {
        ListItem() {
          Text('北京')
            .fontSize(24)
        }
      }, (item: string) => item)
      // [EndExclude ScrollTest]
    }
    .onScrollFrameBegin((offset: number) => {
      this.currentYOffset += Math.abs(offset);
      // Take the Y-axis offset of 100 as an example. When the offset is less than 100, the fixed area is gradually hidden
      if (this.currentYOffset <= 100) {
        this.barHeight = 56 * (1 - this.currentYOffset / 100);
        this.barOpacity = 1 - this.currentYOffset / 100;
      }
      // Directly hide the fixed area when the offset is greater than 100
      else {
        this.barHeight = 0;
        this.barOpacity = 0;
      }
      return { offsetRemain: offset };
    })
    .onScrollStart(() => {
      // Reset the offset of Y-axis sliding at the beginning of sliding
      this.currentYOffset = 0;
    })
    .onScrollStop(() => {
      // Use animation to restore the height and transparency of the fixed area when sliding stops
      setTimeout(() => {
        this.getUIContext().animateTo({
          duration: 300
        }, () => {
          this.barHeight = 56;
          this.barOpacity = 1;
        })
      }, 2000);
    })
  }
}
// [End ScrollTest]