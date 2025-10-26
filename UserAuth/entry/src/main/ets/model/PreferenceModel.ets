/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { preferences } from '@kit.ArkData'
import CommonConstants from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;

class PreferenceModel {
  private preference?: preferences.Preferences;

  /**
   * Read the specified Preferences persistence file and load the data into the Preferences instance.
   */
  getPreferencesFromStorage(): preferences.Preferences | undefined {
    if (!this.preference) {
      let options: preferences.Options = { name: CommonConstants.PREFERENCES_NAME};
      try {
        this.preference = preferences.getPreferencesSync(context, options);
        return this.preference;
      } catch (error) {
        hilog.error(0x0000, 'UserAuth', `replaceUrl error ${JSON.stringify(error)}`);
      }
    }
    return this.preference;
  }

  /**
   * Save the data to the Preferences.
   *
   * @param key Key.
   * @param Data to be saved.
   */
  putPreference(key: string, value: preferences.ValueType) {
    let preference = this.getPreferencesFromStorage();
    if (!key || !value || !preference) {
      return;
    }
    try {
      preference.putSync(key, value);
    } catch (error) {
      hilog.error(0x0000, 'UserAuth', `putSync error ${JSON.stringify(error)}`);
    }
    preference.flush().catch((error: BusinessError) => {
      hilog.error(0x0000, 'UserAuth', `flush error ${error.code}`);
    });
  }

  /**
   * Get preference data.
   *
   * @param key Key.
   * @param value Default value.
   */
  getPreference(key: string, value: preferences.ValueType): preferences.ValueType {
    let preference = this.getPreferencesFromStorage();
    if (!preference) {
      return '';
    }
    try {
      return preference.getSync(key, value);
    } catch (error) {
      hilog.error(0x0000, 'UserAuth', `getSync error ${JSON.stringify(error)}`);
    }
    return '';
  }
}

export default new PreferenceModel();