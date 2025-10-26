import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import ConnectionUtil from '../utils/ConnectionUtil';

// [Start entry_ability]
export default class EntryAbility extends UIAbility {
  // [StartExclude entry_ability]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    ConnectionUtil.unregister();
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }
  // [EndExclude entry_ability]

  onForeground(): void {
    // Ability has brought to foreground
    // [StartExclude entry_ability]
    ConnectionUtil.register();
    ConnectionUtil.netCapabilitiesChange();
    AppStorage.setOrCreate('onForeground', true);
    // [EndExclude entry_ability]
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    // [StartExclude entry_ability]
    ConnectionUtil.unregister();
    // [EndExclude entry_ability]
    AppStorage.setOrCreate('onForeground', false);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
// [End entry_ability]
