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

import { HTTPReconnection } from './HTTPReconnection';
import { RCPReconnection } from './RCPReconnection';
import { SocketReconnection } from './SocketReconnection';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if (name === 'HTTPReconnection') {
      HTTPReconnection();
    } else if (name === 'RCPReconnection') {
      RCPReconnection();
    } else if (name === 'SocketReconnection') {
      SocketReconnection();
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text($r('app.string.network_reconnection'))
          .width('100%')
          .fontColor('#E6000000')
          .fontSize(30)
          .fontWeight(700)
          .lineHeight(40)
          .textAlign(TextAlign.Start)
          .margin({ top: 64 })

        Blank()

        Button($r('app.string.http_download'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('HTTPReconnection', '');
          })

        Button($r('app.string.rcp_download'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('RCPReconnection', '');
          })

        Button($r('app.string.Socket_download'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('SocketReconnection', '');
          })

      }
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
  }
}
