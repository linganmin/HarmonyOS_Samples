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
import { ImageUtil } from './ImageUtil'

export class PickLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static underLineColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await PickLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    PickLiveViewController.defaultView = await PickLiveViewController.buildDefaultView();
    if(!PickLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start liveView
    PickLiveViewController.nowStatus = LiveViewStatus.WAITING_PAYMENT;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(PickLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(PickLiveViewController.defaultView);
      Logger.info('Request startLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request startLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
    }
    return true;
  }

  public async updateLiveView(): Promise<boolean> {
    try {
      //live view is disabled
      if (!PickLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', PickLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (PickLiveViewController.defaultView.sequence) {
        PickLiveViewController.defaultView.sequence += 1;
      }
      PickLiveViewController.nowStatus += 1;
      switch (PickLiveViewController.nowStatus) {
        case LiveViewStatus.WAITING_MERCHANT:
          //waiting for merchant confirmation
          PickLiveViewController.defaultView.liveViewData.primary.title =
            await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_merchant_primary_title").id);
          PickLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await ContextUtil.applicationContext.resourceManager
                .getStringValue($r("app.string.Pick_merchant_primary_content").id)
            }
          ];
          PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_merchant_primary_layout_title").id),
            content: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_merchant_primary_layout_content").id),
            underlineColor: PickLiveViewController.underLineColor,
            descPic: 'icon_store.png'
          }
          PickLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: PickLiveViewController.capsuleColor,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_merchant_capsule_title").id)
          }
          break;
        case LiveViewStatus.PREPARING:
          //preparing meals
          PickLiveViewController.defaultView.liveViewData.primary.title =
            await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_prepare_primary_title").id);
          PickLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await ContextUtil.applicationContext.resourceManager
                .getStringValue($r("app.string.Pick_prepare_primary_content1").id)
            },
            {
              text: await ContextUtil.applicationContext.resourceManager
                .getStringValue($r("app.string.Pick_prepare_primary_content2").id)
            }
          ];
          PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_prepare_layout_title").id),
            content: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_prepare_layout_content").id),
            underlineColor: PickLiveViewController.underLineColor,
            descPic: 'coffee.png'
          };
          PickLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_preparing.png',
            backgroundColor: PickLiveViewController.capsuleColor,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_prepare_capsule_title").id)
          }
          break;
        case LiveViewStatus.WAITING_TO_BE_PICKED:
          //waiting to be picked up for meals
          PickLiveViewController.defaultView.isMute = false;
          PickLiveViewController.defaultView.liveViewData.primary.title =
            await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_wait_primary_title").id);
          PickLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await ContextUtil.applicationContext.resourceManager
                .getStringValue($r("app.string.Pick_wait_primary_content").id)
            }
          ];
          PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_wait_layout_title").id),
            content: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_wait_layout_content").id),
            underlineColor: PickLiveViewController.underLineColor,
            descPic: 'coffee.png'
          };
          PickLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_to_pick.png',
            backgroundColor: PickLiveViewController.capsuleColor,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_wait_capsule_title").id)
          }
          break;
        case LiveViewStatus.PRODUCT_PICKED:
          //meal picked up
          PickLiveViewController.defaultView.isMute = true;
          PickLiveViewController.defaultView.liveViewData.primary.title =
            await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_picked_primary_title").id);
          PickLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await ContextUtil.applicationContext.resourceManager
                .getStringValue($r("app.string.Pick_picked_primary_content").id)
            }
          ];
          PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_picked_primary_layout_title").id),
            content: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_picked_primary_layout_content").id),
            underlineColor: PickLiveViewController.underLineColor,
            descPic: 'icon_store.png'
          }
          PickLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_picked.png',
            backgroundColor: PickLiveViewController.capsuleColor,
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Pick_picked_capsule_title").id)
          }
          break;
        case LiveViewStatus.ORDER_FINISHED:
          //order completed
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(PickLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(PickLiveViewController.defaultView);
      Logger.info('Request updateLiveView result: %{public}s', JSON.stringify(result));
      return true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request updateLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
    }
  }

  public async stopLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await PickLiveViewController.isLiveViewEnabled() || !PickLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      PickLiveViewController.defaultView.sequence = LiveViewStatus.ORDER_FINISHED;
      PickLiveViewController.defaultView.isMute = true;
      PickLiveViewController.defaultView.liveViewData.primary.keepTime = 3;
      PickLiveViewController.defaultView.liveViewData.primary.title =
        await ContextUtil.applicationContext.resourceManager
          .getStringValue($r("app.string.Pick_finished_primary_title").id);
      PickLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await ContextUtil.applicationContext.resourceManager
            .getStringValue($r("app.string.Pick_finished_primary_content1").id)
        },
        {
          text: await ContextUtil.applicationContext.resourceManager
            .getStringValue($r("app.string.Pick_finished_primary_content2").id)
        }
      ];
      PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_finished_primary_layout_title").id),
        content: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_finished_primary_layout_content").id),
        underlineColor: PickLiveViewController.underLineColor,
        descPic: 'icon_store.png'
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(PickLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(PickLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async cancelLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await PickLiveViewController.isLiveViewEnabled() || !PickLiveViewController.defaultView) {
        Logger.warn('cancelLiveView, live view is disabled.')
        return;
      }
      Logger.info('cancelLiveView, get active live view succeed.');
      //update liveView parameters
      PickLiveViewController.defaultView.sequence = LiveViewStatus.ORDER_CANCELED
      PickLiveViewController.defaultView.liveViewData.primary.keepTime = 3;
      PickLiveViewController.defaultView.liveViewData.primary.title =
        await ContextUtil.applicationContext.resourceManager
          .getStringValue($r("app.string.Pick_cancel_primary_title").id);
      PickLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await ContextUtil.applicationContext.resourceManager
            .getStringValue($r("app.string.Pick_cancel_primary_content").id)
        }
      ];
      PickLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_cancel_primary_layout_title").id),
        content: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Pick_cancel_primary_layout_content").id),
        underlineColor: PickLiveViewController.underLineColor,
        descPic: 'icon_store.png'
      }
      PickLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_gps.png',
        backgroundColor: PickLiveViewController.capsuleColor,
        title: await ContextUtil.applicationContext.resourceManager
          .getStringValue($r("app.string.Delivery_delivered_capsule_title").id)
      }
      //destroy the liveView
      Logger.info('Request cancelLiveView req: %{public}s', JSON.stringify(PickLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(PickLiveViewController.defaultView);
      Logger.info('Request cancelLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request cancelLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  private static async isLiveViewEnabled(): Promise<boolean> {
    //live view is disabled
    let result: boolean = false;
    try {
      result = await liveViewManager.isLiveViewEnabled();
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request isLiveViewEnabled error: %{public}d %{public}s', err.code, err.message);
    }
    Logger.info('Request isLiveViewEnabled result: %{public}s', result);
    return result;
  }

  private static async buildDefaultView(): Promise<liveViewManager.LiveView | undefined> {
    try {
      return {
        id: 10,// liveView ID, generated by the developer
        event: 'PICK_UP',// application scenarios of liveView：PICK_UP。
        sequence: 1,//serial number
        liveViewData: {
          primary: {
            title: await ContextUtil.applicationContext.resourceManager
              .getStringValue($r("app.string.Delivery_default_primary_title").id),
            content: [
              {
                text: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Delivery_default_primary_content1").id),
                textColor: PickLiveViewController.contentColor
              },
              {
                text: ' ' +
                  await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Delivery_default_primary_content2").id)
              }
            ],//all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('PickUp'),
            extensionData: {//Expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: await ImageUtil.getNetworkPicture('', 'icon_merchant.png'),
              clickAction: await ContextUtil.buildWantAgent('PickUp')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Delivery_default_layout_title").id),
              content: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Delivery_default_layout_content").id),
              underlineColor: PickLiveViewController.underLineColor,
              descPic: 'coffee.png'
            },
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_purse.png',
            backgroundColor: PickLiveViewController.capsuleColor,
            title: await ContextUtil.applicationContext.resourceManager.getStringValue($r("app.string.Delivery_default_capsule_title").id)
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
  WAITING_PAYMENT = 1, //pending payment
  WAITING_MERCHANT = 2, //live view is disabled
  PREPARING = 3, //preparing meals
  WAITING_TO_BE_PICKED = 4, //waiting to be picked up for meals
  PRODUCT_PICKED = 5, //meal picked up
  ORDER_FINISHED = 6, //order completed
  ORDER_CANCELED = 7 //cancellation of order
}

