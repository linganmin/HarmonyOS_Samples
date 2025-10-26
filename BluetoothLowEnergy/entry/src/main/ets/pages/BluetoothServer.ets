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

import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import advertiseBluetoothViewModel from '../viewmodel/AdvertiseBluetoothViewModel';
import MathUtils from '../utils/MathUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';


const MIN_HEART_RATE = 40;
const MAX_HEART_RATE = 200;


const PERMISSION_LIST: Array<Permissions> = [
  'ohos.permission.ACCESS_BLUETOOTH'
];

function reqPermissionFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    Logger.info(`data:${JSON.stringify(data)}`);
  }).catch((err: BusinessError) => {
    Logger.error(`requestPermissionsFromUser fail: err = ${JSON.stringify(err)}`);
  })
}

@Component
export struct BluetoothServer {
  @StorageLink('deviceId') @Watch('onDeviceIdChange') deviceId: string = '';
  @StorageLink('bluetoothEnable') @Watch('onBluetoothEnableChange') bluetoothEnable: boolean = false;
  @State startAdvertiserState: boolean = false;
  @State localName: string = '';
  @State heartRate: number = -1;
  private mIntervalId: number = -1;

  onDeviceIdChange(): void {
    Logger.info(`onDeviceIdChange: deviced = ${this.deviceId}`);
  }

  onBluetoothEnableChange(): void {
    if (this.bluetoothEnable) {
      this.toggleAdvertiser();
    } else {
      advertiseBluetoothViewModel.stopAdvertiser();
      this.toggleHeartRate(false);
      this.startAdvertiserState = false;
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.bluetooth_off_Stop_heart_rate_broadcast'),
          duration: 2000
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'BluetoothServer',
          `showToast failed. code=${err.code}, message=${err.message}`);
      }
    }
  }

  stringToBytes(val: string): number {
    let that = new util.TextEncoder('utf-8');
    let result = that.encodeInto(val);
    return result?.length ?? 0;
  }

  toggleAdvertiser(): void {
    if (this.startAdvertiserState) {
      advertiseBluetoothViewModel.stopAdvertiser();
      this.toggleHeartRate(false);
      this.startAdvertiserState = false;
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.ble_heart_rate_broadcast_is_disabled'),
          duration: 2000
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'BluetoothServer',
          `showToast failed. code=${err.code}, message=${err.message}`);
      }
    } else {
      let BLEName: string = advertiseBluetoothViewModel.getLocalName();
      if (this.stringToBytes(BLEName) > 22) {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.change_bluetooth_name'),
            duration: 2000
          });
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'BluetoothServer',
            `showToast failed. code=${err.code}, message=${err.message}`);
        }
        return;
      }
      let ret = advertiseBluetoothViewModel.startAdvertiser();
      if (ret) {
        this.localName = BLEName;
        this.toggleHeartRate(true);
        this.startAdvertiserState = true;
        try {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.the_ble_heart_rate_broadcast_has_been_enabled'),
            duration: 2000
          });
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'BluetoothServer',
            `showToast failed. code=${err.code}, message=${err.message}`);
        }
      }
    }
  }

  toggleHeartRate(open: boolean): void {
    clearInterval(this.mIntervalId);
    if (open) {
      this.mIntervalId = setInterval(() => {
        this.heartRate = MathUtils.getRandomInt(MIN_HEART_RATE, MAX_HEART_RATE);
        if (this.deviceId) {
          advertiseBluetoothViewModel.notifyCharacteristicChanged(this.deviceId, this.heartRate);
        }
      }, 1000)
    }
  }

  aboutToAppear(): void {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    reqPermissionFromUser(PERMISSION_LIST, context);
  }

  aboutToDisappear(): void {
    advertiseBluetoothViewModel.stopAdvertiser();
  }

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.ble_server'))
        .fontSize(20)
        .lineHeight(42)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
        .opacity(0.9)
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          Row() {
            Text($r('app.string.bluetooth_name',this.localName))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .align(Alignment.Start)
          }
          .width('100%')
          .height(54)
          .backgroundColor(Color.White)
          .borderRadius(18)
          .padding({ left: 12 })

          Row() {
            Text($r('app.string.current_heart_rate'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .align(Alignment.Start)
            Text((this.heartRate > 0 ? this.heartRate.toString() + 'bpm' : ''))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .align(Alignment.Start)
          }
          .width('100%')
          .height(54)
          .backgroundColor(Color.White)
          .borderRadius(18)
          .padding({ left: 12 })
        }

        Row() {
          Button(this.startAdvertiserState ? $r('app.string.turn_off_ble_heart_rate_broadcast') :
          $r('app.string.enable_ble_heart_rate_broadcast'))
            .onClick(() => {
              this.toggleAdvertiser();
            })
            .width('100%')
        }

      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({
      top: 32,
      bottom: 32
    })
    .backgroundColor('#F5F5F5')
    .title(this.NavDestinationTitle())
  }
}