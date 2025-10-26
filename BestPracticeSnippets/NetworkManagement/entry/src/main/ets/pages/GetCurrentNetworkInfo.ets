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

@Builder
export function GetCurrentNetworkInfoBuilder() {
  GetCurrentNetworkInfo()
}

@Entry
@Component
struct GetCurrentNetworkInfo {
  @State text: string = '';
  @State textArea: string = '';
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.query_current_network_information'))
        .fontSize(20)
        .lineHeight(40)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Button($r('app.string.cellular_network_query'))
          .onClick(() => {
            this.pathStack.pushPathByName('CellularNetworkQuery', null, false);
          })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.wifi_query'))
          .onClick(() => {
            this.pathStack.pushPathByName('WiFiQuery', null, false);
          })
          .width('100%')
          .backgroundColor('#0A59F7')
      }
      .justifyContent(FlexAlign.End)
      .height('100%')
      .padding(16)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .title(this.NavDestinationTitle())
  }
}