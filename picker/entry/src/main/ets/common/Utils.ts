/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { router, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

let log = '';
const TIMEOUT_MAX = 10;

export class DocFileInfo {
  constructor(public filename: string, public size: number) {
    this.filename = filename;
    this.size = size;
  }
}

export default class Utils {
  clearLog(): void {
    log = '';
  }

  setLog(message: string): void {
    if (log === null || log === undefined) {
      log = message;
    } else {
      log += '\n' + message;
    }
  }

  getLog(): string {
    return log;
  }

  myLog(info: string, tag: string = 'testTag'): void {
    hilog.isLoggable(0x0000, tag, hilog.LogLevel.INFO);
    hilog.info(0x0000, tag, '%{public}s', info);
    this.setLog('[info]' + info);
  }

  myWarnLog(warn: string, tag: string = 'testTag'): void {
    hilog.isLoggable(0x0000, 'testTag', hilog.LogLevel.WARN);
    hilog.warn(0x0000, 'testTag', 'Failed Cause: %{public}s', warn);
    this.setLog('[warn]' + warn);
  }

  myErrLog(err: string, tag: string = 'testTag'): void {
    hilog.isLoggable(0x0000, tag, hilog.LogLevel.ERROR);
    hilog.error(0x0000, tag, 'Failed Cause: %{public}s', err);
    this.setLog('[error]' + err);
  }

  showInfo(info): void {
    promptAction.showToast({
      message: info,
      duration: 2000
    });
  }

  myBack(toAbility: string = '', mParams: { [key: string]: string } = null): void {
    let options = {
      url: toAbility,
      params: mParams
    };
    router.back(options);
  }

  async goToPage(toAbility: string, mParams: { [key: string]: string }): Promise<void> {
    let options = {
      url: toAbility,
      params: mParams
    };
    try {
      await router.pushUrl(options);
    } catch (err) {
      hilog.error(0x0000, 'err', 'fail callback, code: %{public}s', err.msg);
    }
  }

  async sleep(times): Promise<void> {
    if (!times) {
      times = TIMEOUT_MAX;
    }
    await new Promise((res) => setTimeout(res, times));
  };
}