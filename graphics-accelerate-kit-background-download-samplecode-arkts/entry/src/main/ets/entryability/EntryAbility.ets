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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TAG, DOMAINID } from '../common/CommonConstants';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAINID, TAG, 'Ability onCreate.');
  }

  onDestroy(): void {
    hilog.info(DOMAINID, TAG, 'Ability onDestroy.');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAINID, TAG, 'onWindowStageCreate.');
    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((error: BusinessError, data) => {
      const errCode: number = error.code;
      if (errCode) {
        hilog.error(DOMAINID,
          TAG, `failed to obtain the main window. errCode: ${error.code}, errMessage: ${error.message}`);
        return;
      }
      windowClass = data;
      let names: Array<'status' | 'navigation'> = [];
      try {
        let promise = windowClass.setWindowSystemBarEnable(names);
        promise.then(() => {
          hilog.info(DOMAINID, TAG, 'success in setting system bar to be enable.');
        }).catch((error: BusinessError) => {
          hilog.error(DOMAINID,
            TAG, `Failed to set system bar to be enable. errCode: ${error.code}, errMessage: ${error.message}`);
        });
      } catch (exception) {
        hilog.error(DOMAINID,
          TAG, `Failed to set system bar to be enable. Cause code: ${exception.code}, message: ${exception.message}`);
      }
    });

    windowStage.loadContent('pages/Index', (error) => {
      if (error.code) {
        hilog.error(DOMAINID,
          TAG, `Failed to load the content. Cause errCode: ${error.code}, errMessage: ${error.message}`);
        return;
      }
      hilog.info(DOMAINID, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAINID, TAG, 'Ability onWindowStageDestroy.');
  }

  onForeground(): void {
    hilog.info(DOMAINID, TAG, 'Ability onForeground.');
  }

  onBackground(): void {
    hilog.info(DOMAINID, TAG, 'Ability onBackground.');
  }
}
