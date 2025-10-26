import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[EntryAbility]');

interface Storage {
  windowId: number;
}

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      let windowId = windowStage.getMainWindowSync().getWindowProperties().id;
      let para: Storage = { windowId: windowId };
      let storage = new LocalStorage(para);
      windowStage.loadContent('pages/Index', storage);
    } catch (error) {
      logger.error(`onWindowStageCreate error. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info('EntryAbility onCreate invoked. uri: ', want.uri);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info('EntryAbility onNewWant invoked. uri: ', want.uri);
  }
}
