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

import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConst } from '../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'NetConnectionManager';

/**
 * Get default netHandle.
 * @returns Returns the default netHandle on success,otherwise returns undefined
 * */
export function getDefaultNetHandle(): connection.NetHandle | undefined {
  try {
    let netHandle = connection.getDefaultNetSync();
    hilog.info(DOMAIN, TAG, `[getDefaultNetHandle] success:${netHandle.netId}`);
    if (netHandle.netId < 1) {
      return undefined;
    }
    return netHandle;
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[getDefaultNetHandle] Error:${error.code},${error.name}`);
    return undefined;
  }
}

// [Start get_all_nethandles]
/**
 * Get all netHandles.
 * @returns Returns all netHandles on success,otherwise returns undefined
 * */
export function getAllNetHandles(): connection.NetHandle[] | undefined {
  try {
    let netHandles = connection.getAllNetsSync();
    const constNetHandles: connection.NetHandle[] = [];
    for (let i = 0; i < netHandles.length; i++) {
      hilog.info(DOMAIN, TAG, `[getAllNetHandles] success [${i}]>>>${netHandles[i].netId}`);
      if (netHandles[i].netId >= CommonConst.MIN_USEFUL_NET_ID) {
        constNetHandles.push(netHandles[i]);
      }
    }
    return constNetHandles;
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[getAllNetHandles] Error:${error.code},${error.name}`);
    return undefined;
  }
}
// [End get_all_nethandles]