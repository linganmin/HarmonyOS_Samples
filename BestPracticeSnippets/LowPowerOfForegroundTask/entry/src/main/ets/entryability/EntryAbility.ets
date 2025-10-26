import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

// [Start power_entry_ability]
export default class EntryAbility extends UIAbility {
  // [StartExclude power_entry_ability]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'setColorMode fail');
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }
  // [EndExclude power_entry_ability]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude power_entry_ability]
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    // [EndExclude power_entry_ability]
    // Determine whether it is currently in dark mode.
    if (this.context?.config?.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      try {
        let windowClass = windowStage.getMainWindowSync();
        // Set the brightness of the current application window
        windowClass.setWindowBrightness(0.2, (err) => {
          if (err.code) {
            console.error('Failed to set the brightness. Cause: ' + JSON.stringify(err));
            return;
          }
          console.info('Succeeded in setting the brightness.');
        });
      } catch (exception) {
        console.error('Failed to set the brightness. Cause: ' + JSON.stringify(exception));
      }
    }
  }

  // [StartExclude power_entry_ability]
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  // [EndExclude power_entry_ability]
}
// [End power_entry_ability]