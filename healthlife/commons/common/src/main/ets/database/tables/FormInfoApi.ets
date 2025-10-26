/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import RdbUtils from '../RdbUtils';
import { TableApi } from './TableApi';
import ColumnInfo from '../../model/ColumnModel';
import { FormInfo } from '../../model/database/FormInfo';
import { RdbConstants } from '../../constants/RdbConstants';

// hilog tag.
const TAG: string = 'FormInfoApi';
// this api table name.
const TABLE_NAME: string = RdbConstants.TABLE_OF_FORM;
// this api columns info.
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
// this api columns name of primary key.
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class FormInfoApi implements TableApi<FormInfo> {
  /**
   * The method of inserting a data information.
   * @param { T } data data entities that need to be inserted.
   * @returns { Promise<number> } Returns primary key information for inserting data, and -1 if it fails.
   */
  async insert(data: FormInfo): Promise<number> {
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, false);
    await RdbUtils.rdbStore?.insert(TABLE_NAME, valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
      if (rowId === -1) {
        hilog.error(0x0000, TAG, `Insert is failed, data is ${data.toString()}`);
      }
      hilog.info(0x0000, TAG, `Insert is successful, data is ${data.toString()}`);
      result = rowId;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Insert is failed, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * The method of batch inserting data information.
   * @param { T[] } dataList data entities List that need to be inserted.
   * @returns { Promise<number[]> } Returns rows count for inserting data, and -1 if it fails.
   */
  async batchInsert(dataList: FormInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      valueBucketList.push(this.convertEntity2ValuesBucket(data, false))
    }
    await RdbUtils.rdbStore?.batchInsert(TABLE_NAME, valueBucketList).then((count: number) => {
      if (count === -1) {
        hilog.error(0x0000, TAG, 'Batch insert is failed');
      }
      hilog.info(0x0000, TAG, 'Batch insert is successful');
      result = count;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Batch insert is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * The method of deleting a data information.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be deleted.
   * @returns { Promise<boolean> } returns the deleted result.
   */
  async delete(primaryKey: string): Promise<boolean> {
    let result = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.delete(predicates).then((rows: number) => {
      hilog.info(0x0000, TAG, `Delete is successful, primaryKey is ${primaryKey}, affected rows is ${rows}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Delete is failed, primaryKey is ${primaryKey}, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  /**
   * The method of updating a data information.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be updated.
   * @param { T } data data entities that need to be updated.
   * @returns { Promise<boolean> } returns the updated result.
   */
  async update(primaryKey: string, data: FormInfo): Promise<boolean> {
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then(async (rows: number) => {
      hilog.info(0x0000, TAG,
        `Updated is successful, primaryKey is ${primaryKey}, data is ${data.toString()}, affected rows is ${rows}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Updated is failed, primaryKey is ${primaryKey}, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  /**
   * The method of querying a data information.
   * @param { string } querySql the query sql statement that needs to be executed.
   * @returns { Promise<T[]> } returns the list of data that were queried.
   */
  async query(querySql: string): Promise<FormInfo[]> {
    let resultList: FormInfo[] = [];
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        resultList.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
      hilog.info(0x0000, TAG, `Query is successful, querySql is [${querySql}], query count is ${resultList.length}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Query is failed, querySql is [${querySql}], code is ${err.code}, message is ${err.message}`);
    });
    return resultList;
  }

  /**
   * The method of querying a data information by primary key.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be queried.
   * @returns { Promise<T | null> } returns the data that were queried.
   */
  async queryByKey(primaryKey: string): Promise<FormInfo | null> {
    let result: FormInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow()
        result = this.convertResultSet2Entity(resultSet)
        hilog.info(0x0000, TAG,
          `Query is successful, primaryKey is ${primaryKey}, query result is ${result.toString()}`);
      } else {
        hilog.error(0x0000, TAG,
          `Query is failed, primaryKey is ${primaryKey}, query count is ${resultSet.rowCount}`);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Query is failed, primaryKey is ${primaryKey}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async updateByKey(date: string, targetTaskNum: number, finTaskNum: number): Promise<boolean> {
    let result: boolean = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, date);
    let valueBucket: relationalStore.ValuesBucket = {
      'targetTaskNum': targetTaskNum,
      'finTaskNum': finTaskNum,
    }
    await RdbUtils.rdbStore?.update(valueBucket, predicates).then(async () => {
      hilog.info(0x0000, TAG,
        `Updated is successful, date is ${date}, targetTaskNum is ${targetTaskNum}, finTaskNum is ${finTaskNum}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Updated failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  /**
   * convert entity information to a ValuesBucket type.
   * @param { T } data T entity information.
   * @param { boolean } excludePrimary Whether to exclude the conversion of the primary key.
   * @returns { relationalStore.ValuesBucket }  ValuesBucket of T.
   */
  convertEntity2ValuesBucket(data: FormInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
    let valueBucket = {} as relationalStore.ValuesBucket;
    for (let item of COLUMNS_INFO) {
      if (excludePrimary && item.primary) {
        continue;
      }
      let name = item.name;
      switch (name) {
        case 'formId':
          valueBucket[name] = data.formId;
          break;
        case 'formName':
          valueBucket[name] = data.formName;
          break;
        case 'formDimension':
          valueBucket[name] = data.formDimension;
          break;
        default:
          break;
      }
    }
    return valueBucket;
  }

  /**
   * convert ResultSet to entity information.
   * @param { relationalStore.ResultSet } resultSet a database result set.
   * @returns { T } T entity information.
   */
  convertResultSet2Entity(resultSet: relationalStore.ResultSet): FormInfo {
    const formId = resultSet.getValue(resultSet.getColumnIndex('formId')) as string;
    const formName = resultSet.getValue(resultSet.getColumnIndex('formName')) as string;
    const formDimension = resultSet.getValue(resultSet.getColumnIndex('formDimension')) as number;
    return new FormInfo(formId, formName, formDimension);
  }

  /**
   * query all service card information.
   * @returns { Promise<FormInfo[]> } all service card information.
   */
  async queryAll(): Promise<FormInfo[]> {
    const querySql = 'SELECT * FROM formInfo';
    return this.query(querySql);
  }
}

export default new FormInfoApi();