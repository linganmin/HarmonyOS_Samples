import { atomicService } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';

let stateArray: Array<atomicService.SystemInfoType> =
  ['brand', 'deviceModel', 'screenWidth', 'screenHeight', 'statusBarHeight', 'screenSafeArea', 'language', 'osFullName',
    'fontSizeSetting', 'sdkApiVersion', 'bluetoothEnabled', 'wifiEnabled', 'locationEnabled', 'deviceOrientation',
    'theme', 'windowWidth', 'windowHeight'];
try {
  atomicService.getSystemInfo(stateArray).then((data: atomicService.SystemInfo) => {
    hilog.info(0x0000, 'testTag', 'succeeded in getting system info asynchronously');
    let brand: string | undefined = data.brand;
    let deviceModel: string | undefined = data.deviceModel;
    let screenWidth: number | undefined = data.screenWidth;
    let screenHeight: number | undefined = data.screenHeight;
    let statusBarHeight: number | undefined = data.statusBarHeight;
    let screenSafeArea: window.AvoidArea | undefined = data.screenSafeArea;
    let language: string | undefined = data.language;
    let osFullName: string | undefined = data.osFullName;
    let fontSizeSetting: number | undefined = data.fontSizeSetting;
    let sdkApiVersion: number | undefined = data.sdkApiVersion;
    let bluetoothEnabled: boolean | undefined = data.bluetoothEnabled;
    let wifiEnabled: boolean | undefined = data.wifiEnabled;
    let locationEnabled: boolean | undefined = data.locationEnabled;
    let deviceOrientation: string | undefined = data.deviceOrientation;
    let theme: ColorMode | undefined = data.theme;
    let windowWidth: number | undefined = data.windowWidth;
    let windowHeight: number | undefined = data.windowHeight;
  }).catch((error: BusinessError) => {
    hilog.error(0x0000, 'testTag', 'Promise error: %{public}d %{public}s', error.code, error.message);
  })
} catch (error) {
  hilog.error(0x0000, 'testTag', 'failReason: %{public}d %{public}s', error.code, error.message);
}