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

import { preferences } from '@kit.ArkData';
import { CardListItemData } from '../CommonData';
import { CommonConstants } from '../CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'PreferencesUtil';
const MY_STORE: string = 'myStore';

export class PreferencesUtil {
  private static preferencesUtil: PreferencesUtil;

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.preferencesUtil) {
      PreferencesUtil.preferencesUtil = new PreferencesUtil();
    }
    return PreferencesUtil.preferencesUtil;
  }

  getPreferences(context: Context): preferences.Preferences | undefined {
    try {
      preferences.removePreferencesFromCacheSync(context, MY_STORE);
      return preferences.getPreferencesSync(context, { name: MY_STORE });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getPreferences failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  preferencesFlush(preferences: preferences.Preferences) {
    preferences.flush((err) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to flush. Code:${err.code}, message:${err.message}`);
      }
    })
  }

  preferencesPut(preferences: preferences.Preferences, key: string, value: preferences.ValueType): void {
    try {
      preferences.putSync(key, value);
      this.preferencesFlush(preferences);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `preferencesPut failed, error code=${err.code}, message=${err.message}`);
    }
  }

  removePreferencesFromCache(context: Context): void {
    preferences.removePreferencesFromCache(context, MY_STORE).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `removePreferencesFromCache failed, error code=${err.code}, message=${err.message}`);
    });
  }

  getFormIds(preferences: preferences.Preferences): Array<string> {
    if (preferences === null) {
      hilog.error(0x0000, TAG, `preferences is null`);
      return [];
    }
    try {
      return preferences.getSync('formIdList', ['']) as Array<string>;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getSync failed, error code=${err.code}, message=${err.message}`);
      return [];
    }
  }

  addFormId(preferences: preferences.Preferences, formId: string): void {
    try {
      if (preferences.hasSync('formIdList')) {
        let formIds = this.getFormIds(preferences);
        if (formIds.indexOf(formId) === -1) {
          formIds.push(formId);
          this.preferencesPut(preferences, 'formIdList', formIds);
        }
      } else {
        this.preferencesPut(preferences, 'formIdList', [formId]);
      }
      this.preferencesFlush(preferences);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to check the key 'formIds'. Code:${error.code}, message:${error.message}`);
    }
  }

  getFormInitData(key: string, preferences: preferences.Preferences): CardListItemData {
    let initData: CardListItemData = CommonConstants.CARD_LIST_DATA_FIRST[0];
    try {
      let index: number = preferences.getSync(key, 0) as number;

      if (preferences.hasSync(`dataArr`)) {
        initData = (preferences.getSync(`dataArr`, []) as CardListItemData[])[index];
        initData.favour = (preferences.getSync(`statusArr`, []) as boolean[])[index];
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getFormInitData failed, error code=${err.code}, message=${err.message}`);
    }
    return initData;
  }

  removeFormId(context: Context, formId: string) {
    try {
      let preferences = this.getPreferences(context);
      if (!preferences) {
        hilog.error(0x0000, TAG, `preferences is null`);
        return;
      }
      if (preferences.hasSync('formIdList')) {
        let formIds = this.getFormIds(preferences);
        let index = formIds.indexOf(formId);
        if (index !== -1) {
          formIds.splice(index, 1);
        }
        this.preferencesPut(preferences, 'formIdList', formIds);
        if (preferences.hasSync(`${formId}_show_index`)) {
          preferences.deleteSync(`${formId}_show_index`);
        }
        this.preferencesFlush(preferences);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to get preferences. Code:${error.code}, message:${error.message}`);
    }
  }
}