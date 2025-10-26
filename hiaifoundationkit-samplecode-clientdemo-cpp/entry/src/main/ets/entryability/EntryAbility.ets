/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window, promptAction } from '@kit.ArkUI'

import hiai from 'libentry.so'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    let ret : number = hiai.LoadModel(this.context.resourceManager) // Loading a Model
    if (ret == 0) {
      promptAction.showToast({
        message: 'load model success.',
        duration: 3000,
      });
      hilog.info(0x0000, 'HiAIFoundationDemo', 'Succeeded in loading model');
    } else {
      promptAction.showToast({
        message: 'load model fail.',
        duration: 3000,
      });
      hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to load model');
    }

    ret = hiai.InitLabels(this.context.resourceManager);
    if (ret == 0) {
      hilog.info(0x0000, 'HiAIFoundationDemo', 'Succeeded in initing labels');
    } else {
      hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to init labels');
    }
  }

  onDestroy() {
    let ret : number = hiai.UnloadModel();  // Unloading a Model
    if (ret == 0) {
      hilog.info(0x0000, 'HiAIFoundationDemo', 'Succeeded in unloading model');
    } else {
      hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to unload model');
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    windowStage.loadContent('pages/Index', (err, data) => {   // Load the page for displaying pictures.
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
