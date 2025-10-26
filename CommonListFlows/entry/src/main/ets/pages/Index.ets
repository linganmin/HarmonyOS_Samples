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
struct Index {
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();

  @Builder
  navTitleBuilder() {
    Text($r('app.string.common_list'))
      .fontSize(30)
      .fontWeight(700)
      .padding({ left: 16 })
  }

  build() {
    Navigation(this.pageInfo) {
      Column() {
        Button($r('app.string.multiple_types_list'))
          .width('100%')
          .onClick(() => {
            // Jump to multi type list scene page.
            this.pageInfo.pushPathByName('HomePage', null);
          })
        Button($r('app.string.top_tab_list'))
          .width('100%')
          .margin({ top: 12, bottom: 12 })
          .onClick(() => {
            // Jump to Tab Ceiling Scene Page.
            this.pageInfo.pushPathByName('ManagerPage', null);
          })
        Button($r('app.string.group_ceiling'))
          .width('100%')
          .onClick(() => {
            // Jump to the group ceiling scene page.
            this.pageInfo.pushPathByName('CityList', null);
          })
          .margin({ bottom: 12 })
        Button($r('app.string.secondary_linkage'))
          .width('100%')
          .onClick(() => {
            // Jump to the second level linkage scene page.
            this.pageInfo.pushPathByName('CategoryPage', null);
          })
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .justifyContent(FlexAlign.End)
    }
    .title(this.navTitleBuilder())
    .width('100%')
    .height('100%')
    .backgroundColor(0xF1F3F5)
  }
}