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
* FAQ:如何给UI组件设置不同情况下的属性
*/

// [Start set_different_attributes]
@Entry
@Component
struct TestHeightPage {
  @State message: string = 'Hello World';
  @State myHeight1: number = 30;
  @State myHeight2: number = 60;
  @State flag: boolean = false

  build() {
    Column() {
      Text(this.message)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .height(this.flag ? this.myHeight1 : this.myHeight2)
        .backgroundColor(Color.Orange)

      Button('Modify Text attribute height').onClick(() => {
        this.flag = !this.flag;
      }).margin({ top: 12 })
    }
    .height('100%')
  }
}

// [End set_different_attributes]