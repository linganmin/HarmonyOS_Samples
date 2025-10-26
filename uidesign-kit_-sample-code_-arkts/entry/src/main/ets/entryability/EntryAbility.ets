/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  logTag: string = 'EntryAbility';
  domainId: number = 0x0000;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(this.domainId, this.logTag, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(this.domainId, this.logTag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(this.domainId, this.logTag, 'Ability onWindowStageCreate');
    // 1. Obtain the main window of the app.
    const windowClass: window.Window = windowStage.getMainWindowSync();
    // 2. Set the immersive mode.
    const isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      hilog.info(this.domainId, this.logTag, 'Succeeded in setting WindowLayoutFullScreen.');
    }).catch((error: BusinessError) => {
      hilog.error(this.domainId, this.logTag,
        `Failed to setWindowLayoutFullScreen. errCode is ${error.code}, errMessage is ${error.message}`);
    });

    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        hilog.error(this.domainId, this.logTag,
          `Failed to load the content. errCode is ${error.code}, errMessage is ${error.message}`);
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
