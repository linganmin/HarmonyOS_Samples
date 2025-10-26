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

import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { buffer } from "@kit.ArkTS";
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';

const TAG = 'SetUp';

export default class SetUp {
  // [Start InitTable]
  storeName: string = "testmail_store.db";
  // keep same with the db name in knowledge_schema.json
  storeConfig: relationalStore.StoreConfig = {
    name: this.storeName,
    securityLevel: relationalStore.SecurityLevel.S3,
    tokenizer: relationalStore.Tokenizer.CUSTOM_TOKENIZER,
    enableSemanticIndex: true
  };
  store: relationalStore.RdbStore | null = null;
  dataIndexNow = 0;

  async InitTable() {
    try {
      let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
      if (!this.store) {
        this.store = await relationalStore.getRdbStore(context, this.storeConfig);
      }
      if (this.store != undefined) {
        const createTableSql =
          "CREATE TABLE IF NOT EXISTS email(id integer primary key, subject text, content text, image_text text," +
            " attachment_names text, inlineFiles text, sender text, toReceivers text, ccReceivers text, " +
            "bccReceivers text, received_date text);";
        await this.store.execute(createTableSql, 0, undefined);
        await this.InsertData(context);
      }
    } catch (e) {
      hilog.error(0, TAG, `Init DB failed, code is ${e.code},message is ${e.message}.`);
    }
  }

  // [End InitTable]

  // [Start InsertData]
  async InsertData(context: common.UIAbilityContext) {
    // [StartExclude InsertData]
    if (!this.store) {
      try {
        this.store = await relationalStore.getRdbStore(context, this.storeConfig);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `getRdbStore failed, error code=${err.code}, message=${err.message}`);
      }
    }
    if (!this.store) {
      return;
    }
    // [EndExclude InsertData]
    let fileList: string[] = [];
    try {
      fileList = context.resourceManager.getRawFileListSync('');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getRawFileListSync failed, error code=${err.code}, message=${err.message}`);
    }
    let dataIndex = this.dataIndexNow;
    for (let file of fileList) {
      // [StartExclude InsertData]
      if (!file.startsWith('sourceData') || !file.endsWith('.json')) {
        hilog.info(0, TAG, `file ${file} skip`);
        continue;
      }
      hilog.info(0, TAG, `file ${file} start`);
      // [EndExclude InsertData]
      try {
        const rawFileData = await context.resourceManager.getRawFileContent(file);
        const fileData: string = buffer.from(rawFileData).toString();
        const resultObjArr = JSON.parse(fileData) as Array<object>;
        let jsonObj: object | undefined;
        for (let i = 0; i < resultObjArr.length; i++) {
          jsonObj = resultObjArr[i];
          dataIndex = await this.InsertSingleDataJson(jsonObj, this.store, dataIndex)
        }
      } catch (e) {
        hilog.error(0, TAG, `Load file failed, code is ${e.code},message is ${e.message}`);
      }
    }
    this.dataIndexNow = dataIndex;
  }

  // [End InsertData]

  async InsertSingleDataJson(jsonObj: object, store: relationalStore.RdbStore, indexInput: number) {
    try {
      let dataIndex = indexInput;
      let sender: string = jsonObj?.["sender_name"];
      if (!sender || sender.length === 0) {
        sender = 'undefined';
      }
      const toReceiverStr: string = JSON.stringify(jsonObj["to"]);
      const ccReceiverStr: string = JSON.stringify(jsonObj["cc"]);
      const bccReceiverStr: string = JSON.stringify(jsonObj["bcc"]);
      const time: string = jsonObj?.["received_time"];
      const formattedDateStr = time.replace(' ', 'T');
      let received_date = Date.parse(formattedDateStr);
      if (!received_date || Number.isNaN(received_date)) {
        received_date = 0;
      }
      let subject: string = jsonObj?.["subject"];
      let doc: string = jsonObj?.["body"];
      let imgContent: string = jsonObj?.["img_content"]
      let attachmentPath: string = jsonObj?.["attachment_path"]
      subject = subject.replace(/'/g, '');
      doc = doc.replace(/'/g, '');
      let sql =
        `insert or replace into email VALUES(${dataIndex}, '${subject}', '${doc}', '${imgContent}', '', '', '${sender}', '${toReceiverStr}','${ccReceiverStr}','${bccReceiverStr}','${attachmentPath}', '${received_date}');`
      hilog.debug(0, TAG, `index:${dataIndex}, sql: ${sql}`);
      await store.executeSql(sql);
      dataIndex++;
      return dataIndex;
    } catch (e) {
      hilog.error(0, TAG, `Insert failed, code is ${e.code},message is ${e.message}, jsonObj: ${jsonObj}`);
      return indexInput;
    }
  }

  async InsertSingleData(senderInput: string, toRecipients: Array<string>, ccRecipients: Array<string>,
    bccRecipients: Array<string>, subjectInput: string, docInput: string, context: common.UIAbilityContext) {
    if (!this.store) {
      try {
        this.store = await relationalStore.getRdbStore(context, this.storeConfig);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `getRdbStore failed, error code=${err.code}, message=${err.message}`);
      }
    }
    if (!this.store) {
      return;
    }

    try {
      let sender: string = senderInput;
      if (!sender || sender.length === 0) {
        sender = 'undefined';
      }
      const toReceiverStr: string = JSON.stringify(toRecipients);
      const ccReceiverStr: string = JSON.stringify(ccRecipients);
      const bccReceiverStr: string = JSON.stringify(bccRecipients);
      const received_date = systemDateTime.getTime(false); // time conversion
      let subject: string = subjectInput;
      let doc: string = docInput;
      let imgContent: string = '';
      subject = subject.replace(/'/g, '');
      doc = doc.replace(/'/g, '');
      let sql =
        `insert or replace into email VALUES(${this.dataIndexNow}, '${subject}', '${doc}', '${imgContent}', '', '', '${sender}', '${toReceiverStr}','${ccReceiverStr}','${bccReceiverStr}','' , '${received_date}');`
      hilog.debug(0, TAG, `index:${this.dataIndexNow}, sql: ${sql}`);
      this.dataIndexNow++;
      await this.store.executeSql(sql);
    } catch (e) {
      hilog.error(0, TAG, `Insert failed, code is ${e.code},message is ${e.message}`);
    }
    hilog.info(0, TAG, "insertSingleData end");

  }

  async closeStore() {
    if (!this.store) {
      return;
    }
    try {
      await this.store.close();
    } catch (e) {
      hilog.error(0, TAG, `Close store failed, code is ${e.code},message is ${e.message}.`);
    }
  }
}