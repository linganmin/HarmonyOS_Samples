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

export class QueueLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static processColor: string = '#ff10c1f7';
  private static capsuleColor: string = '#FF308977';
  private static underLineColor: string = '#FF0A59F7';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await QueueLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    QueueLiveViewController.defaultView = await QueueLiveViewController.buildDefaultView();
    if(!QueueLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start liveView
    QueueLiveViewController.nowStatus = LiveViewStatus.WAITING_CALL;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(QueueLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(QueueLiveViewController.defaultView);
      Logger.info('Request startLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request startLiveView error: %{public}s', err.message);
      return false;
    }
    return true;
  }

  public async updateLiveView(): Promise<boolean> {
    Logger.info('updateLiveView start');
    try {
      //live view is disabled
      if (!QueueLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', QueueLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (QueueLiveViewController.defaultView.sequence) {
        QueueLiveViewController.defaultView.sequence += 1;
      }
      QueueLiveViewController.nowStatus += 1;
      switch (QueueLiveViewController.nowStatus) {
        case LiveViewStatus.WAITING_CALL_SECOND:
          //waiting
          QueueLiveViewController.defaultView.timer = {}
          QueueLiveViewController.defaultView.liveViewData.primary.title = await QueueLiveViewController.resourceManager
            .getStringValue($r("app.string.Queue_second_wait_title").id);
          QueueLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_second_wait_content1").id)
            },
            { text: "${placeholder.timer}", textColor: QueueLiveViewController.processColor },
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_second_wait_content2").id)
            }
          ];
          break;
        case LiveViewStatus.UPCOMING_CALL:
          //coming soon
          QueueLiveViewController.defaultView.liveViewData.primary.title = await QueueLiveViewController.resourceManager
            .getStringValue($r("app.string.Queue_upcoming_call_title").id);
          QueueLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_upcoming_call_content1").id)
            },
            { text: "${placeholder.timer}", textColor: QueueLiveViewController.processColor },
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_upcoming_call_content2").id)
            }
          ];
          QueueLiveViewController.defaultView.isMute = false;
          QueueLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: QueueLiveViewController.capsuleColor,
            title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_upcoming_call_capsule_title").id),
          }
          break;
        case LiveViewStatus.CALLING_IN:
          //calling in
          QueueLiveViewController.defaultView.liveViewData.primary.title = await QueueLiveViewController.resourceManager
            .getStringValue($r("app.string.Queue_calling_in_title").id);
          QueueLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_calling_in_content1").id)
            },
            { text: "${placeholder.timer}", textColor: QueueLiveViewController.processColor },
            {
              text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_calling_in_content2").id)
            }
          ];
          QueueLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: QueueLiveViewController.capsuleColor,
            title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_calling_in_capsule_title").id),
          }
          break;
        case LiveViewStatus.QUENE_END:
          //queue completed
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(QueueLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(QueueLiveViewController.defaultView);
      Logger.info('Request updateLiveView result: %{public}s', JSON.stringify(result));
      return true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request updateLiveView error: %{public}s', err.message);
      return false;
    }
  }

  public async stopLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await QueueLiveViewController.isLiveViewEnabled() || !QueueLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (QueueLiveViewController.defaultView.sequence) {
        QueueLiveViewController.defaultView.sequence += 1;
      }
      QueueLiveViewController.defaultView.isMute = true;
      QueueLiveViewController.defaultView.liveViewData.primary.title = await QueueLiveViewController.resourceManager
        .getStringValue($r("app.string.Queue_end_title").id);
      QueueLiveViewController.defaultView.liveViewData.primary.content = [
        { text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_end_content").id) },
      ];
      QueueLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_layout_title").id),
        content: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_layout_content").id),
        underlineColor: QueueLiveViewController.underLineColor,
        descPic: 'icon_store.png'
      }
      QueueLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_store.png',
        backgroundColor: QueueLiveViewController.capsuleColor,
        title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_end_capsule_title").id),
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(QueueLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(QueueLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}s', err.message);
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

  private static async buildDefaultView(): Promise<liveViewManager.LiveView | undefined> {
    try {
      return {
        id: 3, // liveView ID, generated by the developer
        event: "QUEUE", // application scenarios of liveView:QUEUE
        sequence: 1,//serial number
        timer: {//liveView timer
          time: 0,
          isCountdown: false,
          isPaused: false
        },
        liveViewData: {
          primary: {
            title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_title").id),
            content: [
              {
                text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_Content1").id)
              },
              { text: "${placeholder.timer}", textColor: QueueLiveViewController.processColor },
              { text: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_Content2").id) }
            ], // all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('QueueingUp'),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'icon_merchant.png',
              clickAction: await ContextUtil.buildWantAgent('QueueingUp')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_waiting_call_layout_title").id),
              content: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_waiting_call_layout_content").id),
              underlineColor: QueueLiveViewController.underLineColor,
              descPic: 'icon_store.png'
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: QueueLiveViewController.capsuleColor,
            title: await QueueLiveViewController.resourceManager.getStringValue($r("app.string.Queue_wait_capsule_title").id),
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

enum LiveViewStatus {
  WAITING_CALL = 1, //pick up the number
  WAITING_CALL_SECOND = 2, //waiting
  UPCOMING_CALL = 3, //coming soon
  CALLING_IN = 4, //calling in
  QUENE_END = 5, //queue completed
}

