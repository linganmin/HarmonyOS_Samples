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

import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { SongItem } from '../viewmodel/SongItem';
import { Logger } from '../utils/Logger';

const TAG = 'PreferencesUtil';
const PREFERENCE_NAME = 'myStore';
const CURRENT_SONG = 'currentSong';

export class PreferencesUtil {
  private static preferencesUtil: PreferencesUtil;

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.preferencesUtil) {
      PreferencesUtil.preferencesUtil = new PreferencesUtil();
    }
    return PreferencesUtil.preferencesUtil;
  }

  private getPreferences(context: Context): Promise<preferences.Preferences> {
    return new Promise((resolve, reject) => {
      preferences
        .getPreferences(context, PREFERENCE_NAME)
        .then((pref: preferences.Preferences) => {
          Logger.info(TAG, `getPreferences successfully.`);
          resolve(pref);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `getPreferences err code: ${err.code},message: ${err.message}`);
          reject(err);
        });
    });
  }

  private preferencesFlush(preferences: preferences.Preferences) {
    preferences
      .flush()
      .then(() => {
        Logger.info(TAG, `preferencesFlush successfully.`);
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `preferencesFlush err code: ${err.code},message: ${err.message}`);
      });
  }

  private async putValue(context: Context, key: string, value: preferences.ValueType) {
    Logger.info(`putValue key: ${key},value: ${value}`);
    let pre = await this.getPreferences(context);
    pre
      .put(key, value)
      .then(() => {
        this.preferencesFlush(pre);
        Logger.info(TAG, `putValue successfully.`);
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `putValue err code: ${err.code},message: ${err.message}`);
      });
  }

  private async getValue(context: Context, key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    let pre = await this.getPreferences(context);
    return new Promise((resolve, reject) => {
      pre
        .get(key, defaultValue)
        .then((data: preferences.ValueType) => {
          Logger.info(TAG, `getValue successfully,value: ${data.toString()}`);
          resolve(data);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `getValue err code: ${err.code},message: ${err.message}`);
          reject(err);
        });
    });
  }

  public async putCurrentSong(context: Context, currentSong: SongItem) {
    this.putValue(context, CURRENT_SONG, JSON.stringify(currentSong));
  }

  public getCurrentSong(context: Context): Promise<SongItem | undefined> {
    return new Promise((resolve) => {
      try {
        let pre = preferences.getPreferencesSync(context, { name: PREFERENCE_NAME });
        let songStr = pre.getSync(CURRENT_SONG, '') as string;
        if (songStr === '') {
          resolve(undefined);
        } else {
          let currentSong = JSON.parse(songStr) as SongItem;
          resolve(currentSong);
        }
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `getCurrentSong err, code: ${error.code}, mesage: ${error.message}`);
      }
    });
  }
}
