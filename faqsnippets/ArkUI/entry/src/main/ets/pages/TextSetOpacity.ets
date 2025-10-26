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
* FAQ: Text组件设置opacity后，文字颜色在整体透明度基础上叠加了一个透明，应该如何处理
*/

// [Start text_set_opacity]
@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Text('你好')
          .width(200)
          .height(100)
          .fontColor(Color.White)
          .backgroundColor(Color.Blue)
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .opacity(0.3)
          .margin(20)

        Text('你好')
          .width(200)
          .height(100)
          .fontColor(Color.White)
          .backgroundColor(Color.Blue)
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .opacity(0.3)
          .renderGroup(true)
      }
      .width('100%')
    }
    .height('100%')
  }
}

// [End text_set_opacity]