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
// [Start ble]
// [Start access2]
import { access, ble, constant } from '@kit.ConnectivityKit';
// [End access2]
// [End ble]
import ArrayBufferUtils from '../utils/ArrayBufferUtils';
import BluetoothDevice from '../model/BluetoothDevice';
import { Logger } from '../utils/Logger';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

interface BLEDescriptor {
  serviceUuid: string | undefined,
  characteristicUuid: string | undefined,
  descriptorValue: ArrayBufferLike,
  descriptorUuid: string | undefined
}

export class ConnectionState {
  static STATE_CONNECTING = 1;
  static STATE_CONNECTED = 2;
  static STATE_DISCONNECTING = 3;
  static STATE_DISCONNECTED = 4;
}

export class BluetoothClientModel {
  private mGattClientDevice: ble.GattClientDevice | null = null;
  private mConnectBluetoothDevice: BluetoothDevice = {};
  private mAvailableDevices: BluetoothDevice[] = [];
  private mTimeoutID: number = -1;
  private stateChangeFunc = (data: access.BluetoothState): void => {
    if (data === access.BluetoothState.STATE_ON) {
      this.startBLEScan();
    } else if (data === access.BluetoothState.STATE_OFF) {
      this.mAvailableDevices = [];
      AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
      AppStorage.setOrCreate('isSecondaryConnection', false);
    }
  }
  private BLEDeviceFindFunc = (arr: Array<ble.ScanResult>): void => {
    let deviceId: string = arr[0].deviceId;
    let deviceName: string = arr[0].deviceName;
    let device = this.mAvailableDevices.find((availableDevice => {
      return availableDevice.deviceId === deviceId;
    }))
    if (!device) {
      deviceName = arr[0].deviceName;
      this.mAvailableDevices = [];
      this.mAvailableDevices.push(this.getDevice(deviceId, deviceName));
      AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
    }
  }
  private BLEConnectionStateChangeFunc = async (data: ble.BLEConnectionChangeState): Promise<void> => {
    Logger.info('BLEConnectionStateChange:data' + JSON.stringify(data));
    let state: constant.ProfileConnectionState = data.state;
    if (data) {
      if (state === constant.ProfileConnectionState.STATE_CONNECTED) {
        this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_CONNECTED;
        AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);

        try {
          let services: Array<ble.GattService> | undefined = await this.mGattClientDevice?.getServices();
          let service: ble.GattService | undefined =
            services?.find(item => item.serviceUuid === '0000180D-0000-1000-8000-00805F9B34FB');
          let characteristics: Array<ble.BLECharacteristic> | undefined = service?.characteristics;
          let characteristic: ble.BLECharacteristic | undefined =
            characteristics?.find(item => item.characteristicUuid === '00002A37-0000-1000-8000-00805F9B34FB');
          this.mGattClientDevice?.setCharacteristicChangeNotification(characteristic, true);
          let descriptors: Array<ble.BLEDescriptor> | undefined = characteristic?.descriptors;
          let descriptor = descriptors?.find(item => item.descriptorUuid === '00002902-0000-1000-8000-00805F9B34FB')
          let descriptorValue = ArrayBufferUtils.byteArray2ArrayBuffer([0x01, 0x00]);
          let descriptorObj: BLEDescriptor = {
            serviceUuid: descriptor?.serviceUuid,
            characteristicUuid: descriptor?.characteristicUuid,
            descriptorValue: descriptorValue,
            descriptorUuid: descriptor?.descriptorUuid
          }
          this.mGattClientDevice?.writeDescriptorValue(descriptorObj);
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'BluetoothClientModel', `getServices failed. code=${err.code}, message=${err.message}`);
        }
      } else if (state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_DISCONNECTED;
        AppStorage.setOrCreate('availableDevices', []);
        Logger.info('BLEConnectionStateChange:' + JSON.stringify(this.mAvailableDevices))
        AppStorage.setOrCreate('isSecondaryConnection', false);
        if (this.getConnectionState() === ConnectionState.STATE_CONNECTING) {
          this.close();
        } else if (this.getConnectionState() === ConnectionState.STATE_CONNECTED ||
          this.getConnectionState() === ConnectionState.STATE_DISCONNECTING) {
          this.close();
        }
      }
    }
  }
  private BLECharacteristicChangeFunc = (data: ble.BLECharacteristic): void => {
    let characteristicValue: ArrayBuffer = data.characteristicValue;
    let byteArr = ArrayBufferUtils.arrayBuffer2ByteArray(characteristicValue);
    let heartRate = byteArr[1];
    AppStorage.setOrCreate('heartRate', heartRate);
  }

  // [Start blue_tooth]
  isBluetoothEnabled(): boolean {
    let state: access.BluetoothState = 0;
    try {
      state = access.getState();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'BluetoothClientModel',
        `isBluetoothEnabled failed. code=${err.code}, message=${err.message}`);
    }
    Logger.info(`isBluetoothEnabled: state = ${state}`);
    if (state === access.BluetoothState.STATE_ON || state === access.BluetoothState.STATE_TURNING_ON) {
      return true;
    }
    return false;
  }

  // [End blue_tooth]
  enableBluetooth() {
    try {
      this.onBTStateChange();
      // [Start enab]
      access.enableBluetooth();
      // [End enab]
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

  // [Start blue_tooth1]
  startBLEScan(): boolean {
    clearTimeout(this.mTimeoutID);
    if (!this.isBluetoothEnabled()) {
      Logger.info('startBLEScan: bluetooth is disable');
      this.enableBluetooth();
      try {
        uiContext?.getPromptAction().showToast({
          message: $r('app.string.bluetooth_enabled_please_wait'),
          duration: 2000
        })
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'BluetoothClientModel', `showToast failed. code=${err.code}, message=${err.message}`);
      }
      return false;
    }
    this.onBLEDeviceFind();
    const ret = this.startBLEScanInner();
    return ret;
  }

  // [End blue_tooth1]
  stopBLEScan() {
    clearTimeout(this.mTimeoutID);
    this.offBLEDeviceFind();
    this.stopBLEScanInner();
  }

  connect(bluetoothDevice: BluetoothDevice) {
    if (this.mGattClientDevice && this.mConnectBluetoothDevice &&
      this.mConnectBluetoothDevice.deviceId === bluetoothDevice.deviceId) {
      const ret: boolean = this.connectInner(this.mGattClientDevice);
      return ret;
    }
    this.close();

    this.mConnectBluetoothDevice = bluetoothDevice;
    AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
    let ret: boolean = false;
    try {
      this.mGattClientDevice = ble.createGattClientDevice(bluetoothDevice.deviceId);
      ret = this.connectInner(this.mGattClientDevice);
      if (ret) {
        Logger.info('Trying to create a new connection.');
      } else {
        Logger.info('Trying to create a new connection fail.');
        this.close();
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'BluetoothClientModel',
        `createGattClientDevice failed. code=${err.code}, message=${err.message}`);
    }

    return ret;
  }

  disconnect() {
    this.disconnectInner(this.mGattClientDevice);
  }

  close() {
    this.closeInner(this.mGattClientDevice);
  }

  getConnectionState(): number {
    return this.mConnectBluetoothDevice.connectionState ?? 0;
  }

  // [Start state]
  private onBTStateChange() {
    try {
      access.on('stateChange', (data: access.BluetoothState) => {
        if (data === access.BluetoothState.STATE_ON) {
          this.startBLEScan();
        } else if (data === access.BluetoothState.STATE_OFF) {
          this.mAvailableDevices = [];
          AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
        }
      })
    } catch (err) {
      Logger.error(`onBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [End state]
  private offBTStateChange() {
    try {
      access.off('stateChange');
    } catch (err) {
      Logger.error(`offBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [Start find1]
  private onBLEDeviceFind() {
    try {
      ble.on('BLEDeviceFind', (arr: Array<ble.ScanResult>) => {
        let deviceId: string = arr[0].deviceId;
        let deviceName: string = arr[0].deviceName;
        let device = this.mAvailableDevices.find((availableDevice => {
          return availableDevice.deviceId === deviceId;
        }))
        if (!device) {
          let data: ArrayBuffer = arr[0].data;
          deviceName = util.TextDecoder.create('utf-8', {
            ignoreBOM: true
          }).decodeToString(new Uint8Array(data), { stream: false });
          this.mAvailableDevices = [];
          this.mAvailableDevices.push(this.getDevice(deviceId, deviceName));
          AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
        }
      })
    } catch (err) {
      Logger.info(`onBLEDeviceFind: err = ${JSON.stringify(err)}`);
    }
  }

  // [End find1]
  private offBLEDeviceFind() {
    try {
      ble.off('BLEDeviceFind');
    } catch (err) {
      Logger.error(`offBLEDeviceFind: err = ${JSON.stringify(err)}`);
    }
  }

  // [Start state_change1]
  // [Start state_change2]
  private onBLEConnectionStateChange() {
    if (!this.mGattClientDevice) {
      return;
    }

    try {
      this.mGattClientDevice.on('BLEConnectionStateChange', async (data: ble.BLEConnectionChangeState) => {
        let state: constant.ProfileConnectionState = data.state;
        if (data) {
          if (state === constant.ProfileConnectionState.STATE_CONNECTED) {
            this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_CONNECTED;
            AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
            // The connection is successful, and the service is obtained
            let services: Array<ble.GattService> | undefined = await this.mGattClientDevice?.getServices();
            let service: ble.GattService | undefined =
              services?.find(item => item.serviceUuid === '0000180D-0000-1000-8000-00805F9B34FB')
            let characteristics: Array<ble.BLECharacteristic> | undefined = service?.characteristics;
            let characteristic: ble.BLECharacteristic | undefined =
              characteristics?.find(item => item.characteristicUuid === '00002A37-0000-1000-8000-00805F9B34FB');
            // Sends a setup notification request for this feature value to the server
            this.mGattClientDevice?.setCharacteristicChangeNotification(characteristic, true);
            let descriptors: Array<ble.BLEDescriptor> | undefined = characteristic?.descriptors;
            let descriptor = descriptors?.find(item => item.descriptorUuid === '00002902-0000-1000-8000-00805F9B34FB')
            let descriptorValue = ArrayBufferUtils.byteArray2ArrayBuffer([0x01, 0x00]);
            let descriptorObj: BLEDescriptor = {
              serviceUuid: descriptor?.serviceUuid,
              characteristicUuid: descriptor?.characteristicUuid,
              descriptorValue: descriptorValue,
              descriptorUuid: descriptor?.descriptorUuid
            }
            // Writes binary data to a Bluetooth Low energy device-specific descriptor
            this.mGattClientDevice?.writeDescriptorValue(descriptorObj);
          } else if (state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
            this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_DISCONNECTED;
            AppStorage.setOrCreate('availableDevices', []);
            if (this.getConnectionState() === ConnectionState.STATE_CONNECTING) {
              this.close();
            } else if (this.getConnectionState() === ConnectionState.STATE_CONNECTED ||
              this.getConnectionState() === ConnectionState.STATE_DISCONNECTING) {
              this.close();
            }
          }
        }
      })
    } catch (err) {
      Logger.error(`onBLEConnectionStateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [End state_change2]
  // [End state_change1]
  private offBLEConnectionStateChange() {
    if (!this.mGattClientDevice) {
      return;
    }
    try {
      this.mGattClientDevice.off('BLEConnectionStateChange');
    } catch (err) {
      Logger.error(`offBLEConnectionStateChange: err = ${JSON.stringify(err)}`);
    }
  }

  // [Start char_change]
  onBLECharacteristicChange() {
    if (!this.mGattClientDevice) {
      return;
    }
    try {
      this.mGattClientDevice.on('BLECharacteristicChange', (data: ble.BLECharacteristic) => {
        let characteristicValue: ArrayBuffer = data.characteristicValue;
        let byteArr = ArrayBufferUtils.arrayBuffer2ByteArray(characteristicValue);
        let heartRate = byteArr[1];
        AppStorage.setOrCreate('heartRate', heartRate);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'BluetoothClientModel',
        `createGattClientDevice failed. code=${err.code}, message=${err.message}`);
    }
  }

  // [End char_change]
  offBLECharacteristicChange() {
    if (!this.mGattClientDevice) {
      return;
    }
    try {
      this.mGattClientDevice.off('BLECharacteristicChange');
    } catch (err) {
      Logger.error(`offBLECharacteristicChange: err = ${JSON.stringify(err)}`);
    }
  }

  private startBLEScanInner(): boolean {
    try {
      this.mAvailableDevices = [];
      if (this.mConnectBluetoothDevice.connectionState === ConnectionState.STATE_CONNECTED) {
        this.mAvailableDevices.push(this.mConnectBluetoothDevice);
      }
      AppStorage.setOrCreate('availableDevices', this.mAvailableDevices);
      ble.startBLEScan([{ serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB' }]);
      return true;
    } catch (err) {
      Logger.error(`startBLEScanInner: err = ${JSON.stringify(err)}`);
    }
    return false;
  }

  private stopBLEScanInner() {
    try {
      ble.stopBLEScan();
      uiContext?.getPromptAction().showToast({
        message: $r('app.string.bLE_scanning_has_been_stopped'),
        duration: 2000
      })
    } catch (err) {
      Logger.error(`stopBLEScanInner: err = ${JSON.stringify(err)}`);
    }
  }

  // [Start connect_inner]
  private connectInner(gattClientDevice: ble.GattClientDevice): boolean {
    try {
      if (!gattClientDevice) {
        return false;
      }
      // The subscription connection status changes
      this.onBLEConnectionStateChange();
      // Subscription feature value changes
      this.onBLECharacteristicChange();
      // Start connecting
      gattClientDevice.connect();
      this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_CONNECTING;
      AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
      return true;
    } catch (err) {
      Logger.error(`connectInner: err = ${JSON.stringify(err)}`);
      return false;
    }
  }

  // [End connect_inner]
  private disconnectInner(gattClientDevice: ble.GattClientDevice | null) {
    try {
      if (!gattClientDevice) {
        return;
      }
      this.offBLEConnectionStateChange();
      this.offBLECharacteristicChange();
      this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_DISCONNECTED;
      AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
      AppStorage.setOrCreate('availableDevices', [this.mConnectBluetoothDevice]);
      if (this.getConnectionState() === ConnectionState.STATE_CONNECTING) {
        this.close();
      } else if (this.getConnectionState() === ConnectionState.STATE_CONNECTED) {
        gattClientDevice.disconnect();
        this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_CONNECTING;
        AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
        this.close();
      }
    } catch (err) {
      Logger.error(`connectInner: err = ${JSON.stringify(err)}`);
    }
  }

  changeConnectState() {
    this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_DISCONNECTED;
    AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
    AppStorage.setOrCreate('availableDevices', [this.mConnectBluetoothDevice]);
  }

  private closeInner(gattClientDevice: ble.GattClientDevice | null) {
    try {
      if (!gattClientDevice) {
        return;
      }
      gattClientDevice.close();
      this.mConnectBluetoothDevice.connectionState = ConnectionState.STATE_CONNECTED;
      AppStorage.setOrCreate('connectBluetoothDevice', this.mConnectBluetoothDevice);
      this.release();
    } catch (err) {
      Logger.error(`closeInner: err = ${JSON.stringify(err)}`);
    }
  }

  private release() {
    this.mGattClientDevice = null;
    this.mTimeoutID = -1;
  }

  private getDevice(deviceId: string, deviceName: string): BluetoothDevice {
    let device = new BluetoothDevice();
    device.deviceId = deviceId;
    device.deviceName = deviceName;
    return device;
  }
}

let bluetoothClientModel = new BluetoothClientModel();

export default bluetoothClientModel as BluetoothClientModel;