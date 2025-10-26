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

@Entry
@Component
struct mainPageView {
  @Provide('PageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.tab1'))
        .width(328)
        .height(40)
        .margin({ left: '16' })
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }.alignItems(HorizontalAlign.Start)
  }


  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.tab2'))
          .width(328)
          .height(40)
          .margin({ bottom: '12' })
          .onClick(() => {
            this.pageStack.pushPathByName("MainPage", null, false);
          })

        Button($r('app.string.tab3'))
          .width(328)
          .height(40)
          .margin({ bottom: '16' })
          .onClick(() => {
            this.pageStack.pushPathByName("ImperativeViewComponent", null, false);
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .title(this.NavigationTitle())
    .titleMode(NavigationTitleMode.Full)
    .mode(NavigationMode.Stack)
  }
}