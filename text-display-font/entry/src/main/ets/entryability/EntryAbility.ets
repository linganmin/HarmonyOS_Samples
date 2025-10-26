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

import { AbilityConstant, ConfigurationConstant, EnvironmentCallback, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { FontType } from '../common/CommonData';
import PreferenceUtils from '../common/CommonUtils';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';
let callbackId: number;
let envFont: FontType = {
  fontSizeScale: 0,
  fontWeightScale: 0,
};

// [Start Get_Preference]
export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    // Get preference instance
    PreferenceUtils.getTextFontPreference(this.context);
    // [StartExclude Get_Preference]
    // [Start sys_environment_info]
    // System environment change information
    let envCallback: EnvironmentCallback = {
      onConfigurationUpdated(config) {
        envFont.fontSizeScale = config.fontSizeScale; // Font size scaling ratio
        envFont.fontWeightScale = config.fontWeightScale; // Font thickness scaling ratio
      },
      onMemoryLevel(level) {
        hilog.info(DOMAIN, TAG, `onMemoryLevel level: ${level}`);
      }
    }
    let appContext = this.context.getApplicationContext();
    // Register to monitor changes in the system environment
    callbackId = appContext.on('environment', envCallback);
    // [End sys_environment_info]
    AppStorage.setOrCreate('envFont', envFont);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.error(0x0000, 'testTag',`setColorMode failed, Code:${error.code}, message:${error.message}`);
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // [EndExclude Get_Preference]
  }

  // [StartExclude Get_Preference]
  onDestroy(): void {
    // Cancel monitoring of system environment changes
    let appContext = this.context.getApplicationContext();
    appContext.off('environment', callbackId, (error, data) => {
      if (error) {
        hilog.error(DOMAIN, TAG, `unregisterEnvironmentCallback fail, err: ${JSON.stringify(error)}`);
      }
      hilog.info(DOMAIN, TAG, `unregisterEnvironmentCallback success, data: ${JSON.stringify(data)}`);
    });

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

  // [EndExclude Get_Preference]
}

// [Start Get_Preference]