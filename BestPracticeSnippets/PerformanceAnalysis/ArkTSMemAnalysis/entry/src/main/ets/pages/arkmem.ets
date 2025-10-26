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

/**
 * 最佳实践：分析ArkTS/JS内存
 */

import { distributedDataObject } from '@kit.ArkData';
import hilog from '@ohos.hilog';

// [Start function_mem_case_negative]
async addRecorderDataHelperListener() {
  let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
  let context = ContactsGlobalHelper.GetGlobalThis().getDefaultUIContext();
  let callRecorderHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context, uri);
  this.callRecorderHelper.on('dataChange', uri, () => {
    let listData: CallDetail[] = this.detailCallLogDataSource.getAllData();
    this.getRecorderMessage(0, listData, true);
    HiLog.i(TAG, 'callRecorderHelper addRecorderDataHelperListener end');
  });
}

removeRecorderDataHelperListener() {
  let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
  if (this.callRecorderHelper) {
    this.callRecorderHelper.off('dataChange', uri, () => {
      HiLog.i(TAG, 'callRecorderHelper removeRecorderDataHelperListener end');
    });
  }
}
// [End function_mem_case_negative]

// [Start function_mem_case_positive]
let dataChangeCallback: () => {
  let listData: CallDetail[] = this.detailCallLogDataSource.getAllData();
  this.getRecorderMessage(0, listData, true);
  hilog.info(0x0000, "Test", 'callRecorderHelper addRecorderDataHelperListener end');
}

async addRecorderDataHelperListener() {
  let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
  let context = ContactsGlobalHelper.GetGlobalThis().getDefaultUIContext();
  let callRecorderHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context, uri);
  this.callRecorderHelper.on('dataChange', uri, dataChangeCallback);
}

removeRecorderDataHelperListener() {
  let uri = Calls.CALL_RECORDER_LOG_PROXY_URI;
  if (this.callRecorderHelper) {
    this.callRecorderHelper.off('dataChange', uri, dataChangeCallback);
  }
}
// [End function_mem_case_positive]