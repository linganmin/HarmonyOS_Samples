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

import { BluetoothClient } from './BluetoothClient';
import { BluetoothServer } from './BluetoothServer';
import { HeartRate } from './HeartRate';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'BluetoothServer') {
      BluetoothServer();
    } else if (name === 'BluetoothClient') {
      BluetoothClient();
    } else if (name === 'HeartRate') {
      HeartRate();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.bluetooth_low_energy'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .height(56)
          .margin({ top: 56 })
        Column({ space: 12 }) {
          Button($r('app.string.ble_server'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'BluetoothServer' });
            })
            .width('100%')
          Button($r('app.string.ble_client'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'BluetoothClient' });
            })
            .width('100%')
        }
        .height(248)
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 32,
        left: 16,
        right: 16,
        bottom: 32
      })
      .backgroundColor('#F5F5F5')
    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
  }
}