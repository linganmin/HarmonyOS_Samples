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
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .lineHeight(48)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 16 })
    }
    .width('100%')
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 12 }) {
        Button($r('app.string.query_Network_connection_information'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('GetNetworkConnectionInfo', null, false);
          })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.query_current_network_information'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('GetCurrentNetworkInfo', null, false);
          })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.network_status_listening'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('ListeningNetworkStatus', null, false);
          })
          .width('100%')
          .backgroundColor('#0A59F7')
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title(this.NavigationTitle())
    .titleMode(NavigationTitleMode.Full)
  }
}