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

import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { distributedKVStore, preferences, relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { File } from '../view/File';
import Logger from '../common/Logger';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private dataPreferences: preferences.Preferences | null = null;
  private kvManager: distributedKVStore.KVManager | undefined = undefined;
  private context = this.getUIContext().getHostContext()!

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.tab1'))
        .width(328)
        .height(40)
        .margin({ left: '16' })
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }.alignItems(HorizontalAlign.Start)
  }

  @Builder
  PageMap(name: string) {
    if (name === 'fileList') {
      File()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button($r('app.string.tab2'))
          .width(328)
          .height(40)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            try {
              let filesDir = context.filesDir;
              let file = fs.openSync(filesDir + '/test.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
              let writeLen = fs.writeSync(file.fd, 'Try to write str.');
              Logger.info('The Length of str is: ' + writeLen);
              let arrayBuffer = new ArrayBuffer(1024);
              let readOptions: ReadOptions = {
                offset: 0,
                length: arrayBuffer.byteLength
              };
              let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
              let buf = buffer.from(arrayBuffer, 0, readLen);
              Logger.info('the content of file: ' + buf.toString());
              fs.closeSync(file);
            } catch (e) {
              Logger.error(`file error ${JSON.stringify(e)}`);
            }

            try {
              let options2: preferences.Options = { name: 'myStore' };
              this.dataPreferences = preferences.getPreferencesSync(this.context, options2);
              if (this.dataPreferences.hasSync('startup')) {
                Logger.info('The key "startup" is contained.');
              } else {
                Logger.info('The key "startup" does not contain.');
                this.dataPreferences.putSync('startup', 'auto');
                this.dataPreferences.flush((err: BusinessError) => {
                  if (err) {
                    Logger.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
                    return;
                  }
                  Logger.info('Succeeded in flushing.');
                })
              }
            } catch (e) {
              Logger.error(`preferences error ${JSON.stringify(e)}`);
            }

            const kvManagerConfig: distributedKVStore.KVManagerConfig = {
              context: this.context,
              bundleName: 'com.example.myapplication'
            };
            this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
            let kvStore: distributedKVStore.SingleKVStore | undefined = undefined;
            const options: distributedKVStore.Options = {
              createIfMissing: true,
              encrypt: false,
              backup: false,
              autoSync: false,
              kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
              securityLevel: distributedKVStore.SecurityLevel.S1
            };
            this.kvManager!.getKVStore<distributedKVStore.SingleKVStore>('storeId', options,
              (err, store: distributedKVStore.SingleKVStore) => {
                if (err) {
                  Logger.error(`Failed to get KVStore: Code:${err.code},message:${err.message}`);
                  return;
                }
                Logger.info('Succeeded in getting KVStore.');
                kvStore = store;
                kvStore.put('test', 'test1').catch((error: BusinessError) => {
                  Logger.error(`put error ${error.code}`);
                });
              });

            const STORE_CONFIG: relationalStore.StoreConfig = {
              name: 'RdbTest.db',
              securityLevel: relationalStore.SecurityLevel.S3,
              encrypt: false,
              customDir: 'customDir/subCustomDir'
            };
            const SQL_CREATE_TABLE =
              'CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, SALARY REAL, CODES BLOB, IDENTITY UNLIMITED INT)';

            relationalStore.getRdbStore(this.context, STORE_CONFIG, (err, store) => {
              if (err) {
                Logger.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
                return;
              }
              Logger.info('Succeeded in getting RdbStore.');

              if (store.version === 0) {
                store.executeSql(SQL_CREATE_TABLE).catch((error: BusinessError) => {
                  Logger.error(`executeSql error ${error.code}`);
                });
                store.version = 3;
              }

              if (store.version === 1) {
                (store as relationalStore.RdbStore).executeSql('ALTER TABLE EMPLOYEE ADD COLUMN AGE INTEGER')
                  .catch((error: BusinessError) => {
                  Logger.error(`executeSql error ${error.code}`);
                });
                store.version = 2;
              }

              if (store.version === 2) {
                (store as relationalStore.RdbStore).executeSql('ALTER TABLE EMPLOYEE DROP COLUMN ADDRESS TEXT')
                  .catch((error: BusinessError) => {
                  Logger.error(`executeSql error ${error.code}`);
                });
                store.version = 3;
              }
            })

            try {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.message'),
                duration: 2000
              });
            } catch (error) {
              let message = (error as BusinessError).message
              let code = (error as BusinessError).code
              Logger.error(`showToast args error code is ${code}, message is ${message}`);
            }
          })
          .margin({ bottom: '12' })

        Button($r('app.string.tab3'))
          .width(328)
          .height(40)
          .margin({ bottom: '16' })
          .onClick(() => {
            this.pageInfos.pushPathByName('fileList', null);
          })

      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .navDestination(this.PageMap)
    .title(this.NavigationTitle)
    .titleMode(NavigationTitleMode.Full)
  }
}