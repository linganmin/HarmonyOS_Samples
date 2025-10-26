/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonEventUtil } from '../common/CommonEventUtil';

const STATUS_BAR_HEIGHT = 38; // Preset avoidance height for the top of the system.

export default class EntryAbility extends UIAbility {
  logTag: string = 'EntryAbility';
  domainId: number = 0x0000;

  onCreate(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onCreate');
    // Subscribe to youth mode–related common events.
    CommonEventUtil.subscriberCommonEvent();
  }

  onDestroy(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(this.domainId, this.logTag, 'Ability onWindowStageCreate');
    // 1. Obtain the main window of the atomic service.
    let windowClass: window.Window;
    try {
      windowClass = windowStage.getMainWindowSync();
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to obtain the main window. errCode: ${err.code}, message: ${err.message}`);
      return;
    }
    // 2. Set the immersive mode.
    const isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      hilog.info(this.domainId, this.logTag, 'Succeeded in setting WindowLayoutFullScreen.');
    }).catch((err: BusinessError) => {
      hilog.error(this.domainId, this.logTag,
        `Failed to setWindowLayoutFullScreen. code: ${err.code}, message: ${err.message}`);
    });
    // 3. Obtain the avoidance height for the top of the system.
    try {
      const statusBarHeight = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
      if (statusBarHeight > 0) {
        hilog.info(this.domainId, this.logTag, `StatusBarHeight: ${statusBarHeight}`);
        AppStorage.setOrCreate<number>('statusBarHeight', statusBarHeight);
      } else {
        hilog.error(this.domainId, this.logTag, 'Failed to obtain the statusBarHeight.');
        AppStorage.setOrCreate<number>('statusBarHeight', STATUS_BAR_HEIGHT);
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag, 'Failed to obtain the statusBarHeight.');
      AppStorage.setOrCreate<number>('statusBarHeight', STATUS_BAR_HEIGHT);
    }
    windowStage.loadContent('pages/Index', new LocalStorage(), (err) => {
      if (err.code) {
        hilog.error(this.domainId, this.logTag,
          `Failed to load the content. errCode: ${err.code}, message: ${err.message}`);
        return;
      }
      hilog.info(this.domainId, this.logTag, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onBackground');
  }
}
