import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { display, router, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonEventManager } from '../pages/customScan/model/CommonEventManager';
import Logger from '../common/Logger';
import { WindowService } from '../pages/customScan/model/WindowService';
import { WindowServiceV2 } from '../pages/customScanV2/model/WindowService';
import { DeviceService } from '../pages/customScan/model/DeviceService';
import { UIContextSelf } from '../pages/customScan/model/UIContextSelf';
import { ConfigStorage } from '../pages/customScanV2/model/ConfigStorage';

const TAG = 'Scan SampleCode EntryAbility';

export default class EntryAbility extends UIAbility {
  private page: string = 'pages/Index';

  // Obtain the code value through the onCreate callback in cold launch scenarios.
  onCreate(want: Want, __: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    try {
      DeviceService.isFolding = display.isFoldable();
    } catch (error) {
      Logger.error(`Failed to invoke an API of isFoldable. Code: ${error?.code}`);
    }
    // Obtain the uri field from the want information.
    let uri = want?.uri;
    if (uri) {
      // Process the service based on the URI.
      this.page = 'pages/access/ScanAccess';
    }

    if (this.context && this.context.config) {
      AppStorage.setOrCreate<number>('scanColorMode', this.context.config.colorMode);
      AppStorage.setOrCreate<string>('scanLanguage', this.context.config.language);
      const configStorage: ConfigStorage = ConfigStorage.getInstance();
      configStorage.updateConfig(this.context.config.colorMode, this.context.config.language);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    if (newConfig) {
      if (AppStorage.get('scanColorMode') !== newConfig.colorMode) {
        AppStorage.setOrCreate<number>('scanColorMode', newConfig.colorMode);
        ConfigStorage.getInstance().updateColorMode(newConfig.colorMode);
      }
      if (AppStorage.get('scanLanguage') !== newConfig.language) {
        AppStorage.setOrCreate<string>('scanLanguage', newConfig.language);
        ConfigStorage.getInstance().updateLanguage(newConfig.language);
      }
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // The window has been created. Configure the main UI for the function.
    Logger.info(TAG, 'Ability onWindowStageCreate');
    try {
      windowStage.getMainWindow().then((windowObj: window.Window) => {
        Logger.info(TAG, 'Succeeded in getMainWindow.');
        try {
          windowStage.loadContent(this.page).then(() => {
            Logger.info(TAG, 'Succeeded in loading the content.');
            UIContextSelf.setUIContext(windowObj);
            WindowService.getInstance().initWindowObj(windowObj);
            WindowServiceV2.getInstance().initWindowObj(windowObj);
          }).catch((error: BusinessError) => {
            Logger.error(TAG, `Failed to load the content. Code: ${error.code}.`);
          })
        } catch (error) {
          Logger.error(TAG, `Failed to load the content. Code: ${error?.code}.`);
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to get getMainWindow by windowStage. Code: ${error.code}.`);
      });
    } catch (error) {
      Logger.error(TAG, `Failed to get getMainWindow by windowStage. Code: ${error?.code}.`);
    }
  }

  // Obtain the code value through the onNewWant callback in warm launch scenarios.
  onNewWant(want: Want, _: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    // Obtain the uri field from the want information.
    let uri = want?.uri;
    let status: router.RouterState = UIContextSelf.getRouter().getState();
    if (status && status.name !== 'ScanAccess' && uri) {
      // Process the service based on the URI.
      try {
        UIContextSelf.pushUrl({
          url: 'pages/access/ScanAccess'
        });
      } catch (error) {
        Logger.error(TAG, `Failed to pushUrl. Code: ${error?.code}.`);
      }
    }
  }

  onForeground(): void {
    // The app is switched to the foreground.
    Logger.info(TAG, 'Ability onForeground');
    CommonEventManager.getInstance().createSubscriber();
  }

  onBackground(): void {
    // The app is switched to the background.
    Logger.info(TAG, 'Ability onBackground');
    CommonEventManager.getInstance().unsubscribe();
  }

  onWindowStageWillDestroy(): void {
    // Destroy the main window and release UI resources.
    Logger.info(TAG, 'Ability onWindowStageWillDestroy');
    WindowService.getInstance().offWindowSizeChange();
    WindowServiceV2.getInstance().offWindowSizeChange();
    WindowService.getInstance().offAvoidAreaChange();
    WindowServiceV2.getInstance().offAvoidAreaChange();
  }
}
