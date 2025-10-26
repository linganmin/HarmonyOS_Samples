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

import { preferences as dataPreferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { FaultDataSource } from '../model/DataSource';
import { Logger } from '../log/Logger';

// Knowledge point: Initialize Preferences instances for persistent storage of
//  exception information and the ability to retrieve persistent data
let dataPreferencesManager: dataPreferences.Preferences = {} as dataPreferences.Preferences;

export class PreferencesManager {
  // Get Preferences instance
  public static async getPreferences(faultDataSource: FaultDataSource): Promise<void> {
    Logger.info('getPreferences start.');
    try {
      let val: dataPreferences.Preferences = await (dataPreferences.getPreferences(AppStorage.get('context'),
        'myStore') as Promise<dataPreferences.Preferences>);
      dataPreferencesManager = val;
      Logger.info('Succeeded in getting preferences.');
      // Get abnormal information
      await PreferencesManager.getFaultMessage(faultDataSource);
      await PreferencesManager.getFaultSign();
    } catch (err) {
      Logger.error('Failed to get preferences');
    }
  }

  /**
   * Storing abnormal data information
   * @Param faultMessage exception information set
   */
  public static async putFaultMessage(faultMessage: Array<string>): Promise<void> {
    Logger.info(`putMessage start`);
    try {
      // Knowledge point: Storing data through the dataPreferencesManager.put method
      dataPreferencesManager.put('faultMessage', JSON.stringify(faultMessage), async (err: BusinessError) => {
        if (err) {
          Logger.error(`Failed to put value of 'faultMessage'. code =` + err.code + ', message =' + err.message);
          return;
        }
        Logger.info('Succeeded in putting value of faultMessage.');
        dataPreferencesManager.flush();
      })
    } catch (err) {
      Logger.error(`Failed to put value of 'catch err'. code =` + err.code + ', message =' + err.message);
    }
  }

  /**
   * Get abnormal data information
   * @Param faultMessage exception information set
   */
  public static async getFaultMessage(faultDataSource: FaultDataSource): Promise<void> {
    Logger.info(`getFaultMessage start`);
    try {
      // Knowledge point: Obtaining abnormal information data through the dataPreferencesManager.get method
      const data: dataPreferences.ValueType = await dataPreferencesManager.get('faultMessage', []);
      if (typeof data === 'string') {
        const faultData: Array<string> = JSON.parse(data);
        // Add abnormal data to lazy loading data source
        faultData.forEach((item: string) => {
          faultDataSource.pushData(item);
        })
        // Bidirectional data binding lazy loading data source length, updating data source length
        AppStorage.setOrCreate('faultDataSourceLength', faultDataSource.totalCount());
        Logger.info('Succeeded in getting value of faultMessage.');
      }
    } catch (err) {
      Logger.error(`Failed to get value of 'catch err'. code =` + err.code + ', message =' + err.message);
    }
  }

  /**
   * Storage data sign
   */
  public static async putFaultSign(): Promise<void> {
    Logger.info(`putMessage start`);
    try {
      // Knowledge point: Storing data through the dataPreferencesManager.put method
      dataPreferencesManager.put('faultSign', JSON.stringify(true), async (err: BusinessError) => {
        if (err) {
          Logger.error(`Failed to put value of 'faultSign'. code =` + err.code + ', message =' + err.message);
          return;
        }
        Logger.info('Succeeded in putting value of faultSign.');
        dataPreferencesManager.flush();
      })
    } catch (err) {
      Logger.error(`putFaultSign Failed to put value of 'catch err'. code =` + err.code + ', message =' + err.message);
    }
  }

  /**
   * Get abnormal data information
   */
  public static async getFaultSign(): Promise<void> {
    Logger.info(`getFaultMessage start`);
    let faultSign: boolean = false;
    try {
      // Knowledge point: Obtain exception identifiers through the dataPreferencesManager.get method
      const data: dataPreferences.ValueType = await dataPreferencesManager.get('faultSign', faultSign);
      if (typeof data === 'string') {
        faultSign = JSON.parse(data);
        AppStorage.setOrCreate('faultSign', faultSign);
      }
    } catch (err) {
      Logger.error(`getFaultSign Failed to get value of 'catch err'. code =` + err.code + ', message =' + err.message);
    }
  }
}