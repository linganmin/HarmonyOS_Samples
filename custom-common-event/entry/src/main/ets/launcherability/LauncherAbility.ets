/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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
import { commonEventManager } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import consts from '../module/Consts';
import { preferences } from '@kit.ArkData';
import surveillanceEventsManager from '../module/SurveillanceEventsManager';
import { window } from '@kit.ArkUI';
import Logger from '../module/Logger';
import { GlobalContext } from '../module/GlobalContext';

export default class LauncherAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    GlobalContext.getContext().setObject('abilityWant', want);
    let settings: Map<string, number> = new Map();
    surveillanceEventsManager.surveillanceEvents.forEach((element: string) => {
      settings.set(element, consts.ENABLE_STATE_ALWAYS);
    });
    GlobalContext.getContext().setObject('settings', settings);
    let curSettings = GlobalContext.getContext().getObject('settings') as Map<string, number>;
    Logger.info(`LauncherAbility onCreate, settings.size = ${curSettings.size}`);
  }

  async onDestroy() {
    Logger.info("LauncherAbility onDestroy");
    (GlobalContext.getContext().getObject('settings') as Map<string, number>)
      .forEach((value: number, key: string) => {
        if (value == consts.ENABLE_STATE_ONCE) {
          (GlobalContext.getContext().getObject('settings') as Map<string, number>).set(key, consts.ENABLE_STATE_NEVER);
        }
      });
    let thisPref: preferences.Preferences | null = null;
    await preferences.getPreferences(this.context, consts.DATA_BASE_NAME).then((pref) => {
      thisPref = pref;
    }).catch((err: BusinessError) => {
      Logger.error(`getPreferences failed, Code:${err.code}, message:${err.message}`);
    });
    for (let element of surveillanceEventsManager.surveillanceEvents) {
      try {
        await thisPref!.put(element, (GlobalContext.getContext()
          .getObject('settings') as Map<string, number>).get(element));
      } catch (exception) {
        Logger.error(`put failed, Code:${exception.code}, message:${exception.message}`);
      }
    }
    ;
    try {
      await thisPref!.flush();
    } catch (exception) {
      Logger.error(`flush failed, Code:${exception.code}, message:${exception.message}`);
    }
    let options: commonEventManager.CommonEventPublishData = {
      isSticky: true,
      parameters: surveillanceEventsManager.getSurveillanceEventStates()
    };
    commonEventManager.publish(consts.COMMON_EVENT_SETTING_UPDATE, options, () => {
      Logger.info("success to publish once enable event");
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    windowStage.loadContent("pages/Launch", (err, data) => {
      if (err.code) {
        Logger.error('Failed to load the content. Cause:' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeeded in loading the content. Data: ' + JSON.stringify(data));
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.info("LauncherAbility onWindowStageDestroy");
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.info("LauncherAbility onForeground");
  }

  onBackground() {
    // Ability has back to background
    Logger.info("LauncherAbility onBackground");
  }
}
