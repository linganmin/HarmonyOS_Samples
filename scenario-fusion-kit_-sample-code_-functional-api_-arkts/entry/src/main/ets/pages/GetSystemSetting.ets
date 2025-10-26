import { atomicService } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let stateArray: Array<atomicService.SystemSettingType> =
  ['bluetoothEnabled', 'locationEnabled', 'deviceOrientation', 'wifiEnabled'];
try {
  let data = atomicService.getSystemSetting(stateArray);
  hilog.info(0x0000, 'testTag', 'succeeded in getting system setting info');
  let bluetoothEnabled: boolean | undefined = data.bluetoothEnabled;
  let locationEnabled: boolean | undefined = data.locationEnabled;
  let deviceOrientation: string | undefined = data.deviceOrientation;
  let wifiEnabled: boolean | undefined = data.wifiEnabled;
} catch (error) {
  hilog.error(0x0001, 'testTag', 'failReason: %{public}d %{public}s', error.code, error.message);
}