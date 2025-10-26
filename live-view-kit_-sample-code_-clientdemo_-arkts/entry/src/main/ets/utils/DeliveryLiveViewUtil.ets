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

export class DeliveryLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static underLineColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await DeliveryLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    DeliveryLiveViewController.defaultView = await DeliveryLiveViewController.buildDefaultView();
    if(!DeliveryLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    DeliveryLiveViewController.nowStatus = LiveViewStatus.WAITING_PAYMENT;
    //start live view
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(DeliveryLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(DeliveryLiveViewController.defaultView);
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
      if (!DeliveryLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      //update liveView parameters
      Logger.info('updateLiveView, id: %{public}d', DeliveryLiveViewController.defaultView.id);
      if (DeliveryLiveViewController.defaultView.sequence) {
        DeliveryLiveViewController.defaultView.sequence += 1;
      }
      DeliveryLiveViewController.nowStatus += 1;
      switch (DeliveryLiveViewController.nowStatus) {
        case LiveViewStatus.WAITING_MERCHANT:
          //waiting for the merchant to accept the order
          DeliveryLiveViewController.defaultView.liveViewData.primary.title =
            await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_merchant_primary_title").id);
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_merchant_primary_content1").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_merchant_primary_content2").id)
            }
          ];
          DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 10,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            nodeIcons: [
              'icon_store_white.png',
              'icon_finish.png'
            ]
          };
          DeliveryLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_merchant_capsule_title").id)
          }
          break;
        case LiveViewStatus.WAITING_RIDER:
          //summoning the rider
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_rider_primary_content1").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_rider_primary_content2").id)
            }
          ];
          DeliveryLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_rider_capsule_title").id)
          }
          break;
        case LiveViewStatus.RIDER_GET_ORDER:
          //the rider rushed to the merchant
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_order_primary_content1").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_order_primary_content2").id)
            }
          ];
          DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 33,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'icon_rider.png',
            nodeIcons: [
              'icon_order.png',
              'icon_store_white.png',
              'icon_finish.png'
            ]
          };
          DeliveryLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_rider.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_order_capsule_title").id)
          };
          break;
        case LiveViewStatus.RIDER_TO_STORE:
          //the rider rushed to the merchant
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_store_primary_content1").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_store_primary_content2").id)
            }
          ];
          DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 50,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'icon_rider.png',
            nodeIcons: [
              'icon_order.png',
              'icon_store_gray.png',
              'icon_finish.png'
            ]
          };
          break;
        case LiveViewStatus.PRODUCT_DELIVERING:
          //the rider is delivering the goods
          DeliveryLiveViewController.defaultView.liveViewData.primary.title =
            await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_product_primary_title").id);
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_product_primary_content1").id)
            }
          ];
          DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 75,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'icon_rider.png',
            nodeIcons: [
              'icon_order.png',
              'icon_store_gray.png',
              'icon_finish.png'
            ]
          };
          DeliveryLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_rider.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_product_capsule_title").id)
          }
          break;
        case LiveViewStatus.PRODUCT_TO_CABINET:
          DeliveryLiveViewController.defaultView.isMute = false;
          DeliveryLiveViewController.defaultView.liveViewData.primary.title =
            await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_cabinet_primary_title").id);
          DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_cabinet_primary_content1").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_cabinet_primary_content2").id),
              textColor: DeliveryLiveViewController.contentColor
            },
            {
              text: ' | '
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_cabinet_primary_content3").id)
            },
            {
              text: await DeliveryLiveViewController.resourceManager
                .getStringValue($r("app.string.Delivery_cabinet_primary_content4").id),
              textColor: DeliveryLiveViewController.contentColor
            },
          ];
          DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 100,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          DeliveryLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_gps.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_cabinet_capsule_title").id)
          }
          break;
        case LiveViewStatus.PRODUCT_DELIVERED:
          //the product has been taken away and the order has been completed
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(DeliveryLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(DeliveryLiveViewController.defaultView);
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
      if (!await DeliveryLiveViewController.isLiveViewEnabled() || !DeliveryLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      //update liveView parameters
      if (DeliveryLiveViewController.defaultView.sequence) {
        DeliveryLiveViewController.defaultView.sequence += 1;
      }
      DeliveryLiveViewController.defaultView.isMute = true;
      DeliveryLiveViewController.defaultView.liveViewData.primary.title =
        await DeliveryLiveViewController.resourceManager
          .getStringValue($r("app.string.Delivery_delivered_primary_title").id);
      DeliveryLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await DeliveryLiveViewController.resourceManager
            .getStringValue($r("app.string.Delivery_delivered_primary_content1").id)
        },
        {
          text: await DeliveryLiveViewController.resourceManager
            .getStringValue($r("app.string.Delivery_delivered_primary_content2").id)
        }
      ];
      DeliveryLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
        progress: 100,
        lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
        nodeIcons: [
          'icon_order.png',
          'icon_finish.png'
        ]
      };
      //stop live view
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(DeliveryLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(DeliveryLiveViewController.defaultView);
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
      const err: BusinessError = e as BusinessError;
      Logger.error('Request isLiveViewEnabled error: %{public}d %{public}s', err.code, err.message);
    }
    Logger.info('Request isLiveViewEnabled result: %{public}s', result);
    return result;
  }

  private static async buildDefaultView(): Promise<liveViewManager.LiveView | undefined> {
    try {
      return {
        id: 0,// liveView ID, generated by the developer.
        event: 'DELIVERY',// application scenarios of liveView ：DELIVERY。
        sequence: 1,//serial number
        isMute: true,//is ringing reminder
        liveViewData: {
          primary: {
            title: await DeliveryLiveViewController.resourceManager
              .getStringValue($r("app.string.Delivery_default_primary_title").id),
            content: [
              {
                text: await DeliveryLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_primary_content1").id),
                textColor: DeliveryLiveViewController.contentColor
              },
              {
                text: ' ' +
                  await DeliveryLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_primary_content2").id)
              }
            ],// all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('InstantDelivery'),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: await ImageUtil.getNetworkPicture('', 'icon_merchant.png'),
              clickAction: await ContextUtil.buildWantAgent('InstantDelivery')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: await DeliveryLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_layout_title").id),
              content: await DeliveryLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_layout_content").id),
              underlineColor: DeliveryLiveViewController.underLineColor,
              descPic: 'coffee.png'
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_store.png',
            backgroundColor: DeliveryLiveViewController.capsuleColor,
            title: await DeliveryLiveViewController.resourceManager.getStringValue($r("app.string.Delivery_default_capsule_title").id)
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
  WAITING_PAYMENT = 1, //waiting for user payment
  WAITING_MERCHANT = 2, //waiting for the merchant to accept the order
  WAITING_RIDER = 3, //summoning the rider
  RIDER_GET_ORDER = 4, //the rider rushed to the merchant
  RIDER_TO_STORE = 5, //the rider has arrived at the store
  PRODUCT_DELIVERING = 6, //the rider is delivering the goods
  PRODUCT_TO_CABINET = 7, //delivery of goods to pickup container
  PRODUCT_DELIVERED = 8 //the product has been taken away and the order has been completed
}