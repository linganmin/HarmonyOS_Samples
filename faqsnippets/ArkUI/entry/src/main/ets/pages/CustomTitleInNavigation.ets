/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:Navigation自定义标题栏不生效
*/

// [Start navigationcustomtitle_example]
@Entry
@Component
export struct MainPage {
  myTitle: NavigationCustomTitle = {
    builder: this.customTitleBuilder,
    height: TitleHeight.MainOnly
  };

  @LocalBuilder
  customTitleBuilder() {
    Row() {
      Text('Title1')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 7, right: 7, top: 7 })

      Text('Title2')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 7, right: 7, top: 7 })

      Text('Title3')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 7, right: 7, top: 7 })
    }
  }

  build() {
    Navigation() {
      Column() {
        Text('hello world')
          .fontSize('24')
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi-Bold')
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .height('100%')
      .width('100%')
      .background('#F1F3F5')
    }
    .title(this.myTitle)
  }
}
// [End navigationcustomtitle_example]