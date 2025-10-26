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

export class RentLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static processColor: string = '#ff10c1f7';
  private static capsuleColor: string = '#FF308977';
  private static underLineColor: string = '#FF0A59F7';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 1;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await RentLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //update liveView parameters
    RentLiveViewController.defaultView = await RentLiveViewController.buildDefaultView();
    if(!RentLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start liveView
    RentLiveViewController.nowStatus = LiveViewStatus.RENT_START;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(RentLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(RentLiveViewController.defaultView);
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
      if (!RentLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', RentLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (RentLiveViewController.defaultView.sequence) {
        RentLiveViewController.defaultView.sequence += 1;
      }
      RentLiveViewController.nowStatus += 1;
      switch (RentLiveViewController.nowStatus) {
        case LiveViewStatus.RENT_START:
          //start renting
          RentLiveViewController.defaultView.liveViewData.primary.title = await RentLiveViewController.resourceManager
            .getStringValue($r("app.string.Rent_start_title").id);
          RentLiveViewController.defaultView.timer = {
            isPaused: false
          };
          RentLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: false,
          }
          break;
        case LiveViewStatus.RENT_END:
          //end renting
          RentLiveViewController.defaultView.isMute = false;
          RentLiveViewController.defaultView.timer = {
            isPaused: true
          };
          RentLiveViewController.defaultView.liveViewData.primary.title = await RentLiveViewController.resourceManager
            .getStringValue($r("app.string.Rent_end_title").id);
          RentLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: true,
          }
          break;
        case LiveViewStatus.WAIT_PAYMENT:
          //pending payment
          RentLiveViewController.defaultView.liveViewData.primary.title = await RentLiveViewController.resourceManager
            .getStringValue($r("app.string.Wait_payment_title").id);
          RentLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Wait_payment_content").id)
            },
            { text: "${placeholder.timer}", textColor: RentLiveViewController.processColor },
          ];
          RentLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Wait_payment_layout_title").id),
            content: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Wait_payment_layout_content").id),
          }
          RentLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: RentLiveViewController.capsuleColor,
            title: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Wait_payment_capsule_title").id),
          }
          break;
        case LiveViewStatus.RENT_COMPLETE:
          //order completed
          await this.stopLiveView();
          return false;
        default:
          //destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(RentLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(RentLiveViewController.defaultView);
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
      if (!await RentLiveViewController.isLiveViewEnabled() || !RentLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (RentLiveViewController.defaultView.sequence) {
        RentLiveViewController.defaultView.sequence += 1;
      }
      RentLiveViewController.defaultView.isMute = true;
      RentLiveViewController.defaultView.liveViewData.primary.title = await RentLiveViewController.resourceManager
        .getStringValue($r("app.string.Rent_complete_title").id);
      RentLiveViewController.defaultView.liveViewData.primary.extensionData = {
        type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
        pic: 'icon_back.png',
        clickAction: await ContextUtil.buildWantAgent('RentShare')
      };
      RentLiveViewController.defaultView.liveViewData.primary.content = [
        { text: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_complete_content").id) },
      ];
      RentLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_complete_layout_title").id),
        content: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_complete_layout_content").id),
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(RentLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(RentLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}s', err.message);
    }
  }

  public async suspendLiveView(): Promise<boolean> {
    try {
      //live view is disabled
      if (!await RentLiveViewController.isLiveViewEnabled() || !RentLiveViewController.defaultView) {
        Logger.warn('suspendLiveView, live view is disabled.')
        return false;
      }
      if (RentLiveViewController.nowStatus != LiveViewStatus.RENT_START) {
        Logger.warn('suspendLiveView failed, rent is not running.')
        return false;
      }
      //update liveView parameters
      if (RentLiveViewController.defaultView.sequence) {
        RentLiveViewController.defaultView.sequence +=  1;
      }
      RentLiveViewController.nowStatus = LiveViewStatus.RENT_SUSPEND;
      RentLiveViewController.defaultView.liveViewData.primary.title = await RentLiveViewController.resourceManager
        .getStringValue($r("app.string.Rent_suspend_title").id);
      RentLiveViewController.defaultView.timer = {
        isPaused: true
      };
      RentLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
        status: 1,
        isPaused: true,
      }
      //update liveView
      Logger.info('Request suspendLiveView req: %{public}s', JSON.stringify(RentLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(RentLiveViewController.defaultView);
      Logger.info('Request suspendLiveView result: %{public}s', JSON.stringify(result));
      return true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request suspendLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
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
        id: 7, // liveView ID, generated by the developer
        event: "RENT", // application scenarios of liveView：RENT
        sequence: 1,//serial number
        timer: {//liveView timer
          time: 0,
          isCountdown: false,
          isPaused: false
        },
        liveViewData: {
          primary: {
            title: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_start_title").id),
            content: [
              {
                text: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_start_content").id)
              }
            ],// all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('RentShare'),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'icon_rent.png',
              clickAction: await ContextUtil.buildWantAgent('RentShare')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: await RentLiveViewController.resourceManager.getStringValue($r("app.string.Rent_start_layout_title").id),
              content: "${placeholder.timer}",
              underlineColor: RentLiveViewController.underLineColor,
              descPic: 'aito_m5.png'
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            icon: 'share.png',
            backgroundColor: RentLiveViewController.capsuleColor,
            time: 0,
            isCountdown: false,
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

enum LiveViewStatus {
  RENT_START = 1, //start renting
  RENT_END = 2, //end renting
  WAIT_PAYMENT = 3, //pending payment
  RENT_COMPLETE = 4, //order completed
  RENT_SUSPEND = 0, //lease suspension
}

