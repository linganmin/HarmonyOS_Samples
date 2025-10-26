// [Start carrier_ability]
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
// Carrier Ability
// EntryAbility.ets
import {createNWeb} from './common';
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => {
      // Create ArkWeb dynamic components (need to pass in UIContext), which can be created at any time after loadContent.
      createNWeb('https://www.example.com', windowStage.getMainWindowSync().getUIContext());
      if (err.code) {
        return;
      }
    });
  }
}
// [End carrier_ability]