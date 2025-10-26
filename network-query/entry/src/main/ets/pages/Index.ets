/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { WifiConnector } from '../view/WifiConnector';
import { NetworkMonitor } from '../view/NetworkMonitor';
import { WlanLocation } from '../view/WlanLocation';
import { NetworkDiagnostics } from '../view/NetworkDiagnostics';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if (name === 'WifiConnector') {
      WifiConnector()
    } else if (name === 'NetworkMonitor') {
      NetworkMonitor()
    } else if (name === 'WlanLocation') {
      WlanLocation()
    } else if (name === 'NetworkDiagnostics') {
      NetworkDiagnostics()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column({ space: 12 }) {
        Button($r('app.string.title_connect_specified_network'))
          .width('100%')
          .onClick(() => {
            this.pageStack.pushPathByName('WifiConnector', '');
          })
        Button($r('app.string.title_network_aware'))
          .width('100%')
          .onClick(() => {
            this.pageStack.pushPathByName('NetworkMonitor', '');
          })
        Button($r('app.string.title_wlan_positioning'))
          .width('100%')
          .onClick(() => {
            this.pageStack.pushPathByName('WlanLocation', '');
          })
        Button($r('app.string.title_network_troubleshooting'))
          .width('100%')
          .onClick(() => {
            this.pageStack.pushPathByName('NetworkDiagnostics', '');
          })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
    }
    .height('100%')
    .width('100%')
    .navDestination(this.PagesMap)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.background_secondary'))
    .title($r('app.string.title_network_query'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}