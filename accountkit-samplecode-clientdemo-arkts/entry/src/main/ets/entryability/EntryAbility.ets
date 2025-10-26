/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { Configuration, UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { CommonEventUtil } from '../common/CommonEventUtil';

const logTag: string = 'EntryAbility';
const domainId: number = 0x0000;

export default class EntryAbility extends UIAbility {
  private storage: LocalStorage = new LocalStorage();

  onCreate(): void {
    hilog.info(domainId, logTag, 'Ability onCreate');
    this.storage = new LocalStorage();
    // Subscribe to youth mode–related common events.
    new CommonEventUtil(this.context).subscriberCommonEvent();
    // Save the current colorMode of the device.
    AppStorage.setOrCreate('colorMode', this.context.config.colorMode);
  }

  onConfigurationUpdate(newConfig: Configuration) {
    // When the system configuration is updated, if colorMode changes, update AppStorage.
    if (newConfig.colorMode !== AppStorage.get('colorMode')) {
      AppStorage.setOrCreate('colorMode', newConfig.colorMode);
    }
  }

  onDestroy(): void {
    hilog.info(domainId, logTag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(domainId, logTag, 'Ability onWindowStageCreate');
    // 1. Obtain the main window of the app.
    let windowClass: window.Window;
    try {
      windowClass = windowStage.getMainWindowSync();
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to obtain the main window. errCode: ${error?.code}, errMessage: ${error?.message}`);
      return;
    }
    // 2. Set the immersive mode.
    let isLayoutFullScreen = true;
    if (deviceInfo.deviceType === '2in1') {
      // The 2-in-1 device uses the non-immersive mode.
      isLayoutFullScreen = false;
    }
    try {
      windowClass.on('windowSizeChange', (data) => {
        const displayObj: display.Display = display.getDefaultDisplaySync();
        const displayWidth: number = displayObj.width;
        const displayHeight: number = displayObj.height;
        hilog.info(domainId, logTag, `displayWidth: ${displayWidth}; displayHeight: ${displayHeight};`);
        const windowWidth = data.width;
        const windowHeight = data.height;
        hilog.info(domainId, logTag, `windowWidth: ${windowWidth}; windowHeight: ${windowHeight};`);
        if (displayWidth === windowWidth && displayHeight === windowHeight) {
          AppStorage.setOrCreate('isFullMode', true);
        } else {
          AppStorage.setOrCreate('isFullMode', false);
        }
      });
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to enable the listener for window size changes. errCode: ${error.code}, errMessage: ${error.message}`);
    }
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      hilog.info(domainId, logTag, 'Succeeded in setting WindowLayoutFullScreen.');
    }).catch((error: BusinessError) => {
      hilog.error(domainId, logTag,
        `Failed to setWindowLayoutFullScreen. errCode: ${error.code}, message: ${error.message}`);
    });
    // 3. Obtain the avoidance height for the top of the system.
    try {
      const statusBarHeight = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
      const aiBarHeight =
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height;
      if (statusBarHeight > 0) {
        hilog.info(domainId, logTag, `StatusBarHeight: ${statusBarHeight}`);
        AppStorage.setOrCreate<number>('statusBarHeight', statusBarHeight);
      }
      AppStorage.setOrCreate<number>('aiBarHeight', aiBarHeight);
    } catch (error) {
      hilog.error(domainId, logTag, 'Failed to obtain the statusBarHeight.');
    }

    windowStage.loadContent('pages/HomePage', this.storage, (error) => {
      if (error.code) {
        hilog.error(domainId, logTag,
          `Failed to load the content. errCode: ${error.code}, errMessage: ${error.message}`);
        return;
      }
      hilog.info(domainId, logTag, `Succeeded in loading the content.`);
      try {
        // Set the window to be transparent.
        windowClass.setWindowBackgroundColor('#00000000');
        // Hide the title bar, which is valid only for 2-in-1 devices.
        windowClass.setWindowDecorVisible(false);
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to set window. errCode: ${error?.code}, errMessage: ${error?.message}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(domainId, logTag, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(domainId, logTag, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(domainId, logTag, 'Ability onBackground');
  }
}
