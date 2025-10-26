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
* FAQ:使用HiLog打印日志是否有长度限制
 */

// [Start hi_log_is_there_a_length_limit]
import { hilog } from '@kit.PerformanceAnalysisKit';

class LogUtil {
  private static instance: LogUtil;
  private static DOMAIN: number = 0x0000;

  private constructor() {
    // Private constructor to prevent external instantiation
  }

  public static getInstance(): LogUtil {
    if (!LogUtil.instance) {
      LogUtil.instance = new LogUtil();
    }
    return LogUtil.instance;
  }

  public logError(logTag: string, content: string) {
    const maxSize = 1024;
    if (content.length <= maxSize) {
      // Length less than or equal to the limit for direct printing
    } else {
      while (content.length > maxSize) {
        // Loop segmented printing
        let logContent = content.substring(0, maxSize);
        content = content.replace(logContent, '');
        hilog.error(LogUtil.DOMAIN, logTag, '%{public}s', logContent);
        // Print remaining logs
      }
    }
    hilog.error(LogUtil.DOMAIN, logTag, '%{public}s', content);
  }

  public logDebug(logTag: string, content: string) {
    const maxSize = 1024;
    if (content.length <= maxSize) {
      // Length less than or equal to the limit for direct printing
    } else {
      while (content.length > maxSize) {
        //Loop segmented printing
        let logContent = content.substring(0, maxSize);
        content = content.replace(logContent, '');
        hilog.debug(LogUtil.DOMAIN, logTag, '%{public}s', logContent);
        // Print remaining logs
      }
    }
    hilog.debug(LogUtil.DOMAIN, logTag, '%{public}s', content);
  }

  public logInfo(logTag: string, content: string) {
    const maxSize = 1024;
    if (content.length <= maxSize) {
      // Length less than or equal to the limit for direct printing
    } else {
      while (content.length > maxSize) {
        //Loop segmented printing
        let logContent = content.substring(0, maxSize);
        content = content.replace(logContent, '');
        hilog.info(LogUtil.DOMAIN, logTag, '%{public}s', logContent);
        // Print remaining logs
      }
    }
    hilog.info(LogUtil.DOMAIN, logTag, '%{public}s', content);
  }
}

export default LogUtil;
// [End hi_log_is_there_a_length_limit]