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

export class NavigationLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await NavigationLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    NavigationLiveViewController.defaultView = await NavigationLiveViewController.buildDefaultView();
    if(!NavigationLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    NavigationLiveViewController.nowStatus = LiveViewStatus.NAVIGATION_START;
    //start live view
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(NavigationLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(NavigationLiveViewController.defaultView);
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
      if (!NavigationLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', NavigationLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (NavigationLiveViewController.defaultView.sequence) {
        NavigationLiveViewController.defaultView.sequence += 1;
      }
      NavigationLiveViewController.nowStatus += 1;
      switch (NavigationLiveViewController.nowStatus) {
        case LiveViewStatus.GUIDE_OME:
          //guided one
          NavigationLiveViewController.defaultView.liveViewData.primary.title =
            await NavigationLiveViewController.resourceManager
              .getStringValue($r("app.string.Guide_one_title").id);
          NavigationLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
            currentNavigationIcon: "arrow_up.png",
            navigationIcons: ["arrow_left.png", "arrow_up.png", "arrow_up.png", "arrow_right.png"]
          }
          NavigationLiveViewController.defaultView.liveViewData.primary.extensionData = {
            type: liveViewManager.ExtensionType.EXTENSION_TYPE_PIC,
            pic: 'green_light.png',
            clickAction: await ContextUtil.buildWantAgent('Navigation')
          }
          NavigationLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_up.png',
            backgroundColor: NavigationLiveViewController.capsuleColor,
            title: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_capsule_title2").id),
            tailIcon: 'green_light.png',
            isTailIconDisplayed: true
          }
          break;
        case LiveViewStatus.ROUTE_CHANGE:
          //route change
          NavigationLiveViewController.defaultView.liveViewData.primary.title =
            await NavigationLiveViewController.resourceManager
              .getStringValue($r("app.string.Route_change_title").id);
          NavigationLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Route_change_content").id)
            }
          ];
          NavigationLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
            currentNavigationIcon: "arrow_right.png",
            navigationIcons: ["arrow_left.png", "arrow_up.png", "arrow_right.png"]
          }
          NavigationLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_right.png',
            backgroundColor: NavigationLiveViewController.capsuleColor,
            title: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_capsule_title3").id),
          }
          break;
        case LiveViewStatus.GUIDE_TWO:
          //guided two
          NavigationLiveViewController.defaultView.liveViewData.primary.title =
            await NavigationLiveViewController.resourceManager
              .getStringValue($r("app.string.Guide_two_title").id);
          NavigationLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Guide_two_content").id)
            }
          ];
          NavigationLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
            currentNavigationIcon: "arrow_up.png",
            navigationIcons: ["arrow_left.png", "arrow_up.png", "arrow_right.png"]
          }
          NavigationLiveViewController.defaultView.liveViewData.primary.extensionData = {
            type: liveViewManager.ExtensionType.EXTENSION_TYPE_PIC,
            pic: 'red_light.png',
            clickAction: await ContextUtil.buildWantAgent('Navigation')
          }
          NavigationLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_up.png',
            backgroundColor: NavigationLiveViewController.capsuleColor,
            title: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_capsule_title4").id),
            tailIcon: 'red_light.png',
            isTailIconDisplayed: true
          }
          break;
        case LiveViewStatus.NAVIGATION_END:
          //navigation ends
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(NavigationLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(NavigationLiveViewController.defaultView);
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
      if (!await NavigationLiveViewController.isLiveViewEnabled() || !NavigationLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (NavigationLiveViewController.defaultView.sequence) {
        NavigationLiveViewController.defaultView.sequence += 1;
      }
      NavigationLiveViewController.defaultView.liveViewData.primary.title =
        await NavigationLiveViewController.resourceManager
          .getStringValue($r("app.string.Navigation_end_title").id);
      NavigationLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_end_content").id),
        }
      ]
      NavigationLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_DEFAULT
      }
      NavigationLiveViewController.defaultView.liveViewData.primary.extensionData = {
        type: liveViewManager.ExtensionType.EXTENSION_TYPE_DEFAULT
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(NavigationLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(NavigationLiveViewController.defaultView);
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
        id: 5, // liveView ID, generated by the developer
        event: "NAVIGATION", // application scenarios of liveView：NAVIGATION
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        liveViewData: {
          primary: {
            title: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_start_title").id),
            content: [
              {
                text: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_start_content_one").id)
              },
              {
                text: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_start_content_two").id),
                textColor: NavigationLiveViewController.contentColor
              }
            ],//all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('Navigation'),
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
              currentNavigationIcon: "arrow_left.png",
              navigationIcons: ["arrow_left.png", "arrow_up.png", "arrow_up.png", "arrow_right.png"]
            },
            extensionData: {
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_PIC,
              pic: 'red_light.png',
              clickAction: await ContextUtil.buildWantAgent('Navigation')
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_left.png',
            backgroundColor: NavigationLiveViewController.capsuleColor,
            title: await NavigationLiveViewController.resourceManager.getStringValue($r("app.string.Navigation_capsule_title1").id),
            tailIcon: 'red_light.png',
            isTailIconDisplayed: true
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
  NAVIGATION_START = 1, //navigation begins
  GUIDE_OME = 2, //guided one
  ROUTE_CHANGE = 3, //route change
  GUIDE_TWO = 4, //guided two
  NAVIGATION_END = 5, //navigation ends
}

