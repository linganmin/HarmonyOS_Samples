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

import { common } from '@kit.AbilityKit';
import { distributedKVStore } from '@kit.ArkData';
import { bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KVStoreType } from '../../viewmodel/KVStoreType';
import { BusinessError } from '@kit.BasicServicesKit';

export default class KVStore {
  private kvManager: distributedKVStore.KVManager | undefined = undefined;
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined;
  private bundleName: string = '';

  constructor(encrypt: boolean, securityLevel: distributedKVStore.SecurityLevel, UIContext: UIContext) {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    UIContext = UIContext
    let hContext = UIContext.getHostContext() as common.UIAbilityContext;

    bundleManager.getBundleInfoForSelf(bundleFlags, (err, data) => {
      this.bundleName = data.name;
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: hContext,
        bundleName: this.bundleName
      };
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        backup: false,
        autoSync: false,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        encrypt: encrypt,
        securityLevel: securityLevel
      };
      this.kvManager.getKVStore<distributedKVStore.SingleKVStore>(`${securityLevel}${JSON.stringify(encrypt)}`, options,
        (err, store: distributedKVStore.SingleKVStore) => {
          if (err) {
            hilog.error(0x0000, 'KVStore', `Failed to get KVStore: Code:${err.code},message:${err.message}`);
            return;
          }
          hilog.info(0x0000, 'KVStore', 'Succeeded in getting KVStore.');
          this.kvStore = store;
        });
    })
  }

  async put(key: string, value: Uint8Array | string | number | boolean) {
    this.kvStore!.put(key, value, (err) => {
      if (err !== undefined) {
        hilog.error(0x0000, 'KVStore', `Failed to put data. Code:${err.code},message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'KVStore', 'Succeeded in putting data.');
    });
  }

  delete(key: string) {
    this.kvStore!.delete(key, (err) => {
      if (err !== undefined) {
        hilog.error(0x0000, 'KVStore', `Failed to delete data. Code:${err.code},message:${err.message}`);
        return;
      }
      hilog.info(0x0000, 'KVStore', 'Succeeded in deleting data.');
    });
  }

  async getAll(): Promise<KVStoreType[]> {
    let allKVStore: KVStoreType[] = [];
    await this.kvStore!.getEntries('^').then((entries: distributedKVStore.Entry[]) => {
      let i = 0;
      for (i; i < entries.length; i++) {
        let type: string = typeof entries[i].value.value;
        if (type === 'object') {
          type = 'Uint8Array';
        }
        let kvStoreType = new KVStoreType(entries[i].key, entries[i].value.value, type);
        allKVStore.push(kvStoreType);
      }
    }).catch((error: BusinessError) =>{
      hilog.error(0x0000, 'KVStore', `Failed to getEntries. Code:${error.code},message:${error.message}`);
    })
    hilog.info(0x0000, 'KVStore', `kvStoreType: ${JSON.stringify(allKVStore)}`);
    return allKVStore;
  }
}