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
* FAQ:Navigation的toolbar中设置大图标时被切断
*/

// [Start cut_off_when_setting_large_icon]
@Entry
@Component
struct NavigationExample {
  build() {
    Column() {
      Navigation() {
      }.toolbarConfiguration(this.navigationToolbar)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Gray)
  }

  @Builder
  navigationToolbar() {
    Row() {
      Column() {
        Image($r('app.media.icon')).width(24)
      }.layoutWeight(1)

      Column() {
        Image($r('app.media.icon')).width(24).scale({ x: 2, y: 2 })
      }.layoutWeight(1)

      Column() {
        Image($r('app.media.icon')).width(24)
      }.layoutWeight(1)
    }
    .height(34)
    .width('100%').backgroundColor(Color.White)
  }
}
// [End cut_off_when_setting_large_icon]