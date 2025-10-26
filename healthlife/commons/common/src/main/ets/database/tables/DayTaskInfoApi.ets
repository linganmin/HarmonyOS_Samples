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
import { RdbConstants } from '../../constants/RdbConstants';
import { DayTaskInfo } from '../../model/database/DayTaskInfo';

// hilog tag
const TAG: string = 'DayTaskInfoApi';
// this api table name
const TABLE_NAME: string = RdbConstants.TABLE_OF_DAY_TASK;
// this api columns info
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
// this api columns name of primary key
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class DayTaskInfoApi implements TableApi<DayTaskInfo> {
  /**
   * The method of inserting a data information.
   * @param { T } data data entities that need to be inserted.
   * @returns { Promise<number> } Returns primary key information for inserting data, and -1 if it fails.
   */
  async insert(data: DayTaskInfo): Promise<number> {
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
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
  async batchInsert(dataList: DayTaskInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      valueBucketList.push(this.convertEntity2ValuesBucket(data, true))
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
  async delete(primaryKey: number): Promise<boolean> {
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
  async update(primaryKey: number, data: DayTaskInfo): Promise<boolean> {
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then(async (rows: number) => {
      hilog.info(0x0000, TAG,
        `Updated is successful, primaryKey is [${primaryKey}], data is ${data.toString()}, affected rows is ${rows}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Updated is failed, primaryKey is [${primaryKey}], data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  /**
   * The method of querying a data information.
   * @param { string } querySql the query sql statement that needs to be executed.
   * @returns { Promise<T[]> } returns the list of data that were queried.
   */
  async query(querySql: string): Promise<DayTaskInfo[]> {
    let resultList: DayTaskInfo[] = [];
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
  async queryByKey(primaryKey: number): Promise<DayTaskInfo | null> {
    let result: DayTaskInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow()
        result = this.convertResultSet2Entity(resultSet)
        hilog.info(0x0000, TAG,
          `Query is successful, primaryKey is ${primaryKey}, query result is ${result.toString()}`);
      } else {
        hilog.info(0x0000, TAG,
          `Query is failed, primaryKey is ${primaryKey}, query count is ${resultSet.rowCount}`);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Query is failed, primaryKey is ${primaryKey}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * convert entity information to a ValuesBucket type.
   * @param { T } data T entity information.
   * @param { boolean } excludePrimary Whether to exclude the conversion of the primary key.
   * @returns { relationalStore.ValuesBucket }  ValuesBucket of T.
   */
  convertEntity2ValuesBucket(data: DayTaskInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
    let valueBucket = {} as relationalStore.ValuesBucket;
    for (let item of COLUMNS_INFO) {
      if (excludePrimary && item.primary) {
        continue;
      }
      let name = item.name;
      switch (name) {
        case 'id':
          valueBucket[name] = data.id;
          break;
        case 'date':
          valueBucket[name] = data.date;
          break;
        case 'taskId':
          valueBucket[name] = data.taskId;
          break;
        case 'targetValue':
          valueBucket[name] = data.targetValue;
          break;
        case 'finValue':
          valueBucket[name] = data.finValue;
          break;
        case 'isDone':
          valueBucket[name] = data.isDone;
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
  convertResultSet2Entity(resultSet: relationalStore.ResultSet): DayTaskInfo {
    const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
    const date = resultSet.getValue(resultSet.getColumnIndex('date')) as string;
    const taskId = resultSet.getValue(resultSet.getColumnIndex('taskId')) as number;
    const targetValue = resultSet.getValue(resultSet.getColumnIndex('targetValue')) as string;
    const finValue = resultSet.getValue(resultSet.getColumnIndex('finValue')) as string;
    const isDone = resultSet.getValue(resultSet.getColumnIndex('isDone')) ? true : false;
    return new DayTaskInfo(id, date, taskId, targetValue, finValue, isDone);
  }

  /**
   * Query the primary key of the task information for the day based on the date and task ID.
   * @param { string } date date of the day.
   * @param { number } taskId id of the task.
   * @returns { Promise<number> } primary key of the task information.
   */
  async queryKeyByDateAndTaskId(date: string, taskId: number): Promise<number> {
    let result: number = -1;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('date', date);
    predicates.equalTo('taskId', taskId);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow()
        result = resultSet.getValue(resultSet.getColumnIndex('id')) as number
        hilog.info(0x0000, TAG,
          `Query is successful, date is ${date}, taskId is ${taskId}, query result is ${result}`);
      } else {
        hilog.error(0x0000, TAG,
          `Query is failed, date is ${date}, taskId is ${taskId}, query count is ${resultSet.rowCount}`);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Query is failed, date is ${date}, taskId is ${taskId}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * query the list of opened task information.
   * @returns { Promise<TaskInfo[]> } opened task list.
   */
  async queryDayTaskInfo(date: string): Promise<DayTaskInfo[]> {
    let result: DayTaskInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('date', date);
    predicates.orderByAsc('taskId')
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 0) {
        hilog.info(0x0000, TAG, `Query dayTaskInfo is failed, query result is empty`);
        resultSet.close();
        return;
      }
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
      hilog.info(0x0000, TAG, `Query dayTaskInfo is successful, query result is ${result.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query dayTaskInfo is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }
}

export default new DayTaskInfoApi();