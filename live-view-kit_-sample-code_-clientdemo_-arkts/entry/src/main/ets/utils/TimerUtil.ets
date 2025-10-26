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

import { liveViewManager } from '@kit.LiveViewKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './LogUtil';
import { ContextUtil } from './ContextUtil';

export class TimerController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static capsuleColor: string = '#FF308977';
  private static pickUpColor: string = '#FF0A59F7';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static isCountdown: boolean = false;

  public async startLiveView(isCountdown: boolean = false): Promise<void> {
    //live view is disabled
    if (!await TimerController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return;
    }
    //update liveView parameters
    TimerController.isCountdown = isCountdown;
    TimerController.defaultView = await TimerController.buildDefaultView(TimerController.isCountdown);
    if(!TimerController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return;
    }
    //start liveView
    try {
      const result = await liveViewManager.startLiveView(TimerController.defaultView);
      Logger.info('Request startLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request startLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async pauseTimer(): Promise<void> {
    Logger.info('pauseTimer');
    try {
      //is liveView parameters initialized
      if (!TimerController.defaultView) {
        return;
      }
      //update liveView parameters
      TimerController.defaultView.timer = {
        isPaused: true
      }
      TimerController.defaultView.liveViewData.primary.title = '已暂停'
      TimerController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
        status: 1,
        isPaused: true,
      }
      if (TimerController.defaultView.sequence) {
        TimerController.defaultView.sequence += 1;
      }
      //update liveView
      await liveViewManager.updateLiveView(TimerController.defaultView);
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request updateLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async continueTimer(): Promise<void> {
    Logger.info('continueTimer');
    try {
      //is liveView parameters initialized
      if (!TimerController.defaultView) {
        return;
      }
      //update liveView parameters
      TimerController.defaultView.timer = {
        isPaused: false
      }
      TimerController.defaultView.liveViewData.primary.title = '计时中'
      TimerController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
        status: 1,
        isPaused: false,
      }
      if (TimerController.defaultView.sequence) {
        TimerController.defaultView.sequence += 1;
      }
      //update liveView
      await liveViewManager.updateLiveView(TimerController.defaultView);
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request updateLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async stopLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await TimerController.isLiveViewEnabled() || !TimerController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (TimerController.defaultView.sequence) {
        TimerController.defaultView.sequence += 1;
      }
      TimerController.defaultView.liveViewData.primary.title = '已结束'
      TimerController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: '计时时间',
        underlineColor: TimerController.pickUpColor,
        descPic: 'timer.png'
      };
      TimerController.defaultView.timer = {
        isPaused: true
      };
      TimerController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        title: await TimerController.resourceManager
          .getStringValue($r("app.string.Score_end_capsule_title").id)
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(TimerController.defaultView));
      const result = await liveViewManager.stopLiveView(TimerController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  private static async isLiveViewEnabled(): Promise<boolean> {
    //live view is disabled
    let result: boolean = false;
    try {
      result = await liveViewManager.isLiveViewEnabled();
    } catch (e) {
      Logger.error('Request isLiveViewEnabled error: %{public}s', e);
    }
    Logger.info('Request isLiveViewEnabled result: %{public}s', result);
    return result;
  }

  private static async buildDefaultView(isCountdown: boolean = false): Promise<liveViewManager.LiveView | undefined> {
    try {
      return {
        id: 8, // liveView ID, generated by the developer
        event: "TIMER", // application scenarios of liveView:TIMER。
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        timer: {
          time: isCountdown ? 5 * 60 * 1000 : 0,
          isCountdown: isCountdown,
          isPaused: false
        },
        liveViewData: {
          primary: {
            title: '计时中',
            content: [
              {
                text: '计时实况窗体验'
              }
            ],
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('Timer'),
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: '计时时间',
              content: '${placeholder.timer}',
              underlineColor: TimerController.pickUpColor,
              descPic: 'timer.png'
            },
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_DEFAULT,
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            icon: 'capsule_timer.png',
            backgroundColor: TimerController.capsuleColor,
            time: isCountdown ? 5 * 60 * 1000 : 0,
            isCountdown: isCountdown,
            isPaused: false,
          }
        }
      }
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('BuildDefaultView Failed: %{public}d %{public}s', err.code, err.message);
      return undefined;
    }
  }
}


