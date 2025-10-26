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
/**
 * 最佳实践：低功耗蓝牙开发实践
 */
// [Start access1]
import { access, ble, connection, constant } from '@kit.ConnectivityKit';
// [End access1]
import { promptAction } from '@kit.ArkUI';
import ArrayBufferUtils from '../utils/ArrayBufferUtils';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');


interface CharacteristicModel {
  serviceUuid: string,
  characteristicUuid: string,
  characteristicValue: ArrayBufferLike,
  descriptors: Array<ble.BLEDescriptor>
}

interface NotifyCharacteristicModel {
  serviceUuid: string,
  characteristicUuid: string,
  characteristicValue: ArrayBufferLike,
  confirm: boolean
}

export class AdvertiseBluetoothViewModel {
  private mGattServer: ble.GattServer | undefined;
  private stateChangeFunc = (data: access.BluetoothState): void => {
    if (data === access.BluetoothState.STATE_ON) {
      AppStorage.setOrCreate('bluetoothEnable', true);
    } else if (data === access.BluetoothState.STATE_OFF) {
      AppStorage.setOrCreate('bluetoothEnable', false);
    }
  }
  private connectionStateChangeFunc = (data: ble.BLEConnectionChangeState): void => {
    if (data) {
      if (data.state === constant.ProfileConnectionState.STATE_CONNECTED) {
        let deviceId = data.deviceId;
        AppStorage.setOrCreate('deviceId', deviceId);
      } else if (data.state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        AppStorage.setOrCreate('deviceId', '');
      }
    }
  }

  isBluetoothEnabled(): boolean {
    let state: access.BluetoothState = 0;
    try {
      state = access.getState();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'AdvertiseBluetoothViewModel',
        `isBluetoothEnabled failed. code=${err.code}, message=${err.message}`);
    }
    Logger.info(`isBluetoothEnabled: state = ${state}`);
    if (state === access.BluetoothState.STATE_ON || state === access.BluetoothState.STATE_TURNING_ON) {
      return true;
    }
    return false;
  }

  enableBluetooth() {
    try {
      this.onBTStateChange();
      access.enableBluetooth();
    } catch (err) {
      Logger.error(`enableBluetooth: err = ${JSON.stringify(err)}`);
    }
  }

  disableBluetooth() {
    try {
      this.offBTStateChange();
      access.disableBluetooth();
    } catch (err) {
      Logger.error(`disableBluetooth: err = ${JSON.stringify(err)}`);
    }
  }

  getLocalName(): string {
    let localName = '';
    try {
      localName = connection.getLocalName();
    } catch (err) {
      Logger.error(`getLocalName: err = ${JSON.stringify(err)}`);
    }
    return localName;
  }

  // [Start tooth1]
  startAdvertiser(): boolean {
    if (!this.isBluetoothEnabled()) {
      this.enableBluetooth();
      try {
        uiContext?.getPromptAction().showToast({
          message: $r('app.string.bluetooth_enabled_please_wait'),
          duration: 2000
        })
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'AdvertiseBluetoothViewModel',
          `showToast failed. code=${err.code}, message=${err.message}`);
      }
      return false;
    }
    // Create a GattServer instance
    this.mGattServer = ble.createGattServer();
    this.mGattServer.on('descriptorWrite', this.onDescriptorWrite);
    // [StartExclude tooth1]
    let descriptors: Array<ble.BLEDescriptor> = [];
    const arrayBuffer = ArrayBufferUtils.byteArray2ArrayBuffer([11]);
    const descriptor: ble.BLEDescriptor = {
      serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
      characteristicUuid: '00002A37-0000-1000-8000-00805F9B34FB',
      descriptorUuid: '00002902-0000-1000-8000-00805F9B34FB',
      descriptorValue: arrayBuffer
    }
    descriptors[0] = descriptor;

    let characteristics: Array<ble.BLECharacteristic> = [];
    const arrayBufferC = ArrayBufferUtils.byteArray2ArrayBuffer([1]);
    let characteristic: ble.BLECharacteristic = {
      serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
      characteristicUuid: '00002A37-0000-1000-8000-00805F9B34FB',
      characteristicValue: arrayBufferC,
      descriptors: descriptors
    }
    characteristics[0] = characteristic;
    // [EndExclude tooth1]
    // Define the heart rate beating service
    const service: ble.GattService = {
      serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
      isPrimary: true,
      characteristics: characteristics,
      includeServices: []
    }

    try {
      // Add a service
      this.mGattServer.addService(service);
    } catch (err) {
      Logger.error(`addService: err = ${JSON.stringify(err)}`);
    }

    try {
      // The status of the subscription connection service
      this.onConnectStateChange();
      // [StartExclude tooth1]
      let setting: ble.AdvertiseSetting = {
        interval: 160,
        txPower: 1,
        connectable: true
      }

      let advData: ble.AdvertiseData = {
        serviceUuids: ['0000180D-0000-1000-8000-00805F9B34FB'],
        manufactureData: [],
        serviceData: [],
        includeDeviceName: true
      }

      let advResponse: ble.AdvertiseData = {
        serviceUuids: ['0000180D-0000-1000-8000-00805F9B34FB'],
        manufactureData: [],
        serviceData: []
      }
      // [EndExclude tooth1]
      ble.startAdvertising(setting, advData, advResponse);
      return true;
    } catch (err) {
      Logger.error(`startAdvertiser: err = ${JSON.stringify(err)}`);
    }
    return false
  }

  onDescriptorWrite = (descriptorWriteRequest: ble.DescriptorWriteRequest) => {
    let arrayBufferDesc = new ArrayBuffer(8);
    let descValue = new Uint8Array(arrayBufferDesc);
    let deviceId: string = descriptorWriteRequest.deviceId;
    let transId: number = descriptorWriteRequest.transId;
    let offset: number = descriptorWriteRequest.offset;
    let value: Uint8Array = new Uint8Array(descriptorWriteRequest.value);

    descValue[0] = value[0];
    let serverResponse: ble.ServerResponse = {
      deviceId: deviceId,
      transId: transId,
      status: 0,
      offset: offset,
      value: arrayBufferDesc
    };

    try {
      this.mGattServer?.sendResponse(serverResponse);
    } catch (err) {
      console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // [End tooth1]
  stopAdvertiser() {
    if (this.mGattServer) {
      try {
        this.offConnectStateChange();
        ble.stopAdvertising();
        this.disableBluetooth();
      } catch (err) {
        Logger.error(`stopAdvertiser: err = ${JSON.stringify(err)}`);
      }
    }
  }

  // [Start not_char]
  notifyCharacteristicChanged(deviceId: string, heartRate: number) {
    if (!deviceId) {
      return;
    }
    if (this.mGattServer) {
      try {
        let descriptors: Array<ble.BLEDescriptor> = [];
        let arrayBuffer = ArrayBufferUtils.byteArray2ArrayBuffer([11]);
        let descriptor: ble.BLEDescriptor = {
          serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
          characteristicUuid: '00002A37-0000-1000-8000-00805F9B34FB',
          descriptorUuid: '00002902-0000-1000-8000-00805F9B34FB',
          descriptorValue: arrayBuffer
        }
        descriptors[0] = descriptor;

        let arrayBufferC = ArrayBufferUtils.byteArray2ArrayBuffer([0x00, heartRate]);
        let characteristic: CharacteristicModel = {
          serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
          characteristicUuid: '00002A37-0000-1000-8000-00805F9B34FB',
          characteristicValue: arrayBufferC,
          descriptors: descriptors
        }

        let notifyCharacteristic: NotifyCharacteristicModel = {
          serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
          characteristicUuid: '00002A37-0000-1000-8000-00805F9B34FB',
          characteristicValue: characteristic.characteristicValue,
          confirm: false
        }

        this.mGattServer.notifyCharacteristicChanged(deviceId, notifyCharacteristic, (err: BusinessError) => {
          if (err) {
            Logger.error(`notifyCharacteristicChanged callback failed: err = ${JSON.stringify(err)}`);
          } else {
            Logger.info('notifyCharacteristicChanged callback success');
          }
        })
      } catch (err) {
        Logger.error(`notifyCharacteristicChanged: err = ${JSON.stringify(err)}`);
      }
    }
  }

  // [End not_char]
  // [Start on_bts]
  private onBTStateChange() {
    try {
      access.on('stateChange', (data: access.BluetoothState) => {
        if (data === access.BluetoothState.STATE_ON) {
          AppStorage.setOrCreate('bluetoothEnable', true);
        } else if (data === access.BluetoothState.STATE_OFF) {
          AppStorage.setOrCreate('bluetoothEnable', false);
        }
      })
    } catch (err) {
      Logger.error(`onBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [End on_bts]
  private offBTStateChange() {
    try {
      access.off('stateChange');
    } catch (err) {
      Logger.error(`offBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [Start change_State]
  private onConnectStateChange() {
    if (!this.mGattServer) {
      return;
    }

    try {
      this.mGattServer.on('connectionStateChange', (data: ble.BLEConnectionChangeState) => {
        if (data) {
          if (data.state === constant.ProfileConnectionState.STATE_CONNECTED) {
            let deviceId = data.deviceId;
            AppStorage.setOrCreate('deviceId', deviceId);
          } else if (data.state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
            AppStorage.setOrCreate('deviceId', '');
          }
        }
      })
    } catch (err) {
      Logger.error(`connectInner: err = ${JSON.stringify(err)}`);
    }
  }

  // [End change_State]
  private offConnectStateChange() {
    if (!this.mGattServer) {
      return;
    }

    try {
      this.mGattServer.off('connectionStateChange');
    } catch (err) {
      Logger.error(`offConnectStateChange: err = ${JSON.stringify(err)}`);
    }
  }
}

let advertiseBluetoothViewModel = new AdvertiseBluetoothViewModel();

export default advertiseBluetoothViewModel as AdvertiseBluetoothViewModel;

