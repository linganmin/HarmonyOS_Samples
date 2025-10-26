/**
 * 最佳实践：合理使用蓝牙资源
 */

// [Start blue_tooth]
import { UIAbility } from '@kit.AbilityKit';
import { ble } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [StartExclude blue_tooth]
const scanFilter: ble.ScanFilter = {}
const scanOptions: ble.ScanOptions = {}
const setting: ble.AdvertiseSetting = {}
const advData: ble.AdvertiseData = {
  serviceUuids: [],
  manufactureData: [],
  serviceData: []
}
const advResponse = undefined
// [EndExclude blue_tooth]
export default class EntryAbility extends UIAbility {
  // ...
  onForeground(): void {
    try {
      //Initiate Ble scan and broadcast as required by the service at the foreground
      ble.startBLEScan([scanFilter], scanOptions);
      ble.startAdvertising(setting, advData, advResponse);
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `startBLEScan or startAdvertising failed, code=${err.code}, message=${err.message}`);
    }
  }

  onBackground(): void {
    try {
      // Return to the background to stop the Ble scanning and broadcast, which is the same as the application
      ble.stopBLEScan();
      ble.stopAdvertising();
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `stopBLEScan or stopAdvertising failed, code=${err.code}, message=${err.message}`);
    }
  }
}
// [End blue_tooth]