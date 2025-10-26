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
import { Logger } from '../utils/Logger';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import bluetoothClientModel, { ConnectionState } from '../viewmodel/BluetoothClientModel';
import EmptyPage from '../uicomponents/EmptyPage';
import BluetoothDevice from '../model/BluetoothDevice';
import { i18n } from '@kit.LocalizationKit';

const LIST_SPACE: number = 20;
const PERMISSION_LIST: Array<Permissions> = [
  'ohos.permission.ACCESS_BLUETOOTH'
];
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context: Context = uiContext?.getHostContext()!;

function reqPermissionFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    Logger.info(`data:${JSON.stringify(data)}`);
  }).catch((err: BusinessError) => {
    Logger.error(`requestPermissionsFromUser fail: err = ${JSON.stringify(err)}`);
  })
}

@Component
export struct BluetoothClient {
  @State arr: number[] = [1, 2, 3, 4];
  @StorageLink('availableDevices') @Watch('onAvailableDevicesChange') availableDevices: Array<BluetoothDevice> = [];
  @StorageLink('connectBluetoothDevice') @Watch('onConnectBluetoothDeviceChange') connectBluetoothDevice: BluetoothDevice =
    {};
  @State connectBluetoothDevice1: BluetoothDevice = {};
  private windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();

  onAvailableDevicesChange(): void {
    Logger.info(`onAvailableDevicesChange: availableDevices = ${JSON.stringify(this.availableDevices)}`);
  }

  onConnectBluetoothDeviceChange(): void {
    this.connectBluetoothDevice1 = this.connectBluetoothDevice;
    Logger.info(`onConnectBluetoothDeviceChange,${JSON.stringify(this.connectBluetoothDevice1)}`);
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      Logger.info('setWindowOrientation Succeeded');
    }).catch((err: BusinessError) => {
      Logger.error(`setWindowOrientation Failed. Cause:${JSON.stringify(err)}`);
    })
  }

  async onPageShow(): Promise<void> {
    this.setOrientation(window.Orientation.UNSPECIFIED);
  }

  aboutToAppear(): void {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    reqPermissionFromUser(PERMISSION_LIST, context);
    this.setOrientation(window.Orientation.PORTRAIT);
  }

  aboutToDisappear(): void {
    bluetoothClientModel.close();
  }

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.list_of_bluetooth_devices'))
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
        if (this.availableDevices && this.availableDevices.length > 0 && this.availableDevices[0].deviceId) {
          List({ space: LIST_SPACE, initialIndex: 0 }) {
            ForEach(this.availableDevices as BluetoothDevice[], (item: BluetoothDevice, index: number) => {
              ListItem() {
                if (item.deviceId === this.connectBluetoothDevice1.deviceId) {
                  Item({
                    bluetoothDevice: this.connectBluetoothDevice1 as BluetoothDevice,
                    index: index
                  })
                } else {
                  Item({
                    bluetoothDevice: item as BluetoothDevice,
                    index: index
                  })
                }
              }
              .width('100%')
              .height(76)
              .borderRadius(16)
              .backgroundColor(Color.White)
            })
          }
          .scrollBar(BarState.Auto)
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .padding({
            left: 16,
            top: 16,
            right: 16,
            bottom: 0
          })
        } else {
          EmptyPage({ img: $r('app.media.bg_empty_page'), message: $r('app.string.no_equipment') })
            .width('100%')
            .height('100%')
            .layoutWeight(1)
        }
        Row() {
          Button($r('app.string.search_device'))
            .id('btn_start_scan')
            .fontSize(16)
            .onClick(() => {
              const ret = bluetoothClientModel.startBLEScan();
              if (!ret) {
                Logger.info(`startBLEScan: ret= ${ret}`);
              }
            })
            .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .padding({
      top: 32,
      bottom: 32
    })
    .title(this.NavDestinationTitle())
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct Item {
  @StorageLink('isSecondaryConnection') isSecondaryConnection: boolean = false;
  @State bluetoothDevice: BluetoothDevice = {};
  @State isEnglish: boolean = false;
  @Consume('NavPathStack') pathStack: NavPathStack;
  private index: number = 0;
  private windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
  private time: number = -1;

  aboutToAppear(): void {
    let systemLanguage = i18n.System.getSystemLanguage();
    if (systemLanguage === 'en-Latn-US') {
      this.isEnglish = true;
    }
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      Logger.info('setWindowOrientation Succeeded');
    }).catch((err: BusinessError) => {
      Logger.error(`setWindowOrientation Failed. Cause:${JSON.stringify(err)}`);
    })
  }

  getConnectionStateDescription(): ResourceStr {
    let description = $r('app.string.connect');
    switch (this.bluetoothDevice.connectionState) {
      case ConnectionState.STATE_CONNECTING:
        description = $r('app.string.connecting');
        break;
      case ConnectionState.STATE_DISCONNECTING:
        description = $r('app.string.disconnecting');
        break;
      case ConnectionState.STATE_CONNECTED:
        description = $r('app.string.connect');
        break;
      default:
        description = $r('app.string.connect');
    }
    return description;
  }

  build() {
    Row() {
      Column() {
        Text(this.bluetoothDevice.deviceName)
          .fontSize(16)
          .fontColor('#333333')
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(this.bluetoothDevice.deviceId)
          .fontSize(14)
          .fontColor(Color.Black)
          .opacity(0.6)
          .margin({ top: 6 })
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .width('75%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Button(this.getConnectionStateDescription())
        .id(`btn_connect${this.index}`)
        .fontSize(16)
        .fontColor('#FF0A59F7')
        .backgroundColor(this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED ? '#00000000' :
          '#0D000000')
        .padding({ left: 16, right: 16 })
        .visibility(this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED ? Visibility.None :
        Visibility.Visible)
        .onClick(() => {
          if (this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTING) {
            clearInterval(this.time);
            this.time = setTimeout(() => {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.connection_failed_please_rescan'),
                duration: 2000
              })
            }, 10000)
            return;
          }
          if (this.isSecondaryConnection) {
            this.bluetoothDevice.connectionState = ConnectionState.STATE_CONNECTED;
            AppStorage.setOrCreate('connectBluetoothDevice', this.bluetoothDevice);
            AppStorage.setOrCreate('availableDevices', [this.bluetoothDevice]);
            bluetoothClientModel.onBLECharacteristicChange();
            return;
          }
          if (this.bluetoothDevice.connectionState === ConnectionState.STATE_DISCONNECTED) {
            let isConnected = bluetoothClientModel.connect(this.bluetoothDevice);
            if (isConnected) {
              AppStorage.setOrCreate('isSecondaryConnection', true);
            }
          } else if (this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED) {
            bluetoothClientModel.disconnect();
          }
        })

      Row() {
        Text($r('app.string.connected'))
          .fontSize(16)
          .fontColor(Color.Black)
          .opacity(0.6)
          .margin({ right: 8 })

        Image($r('app.media.ic_public_arrow_right'))
          .width(13)
          .height(13)
      }
      .visibility(this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED ? Visibility.Visible :
      Visibility.None)
      .justifyContent(FlexAlign.End)
      .margin(this.isEnglish ? { right: 16 } : { right: 0 })
    }
    .id(`list_item${this.index}`)
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      if (this.bluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED) {
        this.pathStack.pushPath({ name: 'HeartRate' });
      }
    })
  }
}