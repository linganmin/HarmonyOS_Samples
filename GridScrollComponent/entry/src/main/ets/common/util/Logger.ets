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
 
import { hilog } from "@kit.PerformanceAnalysisKit";

export class Logger {
  static tag = 'GridSample';
  static domain = 0xfa0a;

  static info(info: string, ...arg: ESObject[]) {
    hilog.info(Logger.domain, Logger.tag, info, ...arg);
  }

  static debug(info: string, ...arg: ESObject[]) {
    hilog.debug(Logger.domain, Logger.tag, info, ...arg);
  }

  static error(info: string, ...arg: ESObject[]) {
    hilog.error(Logger.domain, Logger.tag, info, ...arg);
  }

  static warn(info: string, ...arg: ESObject[]) {
    hilog.warn(Logger.domain, Logger.tag, info, ...arg);
  }

  static fatal(info: string, ...arg: ESObject[]) {
    hilog.fatal(Logger.domain, Logger.tag, info, ...arg);
  }
}
