/*
 * Copyright (c) 2025 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { GlobalContext } from '../common/utils/GlobalContext';
import { CommonConstants } from '../common/constants/CommonConstants';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want) {
    GlobalContext.getContext().setObject('abilityWant', want)
    GlobalContext.getContext().setObject('context', this.context)
    AppStorage.setOrCreate('context', this.context);
    if (want.parameters) {
      if (want.parameters.currentTime) {
        GlobalContext.getContext().setObject('currentTime', want.parameters.currentTime);
      }
    }
  }

  onDestroy() {
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      let window = await windowStage.getMainWindow()
      await window.setWindowKeepScreenOn(true)
      window.on('windowSizeChange', (newSize: window.Size) => {
        let eventWHData: emitter.EventData = {
          data: {
            'width': newSize.width,
            'height': newSize.height
          }
        };
        emitter.emit(CommonConstants.innerEventWH, eventWHData);
      });
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `getMainWindow failed, code is ${err.code}, message is ${err.message}`);
    }

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s',
          JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'Succeeded in loading the content. Data: %{public}s',
        JSON.stringify(data) ?? '');
      try {
        let windowClass: window.Window = windowStage.getMainWindowSync();
        windowClass.setWindowLayoutFullScreen(true).catch(() => {
          hilog.error(CommonConstants.LOG_DOMAIN, TAG,
            `setWindowLayoutFullScreen failed, code is ${err.code}, message is ${err.message}`);
        });
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `getMainWindowSync failed, code is ${err.code}, message is ${err.message}`);
      }
    });
  }

  onWindowStageDestroy() {
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}
