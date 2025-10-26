/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  NetRecommendationCallback,
  setOffMultiPathRecommendation,
  setOnMultiPathRecommendation
} from '../net/NetBoostManager';
import { netHandover } from '@kit.NetworkBoostKit';
import { showToast } from '../utils/CommonUtils';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private netRecommend: NetRecommendationCallback = {
    onRecommend: (data: netHandover.MultiPathRecommendationInfo): void => {
      if (data.action === netHandover.MultiPathAction.MULTIPATH_ACTION_REQUEST) {
        showToast($r('app.string.suggest_open'));
      } else if (data.action === netHandover.MultiPathAction.MULTIPATH_ACTION_RELEASE) {
        showToast($r('app.string.suggest_close'));
      } else {
        showToast($r('app.string.unkown'));
      }
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      hilog.info(DOMAIN, TAG, `abilityName:${want?.abilityName},launchReason${launchParam?.launchReason}`);
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      setOnMultiPathRecommendation(this.netRecommend);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, `Failed to setColorMode. Cause: ${err.code},${err.name}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/IndexPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `Failed to load the content. Cause: ${err.code},${err.name}`);
        return;
      }
      try {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync()?.getUIContext());
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `Failed to getUIContext. Cause: ${err.code},${err.name}`);
      }
      AppStorage.setOrCreate('context', this.context);
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onDestroy(): void | Promise<void> {
    setOffMultiPathRecommendation();
  }
}