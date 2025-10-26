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

import { StartupTask } from '@kit.AbilityKit';
import { distributedKVStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SingleKVStoreUtil } from '../util/SingleKVStore';

@Sendable
export default class KVStoreTask extends StartupTask {
  constructor() {
    super();
  }

  async init() {
    try {
      SingleKVStoreUtil.getKVStore()
        .then((kvStore: distributedKVStore.SingleKVStore) => {
          const KEY_TEST_STRING_ELEMENT = 'key_test_string';
          const VALUE_TEST_STRING_ELEMENT = 'Show KVStoreTask init data: value_test_string';
          kvStore.put(KEY_TEST_STRING_ELEMENT, VALUE_TEST_STRING_ELEMENT, (err) => {
            if (err !== undefined) {
              hilog.error(0x0000, 'KVStoreTask', `Failed to put data. Code:${err.code}, message:${err.message}`);
              return;
            }
            hilog.info(0x0000, 'KVStoreTask', `Succeeded in putting data.`);
          });
        }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'KVStoreTask', `Failed to create KVManager. message:${err.message}`);
      });
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'KVStoreTask', `Failed to create KVManager. Code:${error.code}, message:${error.message}`);
    }
  }
}