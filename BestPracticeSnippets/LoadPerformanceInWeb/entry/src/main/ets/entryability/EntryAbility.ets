// [Start entry_ability]
// Carrier Ability
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { createNWeb } from '../pages/common';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      // Create an empty ArkWeb dynamic component in advance (need to pass in UIContext) and start the rendering process.
      createNWeb('about:blank', windowStage.getMainWindowSync().getUIContext());
    });
  }
}
// [End entry_ability]