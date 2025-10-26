/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { TodoItemData, ToDoItemSendable } from '../model/TodoListModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class RdbUtil {
  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'TodoList.db',
    securityLevel: relationalStore.SecurityLevel.S3
  };
  private tableName: string = 'TodoList';
  private store: relationalStore.RdbStore | null = null;

  public static async getInstance(context: Context): Promise<RdbUtil> {
    let rdb = new RdbUtil();
    try {
      rdb.store = await relationalStore.getRdbStore(context, RdbUtil.STORE_CONFIG);
      hilog.info(0x0000, 'RDB', 'Succeeded in getting RdbStore.');
    } catch (err) {
      throw Error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
    }
    return rdb;
  }

  public initRdb() {
    const SQL_CREATE_TABLE =
      'CREATE TABLE IF NOT EXISTS TodoList (id int NOT NULL PRIMARY KEY, taskDetail text NOT NULL, selected bool NULL DEFAULT false)';
    try {
      this.store?.executeSql(SQL_CREATE_TABLE);
    } catch (err) {
      const error = err as BusinessError;
      hilog.info(0x0000, 'RDB', `executeSql failed, code:${error.code}, message:${error.message}`);
    }
  }

  public getAllIds(): number[] {
    const SQL_QUERY_ALL = 'SELECT * FROM TodoList';
    let ids: number[] = [];
    let resultSet: relationalStore.ResultSet | undefined
    try {
      resultSet = this.store?.querySqlSync(SQL_QUERY_ALL);
    } catch (err) {
      const error = err as BusinessError;
      hilog.info(0x0000, 'RDB', `querySqlSync failed, code:${error.code}, message:${error.message}`);
    }
    if (resultSet) {
      try {
        while (resultSet.goToNextRow()) {
          const id = resultSet.getLong(resultSet.getColumnIndex('id'));
          ids.push(id);
        }
      } catch (err) {
        const error = err as BusinessError;
        hilog.info(0x0000, 'RDB', `error processing result, code:${error.code}, message:${error.message}`);
      } finally {
        try {
          resultSet.close();
        } catch (err) {
          const error = err as BusinessError;
          hilog.info(0x0000, 'RDB', `resultSet close failed, code:${error.code}, message:${error.message}`);
        }
      }
    }
    return ids;
  }

  public query(): TodoItemData[] {
    const SQL_QUERY_ALL = 'SELECT * FROM TodoList';
    let todoList: TodoItemData[] = [];
    let resultSet: relationalStore.ResultSet | undefined
    try {
      resultSet = this.store?.querySqlSync(SQL_QUERY_ALL);
    } catch (err) {
      const error = err as BusinessError;
      hilog.info(0x0000, 'RDB', `querySqlSync failed, code:${error.code}, message:${error.message}`);
    }
    if (resultSet) {
      try {
        while (resultSet.goToNextRow()) {
          const id = resultSet.getLong(resultSet.getColumnIndex('id'));
          const taskDetail = resultSet.getString(resultSet.getColumnIndex('taskDetail'));
          const selected = resultSet.getLong(resultSet.getColumnIndex('selected'));
          const todoItem = new TodoItemData(taskDetail, !!selected, id);
          todoItem.toDoItemSendable.state = 1;
          todoItem.state = 1
          todoList.push(todoItem);
        }
      } catch (err) {
        const error = err as BusinessError;
        hilog.info(0x0000, 'RDB', `error processing result, code:${error.code}, message:${error.message}`);
      } finally {
        try {
          resultSet.close();
        } catch (err) {
          const error = err as BusinessError;
          hilog.info(0x0000, 'RDB', `resultSet close failed, code:${error.code}, message:${error.message}`);
        }
      }
    }
    return todoList;
  }

  public inset(data: ToDoItemSendable) {
    const valueBucket: relationalStore.ValuesBucket = {
      'id': data.id,
      'taskDetail': data.detail,
      'selected': data.selected ? 1 : 0
    };
    this.store?.insert('TodoList', valueBucket, (err: BusinessError, rowId: number) => {
      if (err) {
        hilog.error(0x0000, 'RDB', `Failed to insert data. Code:${err.code}, message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'RDB', `Succeeded in inserting data. rowId:${rowId}`);
    });
  }

  public update(data: ToDoItemSendable) {
    let predicates = new relationalStore.RdbPredicates(this.tableName);
    predicates.equalTo('id', data.id);
    const valueBucket: relationalStore.ValuesBucket = {
      'id': data.id,
      'taskDetail': data.detail,
      'selected': data.selected ? 1 : 0
    };
    this.store?.update(valueBucket, predicates, (err: BusinessError, rows: number) => {
      if (err) {
        hilog.error(0x0000, 'RDB', `Failed to update data. Code:${err.code}, message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'RDB', `Update rows: ${rows}`);
    });
  }

  public delete(data: number) {
    let predicates = new relationalStore.RdbPredicates(this.tableName);
    predicates.equalTo('id', data);
    this.store?.delete(predicates, (err: BusinessError, rows: number) => {
      if (err) {
        hilog.error(0x0000, 'RDB', `Failed to delete data. Code:${err.code}, message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'RDB', `Delete rows: ${rows}`);
    });
  }
};