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
* FAQ:如何通过谓词查询方式获取数据
*/

// [Start read_the_local_database]
import { BusinessError } from '@kit.BasicServicesKit';
import { distributedKVStore } from '@kit.ArkData';

let kvStore: undefined | distributedKVStore.SingleKVStore = undefined;

@Entry
@Component
export struct ReadingTheLocalDatabase {
  build() {
    Row() {
      Column({ space: 20 }) {
        Button('Create database')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .onClick(async () => {
            try {
              let name = new distributedKVStore.FieldNode('name'); // Create FieldNode
              name.type = distributedKVStore.ValueType.STRING; // Set NodeType string
              name.nullable = false; // NodeData is not null
              name.default = 'cake'; // Default

              let schema1 = new distributedKVStore.Schema(); // Create Schema
              schema1.root.appendChild(name); // add Child name
              schema1.indexes = ['$.name'];
              // Create KVManager
              let kvManager = distributedKVStore.createKVManager({
                bundleName: 'TEST_CRASH_APP',
                context: this.getUIContext().getHostContext()
              });
              // Create database 
              await kvManager.getKVStore('storeIds', {
                createIfMissing: true,
                backup: false,
                encrypt: false,
                autoSync: false,
                schema: schema1,
                kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
                securityLevel: distributedKVStore.SecurityLevel.S2
              }).then((store: distributedKVStore.SingleKVStore) => {
                kvStore = store;
              }).catch((err: BusinessError) => {
                console.info(`getKVStore error is: ${err.code}, msg is: ${err.message}`);
              })
              if (kvStore === undefined) {
                return;
              }
              let entries: distributedKVStore.Entry[] = [];
              for (let i = 0; i < 10; i++) {
                let ent: distributedKVStore.Entry = {
                  key: 'test' + i,
                  value: {
                    type: distributedKVStore.ValueType.STRING,
                    value: '{"name":"cake"}'
                  }
                }
                entries.push(ent);
              }
              // insert data 
              kvStore.putBatch(entries)
                .then((data) => {
                  console.info('Succeeded in putting Batch');
                })
                .catch((err: BusinessError) => {
                  console.info(`putBatch error is: ${err.code}, msg is: ${err.message}`);
                })
            } catch (e) {
              console.info(`putBatch e is: ${e.code}, msg is: ${e.message}`);
            }
          })

        Button('like select')
          .fontSize(20)
          .onClick(() => {
            try {
              if (kvStore === undefined) {
                return;
              }
              // Use predicates to query a specified field that has a value similar to the specified string, and obtain a list of key value pairs that match the specified Query object
              kvStore.getEntries(new distributedKVStore.Query().like('$.name', 'c%'))
                .then((value) => {
                  for (let i = 0; i < value.length; i++) {
                    console.info('key:' + value[i].key + 'value : ' + JSON.stringify(value[i].value))
                  }
                })
                .catch((err: BusinessError) => {
                  console.info(`getEntries error is: ${err.code}, msg is: ${err.message}`);
                })
            } catch (e) {
              console.info(`getEntries e is: ${e.code}, msg is: ${e.message}`);
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End read_the_local_database]