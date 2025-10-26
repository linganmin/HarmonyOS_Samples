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
  @Provide navPathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {
        Button($r('app.string.get_ui_ability_context'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'GetUIAbilityContextDemo' });
          })

        Button($r('app.string.get_application_context'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'GetApplicationContextDemo' });
          })

        Button($r('app.string.get_window_stage'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'GetWindowStageDemo' });
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding(16)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor('#F1F3F5')
  }
}