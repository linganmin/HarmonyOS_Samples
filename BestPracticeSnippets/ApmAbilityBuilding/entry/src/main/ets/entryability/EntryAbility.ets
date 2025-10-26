import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
// [Start entryImportHilog]
import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit';
// [End entryImportHilog]
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      // [Start hiAppEvent_addWatcher]
      hiAppEvent.addWatcher({
        // Developers can customize the observer name, and the system will use the name to identify different observers
        name: "watcher1",
        // Developers can subscribe to application events of interest, in this case, button events
        appEventFilters: [{ domain: "button" }],
        // Developers can set the conditions for triggering subscription callbacks. Here, it is set that the number of event dots meets 1
        triggerCondition: { row: 1 },
        // Developers can implement the subscription callback function by themselves, so as to customize the event dot data obtained by subscription
        onTrigger: (curRow: number, curSize: number, holder: hiAppEvent.AppEventPackageHolder) => {
          // The returned holder object is null, indicating that an exception occurred in the subscription process, so it is returned directly after recording the error log
          if (holder == null) {
            hilog.error(0x0000, 'testTag', "HiAppEvent holder is null");
            return;
          }
          hilog.info(0x0000, 'testTag', `HiAppEvent onTrigger: curRow=%{public}d, curSize=%{public}d`, curRow, curSize);
          let eventPkg: hiAppEvent.AppEventPackage | null = null;
          // Acquire the subscription event package according to the set threshold size (default is 512KB) until all subscription data are taken out
          // The returned event package object is null, indicating that all the current subscription data has been taken out, and this subscription callback triggers the end
          while ((eventPkg = holder.takeNext()) != null) {
            // Developers can customize the event dot data in the event package, here, print the event dot data in the log
            hilog.info(0x0000, 'testTag', `HiAppEvent eventPkg.packageId=%{public}d`, eventPkg.packageId);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventPkg.row=%{public}d`, eventPkg.row);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventPkg.size=%{public}d`, eventPkg.size);
            for (const eventInfo of eventPkg.data) {
              hilog.info(0x0000, 'testTag', `HiAppEvent eventPkg.info=%{public}s`, eventInfo);
            }
          }
        }
      });
      // [End hiAppEvent_addWatcher]
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}