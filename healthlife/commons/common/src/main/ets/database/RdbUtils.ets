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
import { RdbConstants } from '../constants/RdbConstants';

// hilog tag.
const TAG: string = 'RdbUtils';

class RdbUtils {
  // database connection instance.
  rdbStore?: relationalStore.RdbStore;

  /**
   * The method of creating an RDBStore Instance.
   */
  async createRdb(context: Context): Promise<void> {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: RdbConstants.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    await relationalStore.getRdbStore(context, STORE_CONFIG).then((rdbStore: relationalStore.RdbStore) => {
      this.rdbStore = rdbStore;
      hilog.info(0x0000, TAG, 'Get RdbStore successfully.');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Get RdbStore failed, code is ${err.code},message is ${err.message}`);
    });
  }

  /**
   * The method of creating a table.
   * @param { string } tableName the table name that needs to be created
   */
  createTable(tableName: string): void {
    if (!this.rdbStore) {
      hilog.error(0x0000, TAG, 'RdbStore is undefined');
      return;
    }
    let createSql = this.generateTableSql(tableName);
    this.rdbStore.execute(createSql)
      .then(() => {
        hilog.info(0x0000, TAG, `Execute create ${tableName} table sql success`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Execute create ${tableName} table sql failed, code is ${err.code},message is ${err.message}`);
      });
  }

  /**
   * generate a SQL statement for creating a new table based on the table name
   * @param { string } tableName the table name that needs to be created
   * @returns { string } the generated SQL statement
   */
  private generateTableSql(tableName: string): string {
    let columns = RdbConstants.TABLE_COLUMNS_MAPPING[tableName];
    let sql = `create table if not exists ${tableName}(`;
    for (let column of columns) {
      sql = sql.concat(`${column.name} ${column.type}`);
      sql = sql.concat(`${column.length && column.length > 0 ? `(${column.length})` : ''}`);
      sql = sql.concat(`${column.primary ? ' primary key' : ''}`);
      sql = sql.concat(`${column.autoincrement ? ' autoincrement' : ''}`);
      sql = sql.concat(`${column.nullable ? '' : ' not null'}`);
      sql = sql.concat(', ');
    }
    sql = `${sql.substring(0, sql.length - 2)})`;
    hilog.info(0x0000, TAG, `The SQL statement generated based on the ${tableName} is '${sql}'`);
    return sql;
  }

  /**
   * The method of execute sql.
   * @param { string } executeSql the sql statement that needs to be executed.
   * @returns { Promise<boolean> } returns whether the execution was successful.
   */
  async executeSql(executeSql: string): Promise<boolean> {
    let result = true;
    await this.rdbStore?.executeSql(executeSql).then(() => {
      hilog.info(0x0000, TAG, `Execute Sql is successful, sql is ${executeSql}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Execute Sql is failed, sql is ${executeSql}, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  /**
   * The method of creating an RDBStore Instance.
   */
  async closeRdb(): Promise<void> {
    if (this.rdbStore) {
      this.rdbStore.close().then(() => {
        hilog.info(0x0000, TAG, 'Close RdbStore successfully.');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Close RdbStore failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }
}

export default new RdbUtils();