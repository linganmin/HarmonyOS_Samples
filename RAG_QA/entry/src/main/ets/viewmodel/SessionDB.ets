/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import data_relationalStore from '@ohos.data.relationalStore'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const CREATE_TABLE =
  "CREATE TABLE IF NOT EXISTS session_history (id INTEGER PRIMARY KEY AUTOINCREMENT, sender_id INTEGER, message " +
    "TEXT NOT NULL)";

const TAG = "SessionDB";

enum Sender {
  Robot = 1,
  User
}

class Message {
  sender: Sender
  content: string

  constructor(sender: Sender, content: string) {
    this.sender = sender;
    this.content = content;
  }
}

export class SessionDB {
  store?: data_relationalStore.RdbStore;
  isInitialized: boolean = false;
  config: data_relationalStore.StoreConfig = {
    name: "Session.db",
    securityLevel: data_relationalStore.SecurityLevel.S1,
    encrypt: false,
    autoCleanDirtyData: false,
  };

  async deleteRdbStore() {
    if (this.store === undefined) {
      try {
        let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
        await data_relationalStore.deleteRdbStore(context, this.config);
        hilog.info(0, TAG, "deleteRdbStore ok");
      } catch (err) {
        hilog.error(0, TAG, `deleteRdbStore failed. code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  async getRdbStore() {
    if (this.store === undefined) {
      try {
        let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
        this.store = await data_relationalStore.getRdbStore(context, this.config);
        hilog.info(0, TAG, "getRdbStore ok");
      } catch (err) {
        hilog.error(0, TAG, `getRdbStore failed. code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  async createTable() {
    if (this.store === undefined) {
      hilog.info(0, TAG, "store is null");
      return;
    }
    try {
      await this.store.execute(CREATE_TABLE)
      hilog.info(0, TAG, "createTable ok");
    } catch (err) {
      hilog.error(0, TAG, `createTable failed. code is ${err.code}, message is ${err.message}`);
    }
  }

  async insertMessage(senderId: number, message: string) {
    if (this.store === undefined) {
      hilog.info(0, TAG, "store is null");
      return;
    }
    let insertSql = `insert into session_history (sender_id, message) values (${senderId}, '${message}')`;
    try {
      await this.store!.execute(insertSql);
      hilog.info(0, TAG, "insertMessage ok, sql: %{public}s", insertSql);
    } catch (err) {
      hilog.error(0, TAG, `insertMessage failed. code is ${err.code}, message is ${err.message}. sql: ${insertSql}}`);
      return;
    }
  }

  IsInitialized() {
    return this.isInitialized;
  }

  async init() {
    hilog.info(0, TAG, "db init");
    await this.getRdbStore();
    await this.createTable();
  }

  // searching all history
  async selectHistoryMessage() {
    // searching all history by time asc
    let selectSql =
      `select sender_id, message from session_history order by id ASC;`
    // format the result
    let result: Array<Message> = [];

    try {
      // record the searching result
      if (this.store === undefined) {
        await this.init();
      }
      let resultSet = await this.store!.querySql(selectSql)
      let index = 0; // array index
      while (resultSet.goToNextRow()) {
        let sender = resultSet.getLong(0)
        let message = resultSet.getString(1)
        result[index++] = new Message(sender, message)
      }
      hilog.info(0, TAG, "select , length: %{public}d", result.length);
    } catch (err) {
      hilog.error(0, TAG, `select failed. code is ${err.code}, message is ${err.message}`);
    }
    return result
  }

  // clear all history
  async clearHistoryMessage() {
    if (this.store === undefined) {
      let clearSql = `delete from session_history;`
      try {
        await this.store!.execute(clearSql);
        hilog.info(0, TAG, "delete , sql: %{public}s", clearSql);
      } catch (err) {
        hilog.error(0, TAG, `delete failed. code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}