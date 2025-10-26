/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const logTag: string = 'EntryAbility';
const domainId: number = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(domainId, logTag, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(domainId, logTag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(domainId, logTag, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        hilog.error(domainId, logTag, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(domainId, logTag, 'Succeeded in loading the content.');
    });
  }
}