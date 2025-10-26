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

import { common, startupManager } from '@kit.AbilityKit';
import { distributedKVStore, relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'SingleKVStoreUtil';

export class SingleKVStoreUtil {
  static getKVStore(): Promise<distributedKVStore.SingleKVStore> {
    return new Promise((resolve, reject) => {
      try {
        const options: distributedKVStore.Options = {
          createIfMissing: true,
          encrypt: false,
          backup: false,
          autoSync: false,
          // When kvStoreType is not filled in, a multi device collaborative database is created by default
          kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
          // kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
          securityLevel: distributedKVStore.SecurityLevel.S1
        };

        let kvManagerUtilTask = startupManager.getStartupTaskResult('KvManagerUtilTask') as distributedKVStore.KVManager
        kvManagerUtilTask.getKVStore<distributedKVStore.SingleKVStore>('storeId', options,
          (err, store: distributedKVStore.SingleKVStore) => {
            if (err) {
              hilog.error(0x0000, TAG, `Failed getKVStore, errorCode:${err.code}, message:${err.message}`);
              reject(`Failed to get KVStore: Code:${err.code}, message:${err.message}`)
              return;
            }
            // Please ensure that the key value database instance is obtained before performing relevant data operations
            if (store === undefined) {
              reject('store === undefined');
              return;
            }
            resolve(store);
          });
      } catch (err) {
        hilog.error(0x0000, TAG, `Failed getKVStore, errorCode:${err.code}`);
      }
    })
  }
}

export class KvManagerUtil {
  private static kvManager: distributedKVStore.KVManager | undefined = undefined;

  private constructor() {
  }

  public static getInstance(context: common.BaseContext) {
    try {
      if (KvManagerUtil.kvManager === undefined) {
        const kvManagerConfig: distributedKVStore.KVManagerConfig = {
          context: context,
          bundleName: 'com.samples.appstartup'
        };
        KvManagerUtil.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      }
      return KvManagerUtil.kvManager;
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed getKVManager, errorCode:${err.code}`);
    }
    return KvManagerUtil.kvManager as distributedKVStore.KVManager;
  }
}

export class RdbStoreUtil {
  static getRdbStore(context: common.Context): Promise<relationalStore.RdbStore> {
    return new Promise((resolve, reject) => {
      try {
        const STORE_CONFIG: relationalStore.StoreConfig = {
          name: 'RdbTest.db',
          securityLevel: relationalStore.SecurityLevel.S1
        };

        relationalStore.getRdbStore(context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
          if (err) {
            reject('rdbStore === undefined');
            hilog.error(0x0000, TAG, `Get RdbStore failed, code is ${err.code},message is ${err.message}`);
            return;
          }
          resolve(rdbStore);
          hilog.info(0x0000, TAG, 'Get RdbStore successfully.');
        })
      } catch (err) {
        hilog.error(0x0000, TAG, `Failed getRdbStore, errorCode:${err.code}`);
      }
    });
  }
}

export class TimeUtils {
  static startTime: number = 0;
  static endTime: number = 0;

  static countTime(): number {
    return TimeUtils.endTime - TimeUtils.startTime;
  }
}