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
* FAQ:状态栏与页面内容发生重叠，如何解决？
*/

// [Start resolve_overlap_between_status_bar_and_page_two]
@Entry
@Component
struct AvoidStatusBar {
  statusBar: number = AppStorage.get<number>('statusBar') as number;


  build() {


    Column() {
      Row() {
        Text('ROW1')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)


      Row() {
        Text('ROW2')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)


      Row() {
        Text('ROW3')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)


      Row() {
        Text('ROW4')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)


      Row() {
        Text('ROW5')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)


      Row() {
        Text('ROW6')
          .fontSize(40)
      }
      .backgroundColor(Color.Orange)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: this.statusBar }) // The specific value of the margin or padding here should be consistent with the height of the status bar area in practice
    .backgroundColor('#008000')
  }
}
// [End resolve_overlap_between_status_bar_and_page_two]