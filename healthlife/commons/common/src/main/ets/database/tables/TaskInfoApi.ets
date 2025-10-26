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
import DayInfoApi from './DayInfoApi';
import { TableApi } from './TableApi';
import DayTaskInfoApi from './DayTaskInfoApi';
import ColumnInfo from '../../model/ColumnModel';
import { RdbConstants } from '../../constants/RdbConstants';
import { taskBaseInfoList } from '../../model/TaskBaseModel';
import { CommonConstants as Const } from '../../constants/CommonConstants';
import { defaultTaskInfoList, TaskInfo } from '../../model/database/TaskInfo';

// hilog tag
const TAG: string = 'TaskInfoApi';
// this api table name
const TABLE_NAME: string = RdbConstants.TABLE_OF_TASK;
// this api columns info
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
// this api columns name of primary key
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class TaskInfoApi implements TableApi<TaskInfo> {
  /**
   * The method of inserting a data information.
   * @param { T } data data entities that need to be inserted.
   * @returns { Promise<number> } Returns primary key information for inserting data, and -1 if it fails.
   */
  async insert(data: TaskInfo): Promise<number> {
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
  async batchInsert(dataList: TaskInfo[]): Promise<number> {
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
  async update(primaryKey: number, data: TaskInfo): Promise<boolean> {
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
  async query(querySql: string): Promise<TaskInfo[]> {
    let resultList: TaskInfo[] = [];
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
  async queryByKey(primaryKey: number): Promise<TaskInfo | null> {
    let result: TaskInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow()
        result = this.convertResultSet2Entity(resultSet)
        hilog.info(0x0000, TAG,
          `Query is successful, primaryKey is ${primaryKey}, query result is ${result.toString()}`);
      } else {
        hilog.error(0x0000, TAG, `Query is failed, primaryKey is ${primaryKey}, query count is ${resultSet.rowCount}`);
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
  convertEntity2ValuesBucket(data: TaskInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
    let valueBucket = {} as relationalStore.ValuesBucket;
    for (let item of COLUMNS_INFO) {
      if (excludePrimary && item.primary) {
        continue;
      }
      let name = item.name;
      switch (name) {
        case 'taskId':
          valueBucket[name] = data.taskId;
          break;
        case 'isOpen':
          valueBucket[name] = data.isOpen;
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
        case 'isAlert':
          valueBucket[name] = data.isAlert;
          break;
        case 'alertStartTime':
          valueBucket[name] = data.alertStartTime;
          break;
        case 'alertEndTime':
          valueBucket[name] = data.alertEndTime;
          break;
        case 'alertFrequency':
          valueBucket[name] = data.alertFrequency;
          break;
        case 'reminderId':
          valueBucket[name] = data.reminderId;
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
  convertResultSet2Entity(resultSet: relationalStore.ResultSet): TaskInfo {
    const taskId = resultSet.getValue(resultSet.getColumnIndex('taskId')) as number;
    const isOpen = resultSet.getValue(resultSet.getColumnIndex('isOpen')) ? true : false;
    const targetValue = resultSet.getValue(resultSet.getColumnIndex('targetValue')) as string;
    const finValue = resultSet.getValue(resultSet.getColumnIndex('finValue')) as string;
    const isDone = resultSet.getValue(resultSet.getColumnIndex('isDone')) ? true : false;
    const isAlert = resultSet.getValue(resultSet.getColumnIndex('isAlert')) ? true : false;
    const alertStartTime = resultSet.getValue(resultSet.getColumnIndex('alertStartTime')) as string;
    const alertEndTime = resultSet.getValue(resultSet.getColumnIndex('alertEndTime')) as string;
    const alertFrequency = resultSet.getValue(resultSet.getColumnIndex('alertFrequency')) as string;
    const reminderId = resultSet.getValue(resultSet.getColumnIndex('reminderId')) as number;
    return new TaskInfo(taskId, isOpen, targetValue, finValue, isDone, isAlert, alertStartTime, alertEndTime,
      alertFrequency, reminderId);
  }

  /**
   * check if the default task exists and complete it.
   * @returns { Promise<boolean> } check if it was successful.
   */
  async checkDefaultTask(): Promise<boolean> {
    let taskList: TaskInfo[] = await this.query('SELECT * FROM taskInfo');
    if (taskList.length === Const.TASK_NUM) {
      return true;
    }
    let exitsIndex: number[] = [];
    for (let task of taskList) {
      exitsIndex.push(task.taskId);
    }
    let missInfoList: TaskInfo[] = [];
    for (let index = 0; index < Const.TASK_NUM; index++) {
      if (exitsIndex.includes(index)) {
        continue;
      }
      missInfoList.push(defaultTaskInfoList[index]);
    }
    await this.batchInsert(missInfoList);
    return true;
  }

  /**
   * query the list of task information.
   * @returns { Promise<TaskInfo[]> } task list.
   */
  async queryAllTaskInfo(): Promise<TaskInfo[]> {
    let result: TaskInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByAsc(PRIMARY_KEY)
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 0) {
        hilog.info(0x0000, TAG, `Query all task is failed, query result is empty`);
        resultSet.close();
        return;
      }
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
      hilog.info(0x0000, TAG, `Query all task is successful, query result is ${result.toString()}`);
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query all task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * query the list of opened task information.
   * @returns { Promise<TaskInfo[]> } opened task list.
   */
  async queryOpenedTaskInfo(): Promise<TaskInfo[]> {
    let result: TaskInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('isOpen', true);
    predicates.orderByAsc(PRIMARY_KEY)
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 0) {
        hilog.info(0x0000, TAG, `Query opened task is failed, query result is empty`);
        resultSet.close();
        return;
      }
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
      hilog.info(0x0000, TAG, `Query opened task is successful, query result is ${result.toString()}`);
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query opened task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  /**
   * initialize all tasks to an incomplete state.
   * @returns { Promise<boolean> } initialization succeeded.
   */
  async initAllTask(): Promise<boolean> {
    let initSql = `UPDATE ${TABLE_NAME} SET isDone = false, finValue = ""`
    let result = await RdbUtils.executeSql(initSql);
    if (result) {
      hilog.info(0x0000, TAG, `Init all task is successful`);
    } else {
      hilog.error(0x0000, TAG, `Init all task is failed`);
    }
    return result;
  }

  /**
   * Open the task and update the relevant information synchronously.
   * @param { string } date date of the day.
   * @param { number } taskId id of the task.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async openTask(date: string, taskId: number): Promise<boolean> {
    // Determine whether the task is open.
    let oldTaskInfo = await this.queryByKey(taskId);
    if (!oldTaskInfo) {
      return false;
    }
    if (oldTaskInfo.isOpen) {
      hilog.info(0x0000, TAG, `The current task is opened and cannot be open, taskId is ${taskId}`);
      return true;
    }

    // modify the current task to open.
    let result = true;
    let openTaskSql = `UPDATE ${TABLE_NAME} SET isOpen = true, finValue = "" WHERE taskId = ${taskId}`
    result = await RdbUtils.executeSql(openTaskSql);
    if (!result) {
      return result;
    }

    // Synchronously add the task information records of the day.
    await DayTaskInfoApi.queryKeyByDateAndTaskId(date, taskId).then(async (key: number) => {
      if (key === -1) {
        let taskInfo = await this.queryByKey(taskId);
        if (!taskInfo) {
          return;
        }
        await DayTaskInfoApi.insert(taskInfo.convert2DefaultDayTask(date));
      }
    })
    if (!result) {
      return result;
    }

    // Synchronously modify the number of information tasks for the day.
    result = await DayInfoApi.updateDayByTaskStatus(date);

    return result;
  }

  /**
   * Open the task and update the relevant information synchronously.
   * @param { string } date date of the day.
   * @param { number } taskId id of the task.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async closeTask(date: string, taskId: number): Promise<boolean> {
    // Determine whether the task is open.
    let oldTaskInfo = await this.queryByKey(taskId);
    if (!oldTaskInfo) {
      return false;
    }
    if (!oldTaskInfo.isOpen) {
      hilog.info(0x0000, TAG, `The current task is closed and cannot be close, taskId is ${taskId}`);
      return true;
    }

    let result = true;
    // modify the current task to close.
    let openTaskSql = `UPDATE ${TABLE_NAME} SET isOpen = false WHERE taskId = ${taskId}`
    result = await RdbUtils.executeSql(openTaskSql);
    if (!result) {
      return result;
    }

    // If this task is not done, synchronously delete the task information records of the day and taskId.
    if (!oldTaskInfo.isDone) {
      let key = await DayTaskInfoApi.queryKeyByDateAndTaskId(date, taskId);
      result = await DayTaskInfoApi.delete(key);
      if (!result) {
        return result;
      }
    }

    // Synchronously modify the number of information tasks for the day.
    result = await DayInfoApi.updateDayByTaskStatus(date);

    return result;
  }

  /**
   * Clock the task and update the relevant information synchronously.
   * @param { string } date date of the day.
   * @param { number } taskId id of the task.
   * @returns { Promise<boolean> } whether it was successful or not.
   */
  async clockTask(date: string, taskId: number): Promise<boolean> {
    // Determine whether the task is done.
    let taskInfo = await this.queryByKey(taskId);
    if (!taskInfo) {
      return false;
    }
    if (!taskInfo.isOpen) {
      hilog.info(0x0000, TAG, `The current task is not open and cannot be clock, taskId is ${taskInfo.taskId}`);
      return true;
    }
    if (taskInfo.isDone) {
      hilog.info(0x0000, TAG, `The current task is done and cannot be clock, taskId is ${taskInfo.taskId}`);
      return true;
    }

    let result = true;
    /*
     * Step 0 means that the task is a one-time task and can be completed directly.
     * Otherwise, you need to add the step value to determine whether it is completed.
     */
    let step = taskBaseInfoList[taskId].step;
    if (step === 0) {
      taskInfo.finValue = taskInfo.targetValue;
      taskInfo.isDone = true;
    } else {
      let finValue = Number(taskInfo.finValue) + step;
      taskInfo.finValue = finValue.toString();
      taskInfo.isDone = finValue >= Number(taskInfo.targetValue);
    }

    result = await this.update(taskId, taskInfo);
    if (!result) {
      return result;
    }

    let key = await DayTaskInfoApi.queryKeyByDateAndTaskId(date, taskId);
    result = await DayTaskInfoApi.update(key, taskInfo.convert2DayTask(date));
    if (!result) {
      return result;
    }
    // Synchronously modify the information for the day info.
    return await DayInfoApi.updateDayByTaskStatus(date);
  }
}

export default new TaskInfoApi();