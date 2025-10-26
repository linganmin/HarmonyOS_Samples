import { Logger } from '../utils/Logger';
/**
 * 最佳实践：意图框架习惯推荐场景开发实践
 */
import { UIAbility } from '@kit.AbilityKit';
import type { AbilityConstant, Want } from '@kit.AbilityKit';
import type { window } from '@kit.ArkUI';
import type { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private result: string = '';

  // [Start on_create]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'onCreate');
    if (want.parameters?.['result']) {
      this.result = want.parameters?.['result'] as string;
    }
  }

  // [End on_create]
  onDestroy(): void {
    Logger.info(TAG, 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // When the main window is created, set a main page for this ability.
    Logger.info(TAG, `onWindowStageCreate`)
    let para: Record<string, string> = {
      'result': this.result,
    };
    let localStorage: LocalStorage = new LocalStorage(para);
    windowStage.loadContent('pages/Index', localStorage)
      .then(() => {
        Logger.info(TAG, `onWindowStageCreate success`);
      }, (err: BusinessError) => {
        Logger.info(TAG, `onWindowStageCreate failes: ${JSON.stringify(err)}`);
      })
  }

  onWindowStageDestroy(): void {
    // When the main window is destroyed, free up UI-related resources.
    Logger.info(TAG, `onWindowStageDestroy`);
  }

  onForeground(): void {
    // The ability has been brought to the foreground.
    Logger.info(TAG, `onForeground`);
  }

  onBackground(): void {
    // The ability has returned to the background.
    Logger.info(TAG, `onBackground`);
  }
}
