/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import { UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import Utils from '../utils/Utils';
import { Constants } from '../common/Constants';

export default class EntryAbility extends UIAbility {
  private logTag: string = 'EntryAbility';
  private domainId: number = 0x0000;

  onCreate(want: Want): void {
    hilog.info(this.domainId, this.logTag, 'onCreate');
    if (want.parameters && want.parameters[Constants.PARAM_CALLER_BUNDLE_NAME]) {
      Utils.setCallerBundleName(want.parameters[Constants.PARAM_CALLER_BUNDLE_NAME] as string);
    }
  }

  onDestroy(): void {
    hilog.info(this.domainId, this.logTag, 'onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(this.domainId, this.logTag, 'EntryAbility onWindowStageCreate');
    let windowClass: window.Window = await windowStage.getMainWindow()
    await windowClass.setWindowLayoutFullScreen(true)
    await windowClass.setWindowSystemBarEnable(['status', 'navigation'])
    windowClass.on('keyboardHeightChange', async data => {
      hilog.info(this.domainId, this.logTag, `testTag: ${data.toString()}`);
    })
    windowStage.loadContent('pages/ParentControlHomePage', (err) => {
      if (err.code) {
        hilog.info(this.domainId, this.logTag, `failed to load the content. Cause: ${err.code}`);
        return;
      }
      hilog.info(this.domainId, this.logTag, 'succeeded in loading the content.');
    });
  }

  onNewWant(want: Want): void {
    hilog.info(this.domainId, this.logTag, 'onNewWant');
    if (want.parameters && want.parameters[Constants.PARAM_CALLER_BUNDLE_NAME]) {
      Utils.setCallerBundleName(want.parameters[Constants.PARAM_CALLER_BUNDLE_NAME] as string);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(this.domainId, this.logTag, 'onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(this.domainId, this.logTag, 'onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(this.domainId, this.logTag, 'onBackground');
  }
}