/*
* FAQ:如何判断App的启动来源
*/

// [Start SourceAppLaunch2]
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', `app resource is:${want.parameters?.['ohos.aafwk.param.callerBundleName']}`);
    // ...
  }

  // ...
}
// [End SourceAppLaunch2]