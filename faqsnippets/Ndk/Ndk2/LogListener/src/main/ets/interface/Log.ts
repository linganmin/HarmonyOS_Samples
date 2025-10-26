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
/**
 * FAQ: 如何在ArkTS侧监听Native侧日志信息
 */

// [Start log_listener_ts]
import { hilog } from '@kit.PerformanceAnalysisKit';


export class GlobalThisAdapter {
  private constructor() {
  }


  private static instance: GlobalThisAdapter;
  private _logListener: LogsListener = new LogsListener();


  public static getInstance(): GlobalThisAdapter {
    if (!GlobalThisAdapter.instance) {
      GlobalThisAdapter.instance = new GlobalThisAdapter();
    }
    return GlobalThisAdapter.instance;
  }


  getLogsListener(): LogsListener | undefined {
    return this._logListener;
  }


  setLogsListener(value: LogsListener): void {
    this._logListener = value;
  }
}


export class LogsListener implements OnLogsListener {
  public constructor() {
  }


  onLogs(level: LogLevel, message: string): void {
    switch (level) {
      case LogLevel.DEBUG:
        hilog.debug(0x0000, 'debug', 'debug message is %{public}s', message);
        break;
      case LogLevel.INFO:
        hilog.info(0x0000, 'info', 'info message is %{public}s', message);
        break;
      case LogLevel.WARN:
        hilog.warn(0x0000, 'warn', 'warn message is %{public}s', message)
        break;
      case LogLevel.ERROR:
        hilog.error(0x0000, 'error', 'error message is %{public}s', message);
        break;
      case LogLevel.FATAL:
        hilog.fatal(0x0000, 'fatal', 'fatal message is %{public}s', message);
        break;
      default:
        hilog.info(0x0000, 'info', 'info message is %{public}s', message);
    }
  }
}


enum LogLevel {
  DEBUG = 3,
  INFO,
  WARN,
  ERROR,
  FATAL
}


export default interface OnLogsListener {
  onLogs(level: number, message: string): void;
}
// [End log_listener_ts]