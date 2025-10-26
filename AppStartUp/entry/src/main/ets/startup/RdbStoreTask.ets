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

import { common, StartupTask } from '@kit.AbilityKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RdbStoreUtil } from '../util/SingleKVStore';

@Sendable
export default class RdbStoreTask extends StartupTask {
  constructor() {
    super();
  }

  async init(context: common.AbilityStageContext) {
    RdbStoreUtil.getRdbStore(context)
      .then((rdbStore: relationalStore.RdbStore) => {
        const SQL_CREATE_TABLE =
          'CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, SALARY REAL, CODES BLOB)'; // sql
        rdbStore.executeSql(SQL_CREATE_TABLE); // create table
        let value1 = 'RdbStoreTask init data';
        let value2 = 18;
        let value3 = 100.5;
        let value4 = new Uint8Array([1, 2, 3, 4, 5]);

        const valueBucket1: ValuesBucket = {
          'NAME': value1,
          'AGE': value2,
          'SALARY': value3,
          'CODES': value4,
        };

        rdbStore.insert('EMPLOYEE', valueBucket1, (err: BusinessError, rowId: number) => {
          if (err) {
            hilog.error(0x0000, 'RdbStoreTask', `Failed to insert data. Code:${err.code}, message:${err.message}`);
            return;
          }
          hilog.info(0x0000, 'RdbStoreTask', `Succeeded in inserting data. rowId:${rowId}`);
        })
      }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'RdbStoreTask', `Failed to create KVManager. message:${err.message}`);
    });
  }
}