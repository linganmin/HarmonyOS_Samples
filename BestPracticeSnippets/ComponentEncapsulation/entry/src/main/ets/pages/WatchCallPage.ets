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
// [Start watch]
@Component
export struct ChildComponent {
  @State bgColor: ResourceColor = Color.White;
  @Link @Watch('switchColor') checkFlag: boolean;

  private switchColor() {
    if (this.checkFlag) {
      this.bgColor = Color.Red;
    } else {
      this.bgColor = Color.White;
    }
  }

  build() {
    Column() {
      Text('Child Component')
    }.backgroundColor(this.bgColor)
    .borderWidth(1)
  }
}

@Entry
@Component
struct Index {
  @State childCheckFlag: boolean = false;

  build() {
    Column() {
      ChildComponent({ checkFlag: this.childCheckFlag })

      Button('Switch Color')
        .onClick(() => {
          this.childCheckFlag = !this.childCheckFlag;
        })
        .margin({ top: 16 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

// [End watch]