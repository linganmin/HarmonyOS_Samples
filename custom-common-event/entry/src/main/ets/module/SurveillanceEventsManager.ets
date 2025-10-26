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
import { commonEventManager } from '@kit.BasicServicesKit';
import { GlobalContext } from './GlobalContext';

export default class SurveillanceEventsManager {
  constructor() {
  }

  static getSurveillanceEventStates(): Record<string, number> {
    return {
      "usual.event.wifi.POWER_STATE": (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).get(commonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE) as number,
      "usual.event.SCREEN_OFF": (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).get(commonEventManager.Support.COMMON_EVENT_SCREEN_OFF) as number,
      "usual.event.SCREEN_ON": (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).get(commonEventManager.Support.COMMON_EVENT_SCREEN_ON) as number,
      "usual.event.SCREEN_LOCKED": (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).get(commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED) as number,
      "usual.event.SCREEN_UNLOCKED": (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).get(commonEventManager.Support.COMMON_EVENT_SCREEN_UNLOCKED) as number
    }
  }

  static surveillanceEvents: Array<string> = [
    commonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE,
    commonEventManager.Support.COMMON_EVENT_SCREEN_OFF,
    commonEventManager.Support.COMMON_EVENT_SCREEN_ON,
    commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED,
    commonEventManager.Support.COMMON_EVENT_SCREEN_UNLOCKED,
  ]
}