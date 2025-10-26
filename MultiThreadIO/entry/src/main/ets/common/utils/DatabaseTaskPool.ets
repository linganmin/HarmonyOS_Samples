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

import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { taskpool } from '@kit.ArkTS';
import { CommonConstants } from '../constants/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'RDB2.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

// [Start insert]
@Concurrent
async function insert(context: common.UIAbilityContext, valueBucket: Array<relationalStore.ValuesBucket>,
  config: relationalStore.StoreConfig) {
  try {
    const store = await relationalStore.getRdbStore(context, config);
    store.batchInsert('EMPLOYEE', valueBucket).catch(() => {
      hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'batchInsert error');
    });
  } catch (error) {
    hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'batchInsert error');
  }
}
// [End insert]

// [Start read]
@Concurrent
async function read(context: common.UIAbilityContext, config: relationalStore.StoreConfig) {
  try {
    const store = await relationalStore.getRdbStore(context, config);
    const predicates = new relationalStore.RdbPredicates('EMPLOYEE');
    const resultSet = store.querySync(predicates);
    let ValuesBucketArray: ValuesBucket[] = [];
    if (resultSet.rowCount === 0) {
      return ValuesBucketArray;
    }
    resultSet.goToFirstRow();
    do {
      const ValuesBucket = resultSet.getRow() as ValuesBucket;
      ValuesBucketArray.push(ValuesBucket);
    } while (resultSet.goToNextRow());
    resultSet.close();
    return ValuesBucketArray;
  } catch (error) {
    hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'batchInsert error');
    return;
  }
}
// [End read]

export class DatabaseTaskPool {
  private context: common.UIAbilityContext =  uiContext!.getHostContext()! as common.UIAbilityContext;
  private store: relationalStore.RdbStore | undefined = undefined;
  private valueBucketArray: Array<relationalStore.ValuesBucket> = [];

  async init() {
    const SQL_CREATE_TABLE = CommonConstants.SQL_CREATE;
    await relationalStore.getRdbStore(this.context, STORE_CONFIG).catch(() => {
      hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'init error');
    }).then((rdbStore) => {
      this.store = rdbStore as relationalStore.RdbStore;
      try {
        this.store.executeSync(SQL_CREATE_TABLE);
      } catch (error) {
        hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'init error');
      }
    })
  }

  makeData(times: number) {
    const valueBucket: relationalStore.ValuesBucket = {
      'NAME': 'LISA',
      'AGE': 15,
      'SALARY': 100.5
    }
    for (let i: number = 0; i < times; i++) {
      this.valueBucketArray.push(valueBucket);
    }
  }

  // [Start insertrdb]
  async insertRDB(): Promise<void> {
    try {
      await taskpool.execute(insert, this.context, this.valueBucketArray, STORE_CONFIG);
    } catch (error) {
      hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'insertRDB error');

    }
    return;
  }
  // [End insertrdb]

  async readRDB(): Promise<number> {
    try {
      let value = await taskpool.execute(read, this.context, STORE_CONFIG) as ValuesBucket[];
      return value.length;
    } catch (error) {
      hilog.error(0x0000, 'DatabaseTaskPool', '%{public}s', 'insertRDB error');
      return 0;
    }
  }
}