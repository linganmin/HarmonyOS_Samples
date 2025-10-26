// DocsCode 1
// 载体Ability
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { createNWeb } from '../pages/common';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => {
      // 预先创建一个空的ArkWeb动态组件（需传入UIContext），拉起渲染进程
      createNWeb('about://blank', windowStage.getMainWindowSync().getUIContext());
    });
  }
}
// DocsCode 1