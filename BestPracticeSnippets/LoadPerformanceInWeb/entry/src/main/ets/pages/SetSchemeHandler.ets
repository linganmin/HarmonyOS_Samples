import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import testNapi from 'libentry.so';
import webview from '@ohos.web.webview';

export default class EntryAbility extends UIAbility {
  // [Start set_scheme_handler]
  // EntryAbility.ets
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // register CustomSchemes
    testNapi.registerCustomSchemes();
    // initializeWebEngine
    webview.WebviewController.initializeWebEngine();
    // set SchemeHandler。
    testNapi.setSchemeHandler();
  }
  // [End set_scheme_handler]

  onDestroy(): void {

  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        return;
      }
    });
  }

  onWindowStageDestroy(): void {

  }

  onForeground(): void {

  }

  onBackground(): void {

  }
};