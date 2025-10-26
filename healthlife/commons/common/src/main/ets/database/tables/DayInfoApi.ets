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
import TaskInfoApi from './TaskInfoApi';
import DayTaskInfoApi from './DayTaskInfoApi';
import ColumnInfo from '../../model/ColumnModel';
import { DayInfo } from '../../model/database/DayInfo';
import { TaskInfo } from '../../model/database/TaskInfo';
import { RdbConstants } from '../../constants/RdbConstants';
import PreferencesUtils from '../../utils/PreferencesUtils';
import { DayTaskInfo } from '../../model/database/DayTaskInfo';
import { convertDate2Str, convertStr2Date } from '../../utils/Utils';
import { CommonConstants as Const } from '../../constants/CommonConstants';
import FormUtils from '../../utils/FormUtils';

// hilog tag.
const TAG: string = 'DayInfoApi';
// this api table name.
const TABLE_NAME: string = RdbConstants.TABLE_OF_DAY;
// this api columns info.
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
// this api columns name of primary key.
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class DayInfoApi implements TableApi<DayInfo> {
  /**
   * The method of inserting a data information.
   * @param { T } data data entities that need to be inserted.
   * @returns { Promise<number> } Returns primary key information for inserting data, and -1 if it fails.
   */
  async insert(data: DayInfo): Promise<number> {
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
  async batchInsert(dataList: DayInfo[]): Promise<number> {
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
  async update(primaryKey: string, data: DayInfo): Promise<boolean> {
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
  async query(querySql: string): Promise<DayInfo[]> {
    let resultList: DayInfo[] = [];
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
  async queryByKey(primaryKey: string): Promise<DayInfo | null> {
    let result: DayInfo | null = null;
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
  convertEntity2ValuesBucket(data: DayInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
    let valueBucket = {} as relationalStore.ValuesBucket;
    for (let item of COLUMNS_INFO) {
      if (excludePrimary && item.primary) {
        continue;
      }
      let name = item.name;
      switch (name) {
        case 'date':
          valueBucket[name] = data.date;
          break;
        case 'targetTaskNum':
          valueBucket[name] = data.targetTaskNum;
          break;
        case 'finTaskNum':
          valueBucket[name] = data.finTaskNum;
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
  convertResultSet2Entity(resultSet: relationalStore.ResultSet): DayInfo {
    const date = resultSet.getValue(resultSet.getColumnIndex('date')) as string;
    const targetTaskNum = resultSet.getValue(resultSet.getColumnIndex('targetTaskNum')) as number;
    const finTaskNum = resultSet.getValue(resultSet.getColumnIndex('finTaskNum')) as number;
    return new DayInfo(date, targetTaskNum, finTaskNum);
  }

  /**
   * initialize the information of the day.
   * @param { string } date date of the day.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async initDayInfo(date: string): Promise<boolean> {
    let result = -1;
    let currentDayInfo: DayInfo | null = await this.queryByKey(date);
    let taskListOfOpen: TaskInfo[] = await TaskInfoApi.queryOpenedTaskInfo();

    if (currentDayInfo) {
      // current day info exist, check day and task info Whether it is complete.
      let queryDayTaskSql = `SELECT * FROM dayTaskInfo WHERE date = ${date} ORDER BY taskId`;
      let dayTaskList: DayTaskInfo[] = await DayTaskInfoApi.query(queryDayTaskSql);
      if (taskListOfOpen.length !== dayTaskList.length) {
        // day and task info partially missing, identify missing information and insert it.
        let exitsIndex: number[] = [];
        for (let dayTask of dayTaskList) {
          exitsIndex.push(dayTask.taskId);
        }

        let missInfoList: DayTaskInfo[] = [];
        for (let taskOfOpen of taskListOfOpen) {
          if (exitsIndex.includes(taskOfOpen.taskId)) {
            continue;
          }
          missInfoList.push(taskOfOpen.convert2DefaultDayTask(date));
        }

        result = await DayTaskInfoApi.batchInsert(missInfoList);
        if (result === -1) {
          hilog.error(0x0000, TAG, `Additional current day and task info failed`);
          return false;
        }
        hilog.info(0x0000, TAG, `Additional current day and task info successed`);
      }
      return true;
    }

    // Current day info not exist, it means that the application is opened for the first time that day, and all tasks are initialized to not done.
    await TaskInfoApi.initAllTask();

    // current day info not exist, generate the default information of the day and insert.
    result = await this.insert(new DayInfo(date, 0, 0));
    if (result === -1) {
      hilog.error(0x0000, TAG, `Init current day info failed, date is ${date}`);
      return false;
    }
    hilog.info(0x0000, TAG, `Init current day info successed, date is ${date}`);

    // After initializing the current day's information, add the opened task information to the current day's task information.
    let dayTaskInfoList: DayTaskInfo[] = [];
    for (let taskOfOpen of taskListOfOpen) {
      dayTaskInfoList.push(taskOfOpen.convert2DefaultDayTask(date));
    }
    result = await DayTaskInfoApi.batchInsert(dayTaskInfoList)
    if (result === -1) {
      hilog.error(0x0000, TAG, `Init current day of task info failed`);
      return false;
    }
    hilog.info(0x0000, TAG, `Init current day of task info successed`);

    // After the task of the day is successfully added, the information of the day is updated synchronously.
    await this.updateDayByTaskStatus(date);

    return true;
  }

  /**
   * Update the information of the day based on the task information of the day.
   * @param { string } date date of the day.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async updateDayByTaskStatus(date: string): Promise<boolean> {
    let taskListOfOpen: DayTaskInfo[] = await DayTaskInfoApi.queryDayTaskInfo(date);
    let finTaskNum = 0;
    for (let taskOfOpen of taskListOfOpen) {
      if (taskOfOpen.isDone) {
        finTaskNum++;
      }
    }
    let result = await this.updateByKey(date, taskListOfOpen.length, finTaskNum);
    // Update service card information synchronously when tasks change.
    FormUtils.updateForms();
    return result;
  }

  /**
   * Initialize the achievement preference information based on the information of the day.
   * @param { string } date date of the day.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async initAchievementStoreByDayInfo(date: string): Promise<boolean> {
    const currentDayInfo: DayInfo | null = await this.queryByKey(date);
    if (currentDayInfo) {
      // If the information of the day is already there, it means that the initialization is complete, and it will be returned directly.
      return true;
    }

    // The achievement completion status is false on the day of initialization.
    await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(false));

    // If the previous day's information exists and the task is not fully completed, the reset consecutive days record is 0.
    let lastDate = convertStr2Date(date);
    lastDate.setDate(lastDate.getDate() - 1);
    const lastDateStr = convertDate2Str(lastDate);
    const lastDayInfo: DayInfo | null = await this.queryByKey(lastDateStr);
    if (lastDayInfo && lastDayInfo.finTaskNum < lastDayInfo.targetTaskNum) {
      await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS, '0');
    }
    return true;
  }
}

export default new DayInfoApi();