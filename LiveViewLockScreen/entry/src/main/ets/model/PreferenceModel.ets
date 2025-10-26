/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { preferences } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

class PreferenceModel {
  private preference?: preferences.Preferences;

  /**
   * Read the specified Preferences persistence file and load the data into the Preferences instance.
   */
  getPreferencesFromStorage(context: Context): preferences.Preferences | undefined {
    if (!this.preference) {
      let options: preferences.Options = { name: 'LiveViewLockScreen' };
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
  putPreference(context: Context, key: string, value: preferences.ValueType) {
    let preference = this.getPreferencesFromStorage(context);
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
  getPreference(context: Context, key: string, value: preferences.ValueType): preferences.ValueType {
    let preference = this.getPreferencesFromStorage(context);
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