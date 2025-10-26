import { UIAbility } from '@kit.AbilityKit';

export default class MainAbility extends UIAbility {
  storage: LocalStorage

  onCreate(want, launchParam) {
    console.log("[Demo] MainAbility onCreate");
    this.storage = new LocalStorage();
    globalThis.abilityWant = want;
    globalThis.abilityContext = this.context;
  }

  onDestroy() {
    console.log("[Demo] MainAbility onDestroy");
  }

  onWindowStageCreate(windowStage) {
    // Main window is created, set main page for this ability
    console.log("[Demo] MainAbility onWindowStageCreate")
    windowStage.loadContent("pages/Index", this.storage, (err, data) => {
      if (err.code) {
        console.error('Failed to load the content. Cause:' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading the content. Data: ' + JSON.stringify(data))
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    console.log("[Demo] MainAbility onWindowStageDestroy")
  }

  onForeground() {
    // Ability has brought to foreground
    console.log("[Demo] MainAbility onForeground")
  }

  onBackground() {
    // Ability has back to background
    console.log("[Demo] MainAbility onBackground")
  }
};
