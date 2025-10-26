import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      const mainWindow = windowStage.getMainWindowSync();
      mainWindow.setWindowLayoutFullScreen(true).then(() => {
        hilog.info(0x0000, 'testTag', 'Succeeded in setting the window layout to full-screen mode');
      }).catch((err: BusinessError) => {
        hilog.info(0x0000, 'testTag', 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      })

      const sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#ffffff'
      };
      mainWindow.setWindowSystemBarProperties(sysBarProps).then(() => {
        hilog.info(0x0000, 'testTag', 'Succeeded in setting the system bar properties');
      }).catch((err: BusinessError) => {
        hilog.info(0x0000, 'testTag', 'Failed to set system bar properties. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      })
    } catch (exception) {
      hilog.error(0x0000, 'testTag',
        `getMainWindowSync Failed. Code:${exception.code}, message:${exception.message}`);
    }

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

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
