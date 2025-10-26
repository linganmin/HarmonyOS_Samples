import { atomicService } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let stateArray: Array<atomicService.SystemInfoType> =
  ['brand', 'deviceModel', 'screenWidth', 'screenHeight', 'language', 'osFullName', 'fontSizeSetting', 'sdkApiVersion',
    'bluetoothEnabled', 'wifiEnabled', 'locationEnabled', 'deviceOrientation', 'theme'];
try {
  let data = atomicService.getSystemInfoSync(stateArray);
  hilog.info(0x0000, 'testTag', 'succeeded in getting system info');
  let brand: string | undefined = data.brand;
  let deviceModel: string | undefined = data.deviceModel;
  let screenWidth: number | undefined = data.screenWidth;
  let screenHeight: number | undefined = data.screenHeight;
  let language: string | undefined = data.language;
  let osFullName: string | undefined = data.osFullName;
  let fontSizeSetting: number | undefined = data.fontSizeSetting;
  let sdkApiVersion: number | undefined = data.sdkApiVersion;
  let bluetoothEnabled: boolean | undefined = data.bluetoothEnabled;
  let wifiEnabled: boolean | undefined = data.wifiEnabled;
  let locationEnabled: boolean | undefined = data.locationEnabled;
  let deviceOrientation: string | undefined = data.deviceOrientation;
  let theme: ColorMode | undefined = data.theme;
} catch (error) {
  hilog.error(0x0000, 'testTag', 'failReason: %{public}d %{public}s', error.code, error.message);
}