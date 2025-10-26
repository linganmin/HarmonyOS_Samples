import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/Logger';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private static readonly TAG: string = '';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'EntryAbility onCreate.');
  }

  onDestroy() {
    Logger.info(TAG, 'EntryAbility onDestroy.');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'EntryAbility onWindowStageCreate.');

    windowStage.getMainWindow().then((windowClass) => {
      windowClass.setWindowLayoutFullScreen(true).then(() => {
        Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to set the window layout to full-screen mode. Code is ${err.code}, message is ${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to get main window. Code is ${err.code}, message is ${err.message}`);
      this.context.terminateSelf();
    });

    windowStage.loadContent('pages/EntryPage').then(() => {
      Logger.info(TAG, 'Succeeded in loading content.');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to load content. Code is ${err.code}, message is ${err.message}`);
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'EntryAbility onWindowStageDestroy.');
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.info(TAG, 'EntryAbility onForeground.');
  }

  onBackground() {
    // Ability has back to background
    Logger.info(TAG, 'EntryAbility onBackground.');
  }
}
