/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { PreferenceManager } from '@ohos/datastore';

const DARK_MODE_CONFIG: string = 'dark_mode_config';

@Observed
export class DarkModeSettingsConfig {
  // Value: - 1: Not set, 0: On all day, 1: On at scheduled time.
  switchType: DarkModeType = DarkModeType.FOLLOW_UP;
  startTime: Date = new Date();
  endTime: Date = new Date();

  constructor() {
    const startDate = new Date();
    const endDate = new Date(startDate);
    // Set default time.
    startDate.setHours(22);
    startDate.setMinutes(0);
    this.startTime = startDate;
    endDate.setHours(7);
    endDate.setMinutes(30);
    this.endTime = endDate;
  }
}

export enum DarkModeType {
  FOLLOW_UP = -1,
  ALL_DAY = 0,
  TIMED = 1,
}

export class DarkModeUtil {
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  private static instance: DarkModeUtil;

  public static getInstance(): DarkModeUtil {
    if (!DarkModeUtil.instance) {
      DarkModeUtil.instance = new DarkModeUtil();
    }
    return DarkModeUtil.instance;
  }

  public saveDarkModeSettingsConfig(darkModeConfig: DarkModeSettingsConfig) {
    this.preferenceManager.setValue<DarkModeSettingsConfig>(DARK_MODE_CONFIG, darkModeConfig);
    this.checkDarkMode(darkModeConfig);
  }

  public checkDarkModeSetting(): void {
    this.preferenceManager.getValue<DarkModeSettingsConfig>(DARK_MODE_CONFIG)
      .then((config: DarkModeSettingsConfig | null) => {
        let darkModeConfig = config as DarkModeSettingsConfig;
        if (!darkModeConfig) {
          darkModeConfig = new DarkModeSettingsConfig();
        }
        darkModeConfig.startTime = new Date(darkModeConfig.startTime);
        darkModeConfig.endTime = new Date(darkModeConfig.endTime);
        this.checkDarkMode(darkModeConfig);
      });
  }

  private checkDarkMode(darkModeConfig: DarkModeSettingsConfig): void {
    AppStorage.setOrCreate('darkModeConfig', darkModeConfig);
    let applicationContext = getContext(this).getApplicationContext();
    let colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    if (darkModeConfig.switchType === DarkModeType.FOLLOW_UP) {
      colorMode = (getContext(this) as common.UIAbilityContext).config.colorMode ||
      AppStorage.get('systemColorMode') || ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    } else if (darkModeConfig.switchType === DarkModeType.ALL_DAY) {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    } else {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      const startTime: number = darkModeConfig.startTime.getHours() * 60 + darkModeConfig.startTime.getMinutes();
      const endTime: number = darkModeConfig.endTime.getHours() * 60 + darkModeConfig.endTime.getMinutes();
      const nowTime: number = new Date().getHours() * 60 + new Date().getMinutes();
      // Determine the applied dark and light color mode based on the current time.
      if (startTime > endTime) {
        if (nowTime <= endTime || nowTime >= startTime) {
          colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        }
      } else {
        if (nowTime >= startTime && nowTime <= endTime) {
          colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        }
      }
    }
    AppStorage.setOrCreate('currentColorMode', colorMode);
    applicationContext.setColorMode(colorMode);
  }
}