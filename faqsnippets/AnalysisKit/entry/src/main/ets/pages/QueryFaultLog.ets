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
* FAQ:当应用发生故障时，如何获取系统日志
 */

// [Start query_fault_log_callback]
import { FaultLogger } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

function queryFaultLogCallback(error: BusinessError, value: Array<FaultLogger.FaultLogInfo>) {
  if (error) {
    console.info('error is ' + error);
  } else {
    console.info("value length is " + value.length);
    let len: number = value.length;
    for (let i = 0; i < len; i++) {
      console.info("log: " + i);
      console.info("Log pid: " + value[i].pid);
      console.info("Log uid: " + value[i].uid);
      console.info("Log type: " + value[i].type);
      console.info("Log timestamp: " + value[i].timestamp);
      console.info("Log reason: " + value[i].reason);
      console.info("Log module: " + value[i].module);
      console.info("Log summary: " + value[i].summary);
      console.info("Log text: " + value[i].fullLog);
    }
  }
}

try {
  FaultLogger.query(FaultLogger.FaultType.JS_CRASH, queryFaultLogCallback);
} catch (err) {
  console.error(`code: ${(err as BusinessError).code}, message: ${(err as BusinessError).message}`);
}
// [End query_fault_log_callback]