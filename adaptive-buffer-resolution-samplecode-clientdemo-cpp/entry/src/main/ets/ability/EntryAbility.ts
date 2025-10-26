/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import core from 'libentry.so';


export default class EntryAbility extends UIAbility {
  static readonly DOMAIN: number = 42
  static readonly TAG: string = "AdaptiveBufferResolution"

  onCreate(want, launchParam) {
    const context = this.context
    core.create(context.resourceManager, display.getDefaultDisplaySync().densityDPI)
  }

  onDestroy() {
    core.destroy()
  }

  onBackground(): void {
    core.onBackground()
  }

  onForeground(): void {
    core.onForeground()
  }

  onBackPressed(): boolean {
    return false;
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    this.MakeRealFullScreen(windowStage)
    windowStage.loadContent("pages/Index", (err) => {
      if (err.code) {
        hilog.error(EntryAbility.DOMAIN, EntryAbility.TAG, "Failed to load the content. Cause: %{public}s",
          JSON.stringify(err) ?? "")
      }
    })
  }

  private MakeRealFullScreen(windowStage: window.WindowStage): void {
    const w = windowStage.getMainWindowSync()
    w.setWindowLayoutFullScreen(true)
    w.setWindowSystemBarEnable([])
  }
}
