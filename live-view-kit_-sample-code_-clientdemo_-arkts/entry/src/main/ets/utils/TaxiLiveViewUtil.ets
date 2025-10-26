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

export class TaxiLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static underLineColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await TaxiLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    TaxiLiveViewController.defaultView = await TaxiLiveViewController.buildDefaultView();
    if(!TaxiLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start live view
    TaxiLiveViewController.nowStatus = LiveViewStatus.CALLING;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(TaxiLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(TaxiLiveViewController.defaultView);
      Logger.info('Request startLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request startLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
    }
    return true;
  }

  public async updateLiveView(): Promise<boolean> {
    Logger.info('updateLiveView start');
    try {
      //live view is disabled
      if (!TaxiLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', TaxiLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (TaxiLiveViewController.defaultView.sequence) {
        TaxiLiveViewController.defaultView.sequence += 1;
      }
      TaxiLiveViewController.nowStatus += 1;
      switch (TaxiLiveViewController.nowStatus) {
        case LiveViewStatus.ABOUT_TO_BEGIN:
          //the itinerary is about to begin
          TaxiLiveViewController.defaultView.isMute = false;
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.About_to_begin_title").id);
          TaxiLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.About_to_begin_content").id)
            }
          ];
          TaxiLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.About_to_begin_layout_title").id),
            content: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.About_to_begin_layout_content").id),
            underlineColor: TaxiLiveViewController.underLineColor,
            descPic: 'aito_m5.png'
          };
          TaxiLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_taxi.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.About_to_begin_capsule_title").id)
          }
          break;
        case LiveViewStatus.DRIVER_ON_THE_WAY:
          //the driver is on his way
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Driver_on_the_way_title").id);
          TaxiLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_gps.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Driver_on_the_way_capsule_title").id)
          }
          break;
        case LiveViewStatus.DRIVER_ARRIVE:
          //the driver has arrived at the boarding point
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Driver_arrive_title").id);
          TaxiLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.Driver_arrive_content").id)
            }
          ];
          break;
        case LiveViewStatus.HEADING_TO_DESTINATION:
          //going to destination
          TaxiLiveViewController.defaultView.isMute = true;
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Heading_to_destination_title").id);
          TaxiLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.Heading_to_destination_content1").id)
            },
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.Heading_to_destination_content2").id),
              textColor: TaxiLiveViewController.contentColor
            }
          ];
          TaxiLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 0,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'taxi-transport-icon.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          TaxiLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_taxi.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Heading_to_destination_capsule_title").id)
          }
          break;
        case LiveViewStatus.COMPLETED:
          //end of itinerary
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Completed_title").id);
          TaxiLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.Completed_content").id)
            }
          ];
          TaxiLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 100,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'taxi-transport-icon.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          TaxiLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_taxi.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Completed_capsule_title").id)
          }
          break;
        case LiveViewStatus.WAIT_PAYMENT:
          //pending payment
          TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Taxi_pend_payment_title").id);
          TaxiLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TaxiLiveViewController.resourceManager
                .getStringValue($r("app.string.Taxi_pend_payment_content").id)
            }
          ];
          TaxiLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
            title: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_layout_title").id),
            content: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_layout_content").id),
            underlineColor: TaxiLiveViewController.underLineColor,
            descPic: 'aito_m5.png'
          };
          TaxiLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Taxi_for_payment_capsule_title").id)
          }
          break;
        case LiveViewStatus.ORDER_COMPLETED:
          //order completed
          await this.stopLiveView();
          return false;
        default:
          //destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(TaxiLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(TaxiLiveViewController.defaultView);
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
      if (!await TaxiLiveViewController.isLiveViewEnabled() || !TaxiLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (TaxiLiveViewController.defaultView.sequence) {
        TaxiLiveViewController.defaultView.sequence += 1;
      }
      TaxiLiveViewController.defaultView.liveViewData.primary.title = await TaxiLiveViewController.resourceManager
        .getStringValue($r("app.string.Order_completed_title").id);
      TaxiLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await TaxiLiveViewController.resourceManager
            .getStringValue($r("app.string.Order_completed_content").id)
        }
      ];
      TaxiLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
        title: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.Order_completed_layout_title").id),
        content: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.Order_completed_layout_content").id),
        underlineColor: TaxiLiveViewController.underLineColor,
        descPic: 'aito_m5.png'
      };
      // destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(TaxiLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(TaxiLiveViewController.defaultView);
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

  private static async buildDefaultView(): Promise<liveViewManager.LiveView | undefined> {
    try {
      return {
        id: 1,// liveView ID, generated by the developer
        event: 'TAXI',// application scenarios of liveView：TAXI。
        sequence: LiveViewStatus.CALLING,//serial number
        liveViewData: {
          primary: {
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Calling_title").id),
            content: [
              {
                text: await TaxiLiveViewController.resourceManager.getStringValue($r("app.string.Calling_content").id)
              }
            ],// all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('TaxiHailing'),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'icon_taxi.png',
              clickAction: await ContextUtil.buildWantAgent('TaxiHailing')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_DEFAULT
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_gps.png',
            backgroundColor: TaxiLiveViewController.capsuleColor,
            title: await TaxiLiveViewController.resourceManager
              .getStringValue($r("app.string.Calling_capsule_title").id)
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
  CALLING = 1, //call the vehicle
  ABOUT_TO_BEGIN = 2, //the itinerary is about to begin
  DRIVER_ON_THE_WAY = 3, //The driver is on his way
  DRIVER_ARRIVE = 4, //The driver has arrived at the boarding point
  HEADING_TO_DESTINATION = 5, //Going to destination
  COMPLETED = 6, //End of itinerary
  WAIT_PAYMENT = 7, //pending payment
  ORDER_COMPLETED = 8 //order completed
}

