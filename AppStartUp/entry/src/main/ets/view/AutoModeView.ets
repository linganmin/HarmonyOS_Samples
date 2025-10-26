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

import { distributedKVStore, relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { RdbStoreUtil, SingleKVStoreUtil } from '../util/SingleKVStore';
import Constants from '../common/Constants';

const TAG = 'AutoModeView';

@Component
export default struct AutoModeView {
  @StorageLink('image') image: PixelMap | undefined = undefined;
  private readonly FILE_TASK_TITLE: string = 'FileTask';
  private readonly KV_STORE_TASK_TITLE: string = 'KVStoreTask';
  private readonly RDB_STORE_TASK_TITLE: string = 'RdbStoreTask';
  private readonly RESOURCE_MANAGER_TASK_TITLE: string = 'ResourceManagerTask';
  @State fileStr: string = 'fileStr';
  @State kvStoreStr: string = 'kvStoreStr';
  @State rdbStoreStr: string = 'rdbStoreStr';

  aboutToAppear(): void {
    this.readFile();
    this.getKvStoreData();
    this.getRdbStoreData();
  }

  readFile() {
    let filesDir: string = this.getUIContext().getHostContext()!.filesDir;
    if (!filesDir) {
      hilog.error(0x0000, TAG, 'No such file or directory');
      return;
    }
    try {
      let file: fileIo.File = fileIo.openSync(filesDir + '/destFile.txt', fileIo.OpenMode.READ_WRITE);
      // Read a section of content from a file
      let arrayBuffer: ArrayBuffer = new ArrayBuffer(1024);
      let option = new Option();
      option.length = arrayBuffer.byteLength;
      let readLen = fileIo.readSync(file.fd, arrayBuffer, option);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      this.fileStr = buf.toString();
      // close file
      fileIo.closeSync(file);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `Read file failed. code=${err.code}, message=${err.message}`);
    }
  }

  getKvStoreData() {
    SingleKVStoreUtil.getKVStore()
      .then((kvStore: distributedKVStore.SingleKVStore) => {
        const KEY_TEST_STRING_ELEMENT = 'key_test_string';
        kvStore.get(KEY_TEST_STRING_ELEMENT, (err, data) => {
          if (err != undefined) {
            hilog.error(0x0000, TAG, `Failed to get data. Code:${err.code}, message:${err.message}`);
            return;
          }
          this.kvStoreStr = data as string;
          hilog.info(0x0000, TAG, `Succeeded in getting data. Data:${data}`);
        });
      }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Failed to create KVManager. message:${err}`);
    });
  }

  getRdbStoreData() {
    RdbStoreUtil.getRdbStore(this.getUIContext().getHostContext()!)
      .then((rdbStore: relationalStore.RdbStore) => {

        let predicates = new relationalStore.RdbPredicates('EMPLOYEE');
        predicates.equalTo('NAME', 'RdbStoreTask init data');

        rdbStore.query(predicates, ['ID', 'NAME', 'AGE', 'SALARY'], (err: BusinessError, resultSet) => {
          if (err) {
            hilog.error(0x0000, TAG, `Failed to query data. Code:${err.code}, message:${err.message}`);
            return;
          }
          hilog.info(0x0000, TAG,
            `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
          // ResultSet is a cursor for a dataset, which by default points to the -1st record, with valid data starting from 0.
          while (resultSet.goToNextRow()) {
            const id = resultSet.getLong(resultSet.getColumnIndex('ID'));
            const name = resultSet.getString(resultSet.getColumnIndex('NAME'));
            const age = resultSet.getLong(resultSet.getColumnIndex('AGE'));
            const salary = resultSet.getDouble(resultSet.getColumnIndex('SALARY'));
            hilog.info(0x0000, TAG, `id=${id}, name=${name}, age=${age}, salary=${salary}`);
            this.rdbStoreStr = `id=${id}, name=${name}, age=${age}, salary=${salary}`;
          }
          // Release the memory of the dataset
          resultSet.close();
        })
      }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Failed to create KVManager.message:${err}`);
    });
  }

  build() {
    Column() {
      ResultItem({
        title: this.FILE_TASK_TITLE,
        content: this.fileStr
      })
        .margin({ top: 12 })
      ResultItem({
        title: this.KV_STORE_TASK_TITLE,
        content: this.kvStoreStr
      })
        .margin({ top: 12 })
      ResultItem({
        title: this.RDB_STORE_TASK_TITLE,
        content: this.rdbStoreStr
      })
        .margin({ top: 12 })
      Column() {
        Text(this.RESOURCE_MANAGER_TASK_TITLE)
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(20)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .width(Constants.FULL_PERCENT)
        Image($r('app.media.resource_image'))
          .width(Constants.FULL_PERCENT)
          .height(200)
          .margin({ top: 8 })
          .borderRadius(15)
      }
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_PERCENT)
      .margin({ top: 36 })
    }
  }
}

@Component
export struct ResultItem {
  @Prop title: string;
  @Prop content: string;

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(20)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(Constants.FULL_PERCENT)
      Column() {
        Text(this.content)
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(22)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .width(Constants.FULL_PERCENT)
      }
      .width(Constants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
      .borderRadius(20)
      .margin({ top: 8 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_PERCENT)
  }
}

class Option {
  public offset: number = 0;
  public length: number = 0;
}