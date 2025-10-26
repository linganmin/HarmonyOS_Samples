/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何读取本地/预制数据库
*/

// [Start init_rdb]
import { fileIo } from '@kit.CoreFileKit';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Obtaining the Context in EntryAbility, save it to AppStorage, then use AppStorage to retrieve it in the utility class.
let context = AppStorage.get('context') as UIContext;
let UiAbilityContent = context.getHostContext() as common.UIAbilityContext;
let RDBDirectory = UiAbilityContent.databaseDir;
let resource = UiAbilityContent.resourceManager;

function initDatabase() {
  // Create a database sandbox directory
  try {
    let dirPath = RDBDirectory + '/entry';
    fileIo.mkdirSync(dirPath);
    dirPath = dirPath + '/rdb';
    fileIo.mkdirSync(dirPath);
  } catch (error) {
    console.error(`mkdir rdbPath failed, error code: ${error.code}, message: ${error.message}.`);
  }

  // Set db name
  let dbName: string = 'Objective.db';

  // Read the db file in the rawfile directory
  try {
    let content = resource.getRawFileContentSync(dbName);
    let cFile = RDBDirectory + '/entry/rdb/' + dbName;
    let cacheFile = fileIo.openSync(cFile, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.write(cacheFile.fd, content.buffer);
    fileIo.closeSync(cacheFile.fd);
  } catch (error) {
    console.error(`callback getRawFd failed, error code: ${error.code}, message: ${error.message}.`);
  }
}

// [End init_rdb]

// [Start get_rdb]
async function getRDB(): Promise<relationalStore.RdbStore | undefined> {
  let result: relationalStore.RdbStore | undefined = undefined;
  const STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'Objective.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  await relationalStore.getRdbStore(UiAbilityContent, STORE_CONFIG).then((rdbStore: relationalStore.RdbStore) => {
    result = rdbStore;
    console.info('Get RdbStore successfully.');
  }).catch((err: BusinessError) => {
    console.error(`Get RdbStore failed, code is ${err.code}, message is ${err.message}`);
  });
  return result;
}

// [End get_rdb]

@Entry
@Component
struct LocalDatabaseReader {
  private rdb: relationalStore.RdbStore | undefined = undefined;

  aboutToAppear(): void {
    initDatabase();
  }

  build() {
    Column() {
      Button('getRdb')
        .onClick(() => {
          getRDB().then((res) => {
            this.rdb = res;
          })
        })
    }
  }
}