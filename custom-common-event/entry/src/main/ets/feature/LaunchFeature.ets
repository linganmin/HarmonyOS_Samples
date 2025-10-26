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
import { common } from '@kit.AbilityKit';
import { commonEventManager, BusinessError } from '@kit.BasicServicesKit';
import consts from '../module/Consts';
import { preferences } from '@kit.ArkData';
import Logger from '../module/Logger';
import { router } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';
import { GlobalContext } from '../module/GlobalContext';

export default class LaunchFeature {
  private context: UIContext | null = null;
  private pref: preferences.Preferences | null = null;
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private subscriberLow: commonEventManager.CommonEventSubscriber | null = null;
  private currentRecordTimes: number = 0;

  constructor(context: UIContext) {
    this.context = context;
  }

  async init(): Promise<void> {
    await preferences.getPreferences(this.context?.getHostContext() as common.UIAbilityContext, consts.DATA_BASE_NAME)
      .then((pref) => {
        this.pref = pref;
      }).catch((err: BusinessError) => {
        Logger.error(`getPreferences failed, Code:${err.code}, message:${err.message}`);
      });
    await this.pref?.get(consts.DATA_BASE_KEY_WIFI_POWER_STATE, 0).then((value: preferences.ValueType) => {
      (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).set(commonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE, value as number);
    }).catch((err: BusinessError) => {
      Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
    });
    await this.pref?.get(consts.DATA_BASE_KEY_SCREEN_OFF, 0).then((value1: preferences.ValueType) => {
      (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).set(commonEventManager.Support.COMMON_EVENT_SCREEN_OFF, value1 as number);
    }).catch((err: BusinessError) => {
      Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
    });
    await this.pref?.get(consts.DATA_BASE_KEY_SCREEN_ON, 0).then((value2: preferences.ValueType) => {
      (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).set(commonEventManager.Support.COMMON_EVENT_SCREEN_ON, value2 as number);
    }).catch((err: BusinessError) => {
      Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
    });
    await this.pref?.get(consts.DATA_BASE_KEY_SCREEN_LOCKED, 0).then((value3: preferences.ValueType) => {
      (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).set(commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED, value3 as number);
    }).catch((err: BusinessError) => {
      Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
    });
    await this.pref?.get(consts.DATA_BASE_KEY_SCREEN_UNLOCKED, 0).then((value4: preferences.ValueType) => {
      (GlobalContext.getContext()
        .getObject('settings') as Map<string, number>).set(commonEventManager.Support.COMMON_EVENT_SCREEN_UNLOCKED, value4 as number);
    }).catch((err: BusinessError) => {
      Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
    });
  }

  private insertRecord = (event: commonEventManager.CommonEventData, value: preferences.ValueType) => {
    if (event.parameters) {
      (value as Array<string>).push(event.parameters[consts.DATA_BASE_KEY_START_TIME]);
    }
    // refresh database
    this.pref?.put(consts.DATA_BASE_KEY_TOTAL_TIMES, value).then(() => {
      let detail: Array<string> = [];
      if (event.parameters) {
        detail.push(event.parameters["startTime"]);
        detail.push(event.parameters["endTime"]);
        detail.push(event.parameters["totalTime"]);
        detail.push(event.parameters["totalEvents"]);
        this.pref?.put(event.parameters[consts.DATA_BASE_KEY_START_TIME], detail).then(() => {
          this.pref?.flush();
        })
      }
    });
  }
  private callbackFunc = (error: BusinessError, event: commonEventManager.CommonEventData) => {
    this.pref?.has(consts.DATA_BASE_KEY_TOTAL_TIMES, (err, ret) => {
      if (ret) {
        this.pref?.get(consts.DATA_BASE_KEY_TOTAL_TIMES, []).then((value) => {
          this.insertRecord(event, value);
        });
      } else {
        let value: Array<string> = [];
        this.insertRecord(event, value);
      }
      if (this.currentRecordTimes >= consts.MAX_RECORD_NUM) {
        this.subscriber?.finishCommonEvent();
        return;
      }
      this.subscriber?.abortCommonEvent();
      this.subscriber?.finishCommonEvent();
      this.currentRecordTimes++;
    })
  }
  private callbackLowFunc = (error: BusinessError, event: commonEventManager.CommonEventData) => {
    this.currentRecordTimes = 1;
    this.pref?.get(consts.DATA_BASE_KEY_TOTAL_TIMES, []).then((value: preferences.ValueType) => {
      for (let i = 0; i < consts.MAX_RECORD_NUM; i++) {
        this.pref?.delete((value as Array<string>)[i]).then(() => {
          this.pref?.flush();
          this.subscriberLow?.finishCommonEvent();
        })
      }
      let records = (value as Array<string>).slice(consts.MAX_RECORD_NUM, consts.MAX_RECORD_NUM + 1);
      this.pref?.put(consts.DATA_BASE_KEY_TOTAL_TIMES, records);
      this.pref?.flush();
    })
  }
  jumpToStart = () => {
    // subscribe
    if (this.subscriber == null) {
      let highSubscriberInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [
          consts.COMMON_EVENT_FINISH_MEDITATION// unordered self defined event
        ],
        priority: 2 // 2 indicates high priority subscriber
      };
      commonEventManager.createSubscriber(highSubscriberInfo, (err, subscriber) => {
        this.subscriber = subscriber
        if (subscriber != null) {
          commonEventManager.subscribe(subscriber, this.callbackFunc);
        }
      });
    }
    // subscribe
    if (this.subscriberLow == null) {
      let lowSubscriberInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [
          consts.COMMON_EVENT_FINISH_MEDITATION// unordered self defined event
        ],
        priority: 1 // 1 indicates low priority subscriber
      };
      commonEventManager.createSubscriber(lowSubscriberInfo, (err, subscriber) => {
        this.subscriberLow = subscriber;
        if (subscriber != null) {
          commonEventManager.subscribe(subscriber, this.callbackLowFunc);
        }
      });
    }
    let want: Want = {
      bundleName: 'com.samples.customcommonevent',
      abilityName: 'MainAbility',
    };
    let innerContext: common.UIAbilityContext = this.context?.getHostContext() as common.UIAbilityContext
    innerContext?.startAbility(want);
  }
  jumpToHistory = () => {
    Logger.info("ready to jump to history page");
    this.context?.getRouter().pushUrl({
      url: 'pages/History',
      params: {}
    });
  }
  jumpToSetting = () => {
    Logger.info("ready to jump to setting page");
    this.context?.getRouter().pushUrl({
      url: 'pages/Setting',
      params: {}
    });
  }
  jumpToAbout = () => {
    Logger.info("ready to jump to about page");
    this.context?.getRouter().pushUrl({
      url: 'pages/About',
      params: {}
    });
  }
}