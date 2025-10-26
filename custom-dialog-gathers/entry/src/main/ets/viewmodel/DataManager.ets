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
import { DateModel } from './DateModel';
import { getRealTimeDate } from './GetDate';

export class DataManager {
  static getDate(context: Context, callback: (dateModel: DateModel) => void) {
    let dateModel: DateModel = getRealTimeDate();
    try {
      let promise = preferences.getPreferences(context, 'date');
      promise.then((object: preferences.Preferences) => {
        try {
          let getPromise = object.get('selectedDate', '');
          getPromise.then((data: preferences.ValueType) => {
            let dateSting = data as string;
            if (dateSting.length > 0) {
              dateModel = JSON.parse(dateSting) as DateModel;
              callback(dateModel);
            } else {
              callback(dateModel);
            }
          }).catch(() => {
            callback(dateModel);
          })
        } catch (err) {
          callback(dateModel);
        }
      }).catch(() => {
        callback(dateModel);
      })
    } catch (err) {
      callback(dateModel);
    }
  }

  static setDate(context: Context, dateModel: DateModel, callback: () => void) {
    try {
      let promise = preferences.getPreferences(context, 'date');
      promise.then((object: preferences.Preferences) => {
        try {
          let setPromise = object.put('selectedDate', JSON.stringify(dateModel));
          setPromise.then(() => {
            let flushPromise = object.flush();
            flushPromise.then(() => {
              AppStorage.setOrCreate<DateModel>('selectedDate', dateModel);
              callback();
            }).catch(() => {
              callback();
            })
          }).catch(() => {
            callback();
          })
        } catch (err) {
          callback();
        }
      }).catch(() => {
        callback();
      })
    } catch (err) {
      callback();
    }
  }

  static deleteDate(context: Context, callback: () => void) {
    try {
      let promise = preferences.getPreferences(context, 'date');
      promise.then((object: preferences.Preferences) => {
        try {
          let deletePromise = object.delete('selectedDate');
          deletePromise.then(() => {
            let flushPromise = object.flush();
            flushPromise.then(() => {
              AppStorage.setOrCreate<DateModel>('selectedDate', undefined);
              callback();
            }).catch(() => {
            })
          }).catch(() => {
          })
        } catch (err) {
        }
      }).catch(() => {
      })
    } catch (err) {
    }
  }
}
