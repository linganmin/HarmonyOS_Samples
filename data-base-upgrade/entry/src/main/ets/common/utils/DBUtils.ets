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

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from "@kit.BasicServicesKit";
import { User } from '../../viewmodel/UserInfo';
import { CommonConstants } from '../constants/CommonConstants';
import Logger from './Logger';

let store: relationalStore.RdbStore | undefined = undefined;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: "RdbTest.db",
  securityLevel: relationalStore.SecurityLevel.S1
};
const COLUMN_TYPE_MAP = [
  ['username', 'varchar(30)'],
  ['account', 'varchar(30)'],
  ['nickname', 'varchar(30)'],
  ['age', 'varchar(30)']
];

export class DBUtils {
  /**
   * Creating a User Table.
   */
  createDB() {
    relationalStore.getRdbStore(uiContext?.getHostContext(), STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      store = rdbStore;
      if (store !== undefined) {
        (store as relationalStore.RdbStore).executeSql(CommonConstants.SQL_CREATE_USER_TABLE, (err) => {
          if (err) {
            Logger.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
            return;
          }
          Logger.info('create table done.');
          this.insertData();
        })
      }
    })
  }

  /**
   * Initializing User Table Data.
   */
  insertData() {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).executeSql(CommonConstants.SQL_INIT_USER_TABLE).then(() => {
        Logger.info('insert data table done.');
      }).catch((err: BusinessError) => {
        Logger.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  /**
   * Querying User Table Information.
   */
  async queryData(flags: number[]): Promise<User> {
    let res: User = new User();
    if (store !== undefined) {
      (store as relationalStore.RdbStore).querySql(CommonConstants.SQL_QUERY_USER_TABLE, (err, resultSet) => {
        if (err) {
          Logger.error(`Query failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        Logger.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
        try {
          while (resultSet.goToNextRow()) {
            let id = resultSet.getString(resultSet.getColumnIndex("id"));
            res.setId(id);
            let name = '';
            let account = ''
            let nickname = '';
            let age = '';
            try {
              if (flags[0] > 0) {
                name = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[0][0]));
                res.setName(name);
              }
              if (flags[1] > 0) {
                account = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[1][0]));
                res.setAccount(account);
              }
              if (flags[2] > 0) {
                nickname = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[2][0]));
                res.setNickName(nickname);
              }
              if (flags[3] > 0) {
                age = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[3][0]));
                res.setAge(age);
              }
            } catch (error) {
              Logger.error(`ExecuteSql failed, code is ${error.code},message is ${error.message}`);
              resultSet.close();
              return res;
            }
            resultSet.close();
            return res;
          }
        } catch (error) {
          let err = error as BusinessError;
          Logger.error('goToNextRow failed,'+ ` code is ${err.code}, message is ${err.message}`);
        }
        try {
          resultSet.close();
        } catch (error) {
          let err = error as BusinessError;
          Logger.error('close failed,'+ ` code is ${err.code}, message is ${err.message}`);
        }
        return res;
      })
    }
    return res;
  }

  /**
   * Modifying the User Table Information.
   */
  updateData(index: number, content: string) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).executeSql("update user_info set " +
      COLUMN_TYPE_MAP[index][0] + " = '" + content + "' where id = 1")
        .then(() => {
          Logger.info('update data done.');
        })
        .catch((err: BusinessError) => {
          Logger.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
        })
    }
  }

  /**
   * Used for database transactional rollback.
   */
  rollback() {
    if (store !== undefined) {
      try {
        store.rollBack();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error('rollBack failed,'+ ` code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  /**
   * Used to commit database transactions.
   */
  commit() {
    if (store !== undefined) {
      try {
        store.commit();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error('commit failed,'+ ` code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  /**
   * Modifying the User Table Structure.
   */
  async updateTable(index: number, content: string) {
    let updateTableSql = "alter table user_info add column " +
      COLUMN_TYPE_MAP[index][0] + " " + COLUMN_TYPE_MAP[index][1];
    if (store !== undefined) {
      try {
        store.beginTransaction();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error('beginTransaction failed,'+ ` code is ${err.code}, message is ${err.message}`);
      }
      (store as relationalStore.RdbStore).executeSql(updateTableSql, (err) => {
        if (err) {
          Logger.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        Logger.info('update table done.');
        this.updateData(index, content);
      })
    }
  }

  /**
   * Modifying the User Table Information.
   */
  async backup(callback: () => void) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).backup('dbBackup.db', (err) => {
        if (err) {
          Logger.error(`Failed to backup data. Code:${err.code},message:${err.message}`);
          return;
        }
        Logger.info('Succeeded in backuping data.');
        callback();
      })
    }
  }

  /**
   * Modifying the User Table Information.
   */
  async restore(callback: () => void) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).restore('dbBackup.db', (err) => {
        if (err) {
          Logger.error(`Failed to restore data. Code:${err.code},message:${err.message}`);
          return;
        }
        Logger.info('Succeeded in restoring data.');
        callback();
      })
    }
  }
}

let dbUtils = new DBUtils();

export default dbUtils as DBUtils;