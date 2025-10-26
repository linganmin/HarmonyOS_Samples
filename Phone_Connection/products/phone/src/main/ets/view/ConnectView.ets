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

import { ConnectUtil } from 'utils';

@Builder
export function ConnectViewBuilder() {
  ConnectView()
}

@Component
struct ConnectView {
  @State message: string = '';
  connectUtils: ConnectUtil = new ConnectUtil(this.getUIContext().getHostContext() as Context);
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.connectUtils.getConnectedDevices();
  }

  build() {
    NavDestination() {
      Column() {
        TextArea({ placeholder: $r('app.string.message_input') })
          .width('100%')
          .height(120)
          .margin({
            top: 18
          })
          .onChange((value: string) => {
            this.message = value;
          })
        Button($r('app.string.sendMessage'))
          .width(328)
          .height(40)
          .margin({
            top: 12
          })
          .onClick(() => {
            this.connectUtils.sendMessage(this.message);
          })
      }
      .padding({
        left: 16,
        right: 16
      })
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.interconnection_communication'))
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  aboutToDisappear(): void {
    this.connectUtils.unregisterMessageReceiver();
  }
}