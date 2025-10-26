// [Start prefetch_resource]
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb';

export default class EntryAbility extends UIAbility {
  // EntryAbility.ets
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log('EntryAbility onCreate.');
    webview.WebviewController.initializeWebEngine();
    // When pre-acquiring, 'https://www.example1.com/POST? E=f&g=h' is replaced by the actual website address to be visited.
    webview.WebviewController.prefetchResource(
      {
        url: 'https://www.example.com/POST?e=f&g=h',
        method: 'POST',
        formData: 'a=x&b=y'
      },
      [{
        headerKey: 'c',
        headerValue: 'z'
      }],
      'KeyX', 500
    );
    AppStorage.setOrCreate('abilityWant', want);
    console.log('EntryAbility onCreate done.');
  }
  // ...
}
// [End prefetch_resource]