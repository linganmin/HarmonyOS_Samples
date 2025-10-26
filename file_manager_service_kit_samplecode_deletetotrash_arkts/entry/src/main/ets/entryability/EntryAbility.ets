import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const domain = 0x0000;

export default class EntryAbility extends UIAbility {
  public onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.error(domain, launchParam.launchReason.toString(),
          'setColorMode failed with err: ' + JSON.stringify(error));
    }
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onCreate');
    if (want.abilityName !== undefined) {
      hilog.info(domain, launchParam.launchReason.toString(), '%{public}s', 'Ability onCreate');
    }
  }

  public onDestroy(): void {
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(domain, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(domain, 'testTag', 'Succeeded in loading the content.');
    });
  }

  public onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  public onForeground(): void {
    // Ability has brought to foreground
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onForeground');
  }

  public onBackground(): void {
    // Ability has back to background
    hilog.info(domain, 'testTag', '%{public}s', 'Ability onBackground');
  }
}