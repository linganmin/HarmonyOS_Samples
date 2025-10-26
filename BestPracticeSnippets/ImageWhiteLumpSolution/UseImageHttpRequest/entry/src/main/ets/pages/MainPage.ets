/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
 * 最佳实践：Image白块解决问题指导
 *
 * 直接使用Image原生组件加载网络图片白块时长较长 反例
 */

@Entry
@Component
struct MainPage {
  @State childNavStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.childNavStack) {
      Column() {
        Button('push Path to pageOne', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin({ bottom: '36vp' })
          .onClick(() => {
            this.childNavStack.pushPath({ name: 'pageOne' });
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor(Color.Transparent)
    .title('ParentNavigation')
  }
}