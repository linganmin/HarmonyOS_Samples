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

// [Start animate_to1]
class MyData {
  str: string;

  constructor(str: string) {
    this.str = str;
  }
}

@Entry
@Component
struct Index {
  @State data1: MyData | undefined = new MyData("branch 0");
  @State data2: MyData | undefined = new MyData("branch 1");

  build() {
    Column() {
      if (this.data1) {
        // If adding/deleting in the animation, it will add default transitions to the Text
        // When deleting, increasing the default transparency transition will extend the lifecycle of the component. The Text component is not actually deleted, but is only deleted after the transition animation is completed
        // Add an additional layer of null protection when using data, and only use the str in data1 if it exists
        Text(this.data1?.str)
          .id("1")
      } else if (this.data2) {
        // If adding/deleting in the animation, it will add default transitions to the Text
        // Add another layer of null protection when using data
        Text(this.data2?.str)
          .id("2")
      }
      Button("play with animation")
        .onClick(() => {
          this.getUIContext().animateTo({}, () => {
            // Modifying the if condition in animateTo will give default transitions to the first layer components under if in the animation
            if (this.data1) {
              this.data1 = undefined;
              this.data2 = new MyData("branch 1");
            } else {
              this.data1 = new MyData("branch 0");
              this.data2 = undefined;
            }
          })
        })
    }.width("100%")
    .padding(10)
  }
}
// [End animate_to1]