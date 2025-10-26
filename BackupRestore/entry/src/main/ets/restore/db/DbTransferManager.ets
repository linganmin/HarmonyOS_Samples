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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { fileIo } from '@kit.CoreFileKit';

/**
 * DB file migration and conversion management
 */
export default class DbTransferManager {
  private sourceRdbStore?: relationalStore.RdbStore;
  private targetRdbStore?: relationalStore.RdbStore;

  /**
   * Database migration from HarmonyOS 4.0 to HarmonyOS NEXT.
   * eg:
   *  The db file name for HarmonyOS 4.0 is:
   *    source_deb.db, which contains the table 'user'.
   *    The 'user' field contains fields such as' id ',' integer ',' username ', and' string '.
   *  The db file name for HarmonyOS NEXT is target_deb.db, which contains the table 't_user'.
   *  The table 't_user' contains fields such as' id integer ',' source_id integer ', and' name string '.
   *
   * @param context context.
   */
  async transfer(context: common.Context): Promise<void> {
    // Step 1: Move the db file.
    let result = this.moveDbFile(context);
    if (!result) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', 'moveDbFile failed');
      return;
    }

    // Step 2: query the number of data entries in the user table of the dual database for pagination queries.
    let count = await this.querySourceUserCount(context);

    const PAGE_SIZE = 10;
    let pages = Math.ceil(count / PAGE_SIZE);
    for (let curPage = 1; curPage <= pages; curPage++) {
      // Step 3: pagination query, query data from the dual db table.
      let valuesBucketResults = await this.querySourceUserForPage(context, PAGE_SIZE, PAGE_SIZE * (curPage - 1));

      // Step 4: Batch Insertion: Insert the data from the double db table found in the query into the single db.
      let result = await this.batchInsertToTargetUser(context, valuesBucketResults);
      hilog.info(0x0000, 'BackupRestore DbTransferManager', `batchInsertTargetUser result = ${result}`);
    }

    // Step 5: Retrieve data from the new database.
    let valuesBuckets = await this.queryAllFromTargetUser(context);
    valuesBuckets.forEach(valuesBucket => {
      hilog.info(0x0000, 'BackupRestore DbTransferManager', `queryAllFromTargetUser k-v = ${JSON.stringify(valuesBucket)}`);
    })
  }

  /**
   * Migrating HarmonyOS 4.0 database files to HarmonyOS NEXT.
   *
   * @param context context.
   * @return success return true, failed return false.
   */
  private moveDbFile(context: common.Context): boolean {
    try {
      // The database defaults to the databases directory.
      let sourceDbPath: string = '/data/storage/el2/backup/restore/com.example.backuprestore/ce/databases';
      if (!fileIo.accessSync(sourceDbPath)) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', `moveDbFile, ${sourceDbPath} can't access`);
        return false;
      }
      // Obtain all files and directories under the source path.
      let listFileNames: string[] = fileIo.listFileSync(sourceDbPath);
      if (!listFileNames || listFileNames.length === 0) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', `moveDbFile, ${sourceDbPath} is not file`);
        return false;
      }

      let targetPath: string = context.databaseDir + '/rdb';
      // If the target directory does not exist, it needs to be created.
      if (!fileIo.accessSync(targetPath)) {
        fileIo.mkdirSync(targetPath);
      }

      // Traverse files or directories under the source path and move them.
      listFileNames.forEach((fileName: string) => {
        let srcPath = `${sourceDbPath}/${fileName}`;
        let destPath = `${targetPath}/${fileName}`;
        if (fileIo.statSync(srcPath).isFile()) {
          fileIo.moveFileSync(srcPath, destPath);
        } else {
          fileIo.moveDirSync(srcPath, targetPath);
        }
      });
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `moveDbFile, error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Initialize the rdbStore of the database.
   *
   * @param context context.
   * @return success return true, failed return false.
   */
  private async initSourceDb(context: common.Context): Promise<boolean> {
    if (this.sourceRdbStore) {
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'initSourceDb, sourceRdbStore has been initialized');
      return true;
    }

    try {
      const SOURCE_CONFIG: relationalStore.StoreConfig = {
        // HarmonyOS 4.0 database name, modify according to the actual name.
        name: 'source_db.db',
        // The security level of the database, S1 represents low level, specified according to the actual situation.
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.sourceRdbStore = await relationalStore.getRdbStore(context, SOURCE_CONFIG);
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'initSourceDb, success');
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `initSourceDb, error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Initialize the rdbStore of the database.
   *
   * @param context context.
   * @return success return true, failed return false.
   */
  private async initTargetDb(context: common.Context): Promise<boolean> {
    if (this.targetRdbStore) {
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'initTargetDb, targetRdbStore has been initialized');
      return true;
    }

    try {
      const TARGET_CONFIG: relationalStore.StoreConfig = {
        name: 'target_db.db',
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.targetRdbStore = await relationalStore.getRdbStore(context, TARGET_CONFIG);

      // Create tables based on actual needs
      let createSql = `CREATE TABLE IF NOT EXISTS t_user (
                        id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
                        source_id integer,
                        name varchar(128)
                      )`;
      await this.targetRdbStore.executeSql(createSql);
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'initTargetDb, success');
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `initTargetDb error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Query the number of data entries in the user table of HarmonyOS 4.0.
   *
   * @param context context.
   * @return count.
   */
  private async querySourceUserCount(context: common.Context): Promise<number> {
    let count = 0;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      if (!await this.initSourceDb(context)) {
        return count;
      }
      let queryColumn = ['count(1)'];
      let predicatesInfo = new relationalStore.RdbPredicates('user');
      resultSet = await this.sourceRdbStore?.query(predicatesInfo, queryColumn);
      if (!resultSet || !resultSet.goToFirstRow()) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', 'querySourceUserCount, resultSet is empty');
        return count;
      }
      count = resultSet.getLong(0);
      hilog.info(0x0000, 'BackupRestore DbTransferManager', `querySourceUserCount, success count: ${count}`);
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `querySourceUserCount, error: ${JSON.stringify(error)}`);
    } finally {
      try {
        resultSet?.close();
      } catch (e) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', `close, error: ${JSON.stringify(e)}`);
      }
    }
    return count;
  }

  /**
   * Page wise query of data in the user table of the database.
   *
   * @param context context.
   * @param pageSize pageSize.
   * @param offset total offset.
   * @return ValuesBucket[] Contains data queried from the database.
   */
  private async querySourceUserForPage(context: common.Context, pageSize: number, offset: number): Promise<ValuesBucket[]> {
    let valuesBucketResults: ValuesBucket[] = [];
    if (!await this.initSourceDb(context)) {
      return valuesBucketResults;
    }

    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let queryColumns = ['id', 'username'];
      let predicatesInfo = new relationalStore.RdbPredicates('user')
        .orderByAsc('id')
        .limitAs(pageSize)
        .offsetAs(offset);
      resultSet = await this.sourceRdbStore?.query(predicatesInfo, queryColumns);
      if (!resultSet || !resultSet.goToFirstRow()) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', 'querySourceUserForPage, resultSet is empty');
        return valuesBucketResults;
      }

      do {
        let id = resultSet.getLong(resultSet.getColumnIndex('id'));
        let username = resultSet.getString(resultSet.getColumnIndex('username'));
        let valuesBucket: ValuesBucket = {
          'source_id': id,
          'name': username
        };
        hilog.info(0x0000, 'BackupRestore DbTransferManager', `querySourceUserInfo, k-v : ${JSON.stringify(valuesBucket)}`);
        valuesBucketResults.push(valuesBucket);
      } while (resultSet.goToNextRow());
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'querySourceUserInfo, success');
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `querySourceUserInfo, error: ${JSON.stringify(error)}`);
    } finally {
      try {
        resultSet?.close();
      } catch (e) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', `close, error: ${JSON.stringify(e)}`);
      }
    }
    return valuesBucketResults;
  }

  /**
   * Batch inserting data into the database.
   *
   * @param context context.
   * @param valuesBuckets Contains data to be inserted.
   * @return Number of insertions, failure returns -1.
   */
  private async batchInsertToTargetUser(context: common.Context, valuesBuckets: ValuesBucket[]): Promise<number> {
    if (!await this.initTargetDb(context)) {
      return -1;
    }
    try {
      let result = await this.targetRdbStore?.batchInsert('t_user', valuesBuckets);
      return result ? result : -1;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `batchInsertToTargetUser, error: ${JSON.stringify(error)}`);
    }
    return -1;
  }

  /**
   * Query all data in the t_user table of the database.
   *
   * @param context context.
   * @return ValuesBucket[] Query results.
   */
  public async queryAllFromTargetUser(context: Context): Promise<ValuesBucket[]> {
    let valuesBucketResults: ValuesBucket[] = [];
    if (!await this.initTargetDb(context)) {
      return valuesBucketResults;
    }

    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let queryColumns = ['id', 'source_id', 'name'];
      let predicatesInfo = new relationalStore.RdbPredicates('t_user');
      resultSet = await this.targetRdbStore?.query(predicatesInfo, queryColumns);
      if (!resultSet || !resultSet.goToFirstRow()) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', 'queryAllFromTargetUser, resultSet is empty');
        return valuesBucketResults;
      }

      do {
        let id = resultSet.getLong(resultSet.getColumnIndex('id'));
        let did = resultSet.getLong(resultSet.getColumnIndex('source_id'));
        let name = resultSet.getString(resultSet.getColumnIndex('name'));
        let valuesBucket: ValuesBucket = {
          'id': id,
          'source_id': did,
          'name': name
        };
        valuesBucketResults.push(valuesBucket);
      } while (resultSet.goToNextRow());
      hilog.info(0x0000, 'BackupRestore DbTransferManager', 'queryAllFromTargetUser, success');
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore DbTransferManager', `queryAllFromTargetUser, error: ${JSON.stringify(error)}`);
    } finally {
      try {
        resultSet?.close();
      } catch (e) {
        hilog.error(0x0000, 'BackupRestore DbTransferManager', `close, error: ${JSON.stringify(e)}`);
      }
    }
    return valuesBucketResults;
  }
}