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

import { common } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

const TAG = '[WindowManager]';

/**
 * Keep the screen on
 */
export class WindowManager {
  public static keepWindowScreenOn(context?: common.UIAbilityContext, isKeepScreenOn?: boolean) : void {
    try {
      let windowClass: window.Window | undefined = undefined;
      window.getLastWindow(context, (err: BusinessError, data) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, TAG, `Failed to obtain the top window. Cause: ${JSON.stringify(err)}`);
          return;
        }
        windowClass = data;
        hilog.info(0x0000, TAG, `Succeeded in obtaining the top window. Data: ${JSON.stringify(data)}`);
        try {
          windowClass.setWindowKeepScreenOn(isKeepScreenOn, (err: BusinessError) => {
            const errCode: number = err.code;
            if (errCode) {
              hilog.error(0x0000, TAG, `Failed to set the always-on screen status. Cause: ${JSON.stringify(err)}`);
              return;
            }
            hilog.info(0x0000, TAG, `Succeeded in setting the always-on screen status.`);
          });
        } catch (exception) {
          hilog.error(0x0000, TAG, `Failed to set the always-on screen status. Cause: ${JSON.stringify(exception)}`);
        }
      });
    } catch (exception) {
      hilog.error(0x0000, TAG, `Failed to obtain the top window. Cause: ${JSON.stringify(exception)}`);
    }
  }
}