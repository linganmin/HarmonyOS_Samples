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
import { CommonUtil, CustomerWeatherType } from './CommonUtil';

export class TrainLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static trainNumber: string = '';
  private static trainStartTime: string = '';
  private static trainStopTime: string = '';
  private static flightBackGroundType: liveViewManager.BackgroundType =
    liveViewManager.BackgroundType.SYS_BACKGROUND_UNDEFINED;
  private static nowStatus: number = 1;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await TrainLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //start liveView
    try {
      //initialize live window parameters
      TrainLiveViewController.trainNumber =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_number").id);
      TrainLiveViewController.trainStartTime =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_first_title").id);
      TrainLiveViewController.trainStopTime =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_last_title").id);
      TrainLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_SUNSET;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      TrainLiveViewController.nowStatus = LiveViewStatus.DEPART;
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(TrainLiveViewController.defaultView);
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
      if (!TrainLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', TrainLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (TrainLiveViewController.defaultView.sequence) {
        TrainLiveViewController.defaultView.sequence += 1;
      }
      TrainLiveViewController.nowStatus += 1;
      switch (TrainLiveViewController.nowStatus) {
        case LiveViewStatus.DEPART:
          //plan to depart
          TrainLiveViewController.defaultView.isMute = false;
          let sequenceNow = TrainLiveViewController.defaultView.sequence;
          TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
          if(!TrainLiveViewController.defaultView){
            Logger.warn('buildDefaultView Failed.')
            return false;
          }
          TrainLiveViewController.defaultView.sequence = sequenceNow;
          break;
        case LiveViewStatus.PASSED_SECURITY_CHECK:
          //checked and inspected
          TrainLiveViewController.defaultView.isMute = true;
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Passed_security_check_title").id) + TrainLiveViewController.trainNumber;
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
            await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.HEAVY_RAIN);
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Passed_security_check_capsule_title").id),
          }
          break;
        case LiveViewStatus.TICKET_CHECK:
          //ticket checking reminder
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Ticket_check_title").id) + TrainLiveViewController.trainNumber;
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
            await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.LIGHT_SNOW);
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Ticket_check_capsule_title").id),
          }
          break;
        case LiveViewStatus.CHECKED:
          //ticket checked
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Checked_title").id) + TrainLiveViewController.trainNumber;
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
            await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW);
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Checked_capsule_title").id),
          }
          break;
        case LiveViewStatus.CHECK_IN_CLOSED:
          //stop ticket checking
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Check_in_closed_title").id) + TrainLiveViewController.trainNumber;
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
            await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW2);
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Check_in_closed_capsule_title").id),
          }
          break;
        case LiveViewStatus.SET_OFF:
          //journey begins
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Set_off_title").id);
          TrainLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_content1").id),
            },
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_content2").id),
              textColor: TrainLiveViewController.contentColor
            },
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_content3").id),
            }
          ];
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 0,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'high_speed_train_transport_icon.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager
              .getStringValue($r("app.string.Set_off_capsule_title").id)
          }
          break;
        case LiveViewStatus.SET_OFF_CONTINUE:
          //journey begins
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Set_off_continue_title").id);
          TrainLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_continue_content1").id),
            },
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_continue_content2").id),
              textColor: TrainLiveViewController.contentColor
            },
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Set_off_continue_content3").id),
            }
          ];
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 40,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'high_speed_train_transport_icon.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager
              .getStringValue($r("app.string.Set_off_continue_capsule_title").id)
          }
          break;
        case LiveViewStatus.ARRIVED:
          //arrived
          TrainLiveViewController.defaultView.isMute = false;
          TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Arrived_title").id);
          TrainLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await TrainLiveViewController.resourceManager
                .getStringValue($r("app.string.Arrived_content").id)
            }
          ];
          TrainLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 100,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'high_speed_train_transport_icon.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          TrainLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager
              .getStringValue($r("app.string.Arrived_capsule_title").id)
          }
          break;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(TrainLiveViewController.defaultView);
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
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (TrainLiveViewController.defaultView.sequence) {
        TrainLiveViewController.defaultView.sequence += 1;
      }
      TrainLiveViewController.defaultView.isMute = true;
      TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
        .getStringValue($r("app.string.Arrived_title").id);
      TrainLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Arrived_content").id)
        }
      ];
      TrainLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
        progress: 100,
        lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
        indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
        indicatorIcon: 'high_speed_train_transport_icon.png',
        nodeIcons: [
          'icon_order.png',
          'icon_finish.png'
        ]
      };
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(TrainLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async delayedLiveView(): Promise<Boolean> {
    try {
      //live view is disabled
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('delayedLiveView, live view is disabled.')
        return false;
      }
      Logger.info('delayedLiveView, get active live view succeed.');
      //update liveView parameters
      TrainLiveViewController.trainStartTime =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_first_title_two").id);
      TrainLiveViewController.trainStopTime =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_last_title_two").id);
      TrainLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_MOON;
      let sequenceNow = TrainLiveViewController.defaultView.sequence;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      if (sequenceNow) {
        TrainLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      TrainLiveViewController.nowStatus = LiveViewStatus.TRAIN_DELAY;
      TrainLiveViewController.defaultView.liveViewData.primary.title =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_delay_title").id) +
          TrainLiveViewController.trainNumber;
      TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
        await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW);
      TrainLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_train.png',
        backgroundColor: TrainLiveViewController.capsuleColor,
        title: await TrainLiveViewController.resourceManager
          .getStringValue($r("app.string.Train_delay_capsule_title").id)
      }
      //update liveView
      Logger.info('Request delayedLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(TrainLiveViewController.defaultView);
      Logger.info('Request delayedLiveView result: %{public}s', JSON.stringify(result));
      return true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request delayedLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
    }
  }

  public async rescheduleLiveView(): Promise<Boolean> {
    try {
      //live view is disabled
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('rescheduleLiveView, live view is disabled.')
        return false;
      }
      Logger.info('rescheduleLiveView, get active live view succeed.');
      //update liveView parameters
      if (await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_number").id) ==
      TrainLiveViewController.trainNumber) {
        TrainLiveViewController.trainNumber =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_number_two").id);
        TrainLiveViewController.trainStartTime =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_first_title_two").id);
        TrainLiveViewController.trainStopTime =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_last_title_two").id);
        TrainLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_MOON;
      } else {
        TrainLiveViewController.trainNumber =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_number").id);
        TrainLiveViewController.trainStartTime =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_first_title").id);
        TrainLiveViewController.trainStopTime =
          await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_last_title").id);
        TrainLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_SUNSET;
      }
      let sequenceNow = TrainLiveViewController.defaultView.sequence;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      if (sequenceNow) {
        TrainLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      TrainLiveViewController.nowStatus = LiveViewStatus.RESCHEDULE;
      TrainLiveViewController.defaultView.liveViewData.primary.title =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_reschedule_title").id)
          + TrainLiveViewController.trainNumber;
      TrainLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_train.png',
        backgroundColor: TrainLiveViewController.capsuleColor,
        title: await TrainLiveViewController.resourceManager
          .getStringValue($r("app.string.Train_reschedule_capsule_title").id)
      }
      //update liveView
      Logger.info('Request rescheduleLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(TrainLiveViewController.defaultView);
      Logger.info('Request rescheduleLiveView result: %{public}s', JSON.stringify(result));
      return true;
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request rescheduleLiveView error: %{public}d %{public}s', err.code, err.message);
      return false;
    }
  }

  public async refundTicketLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('refundTicketLiveView, live view is disabled.')
        return;
      }
      Logger.info('refundTicketLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = TrainLiveViewController.defaultView.sequence;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return;
      }
      if (sequenceNow) {
        TrainLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
        await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW2);
      TrainLiveViewController.defaultView.liveViewData.primary.title =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_refund_ticket_title").id)
          + TrainLiveViewController.trainNumber;
      //update liveView
      Logger.info('Request refundTicketLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(TrainLiveViewController.defaultView);
      Logger.info('Request refundTicketLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request refundTicketLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async cancelLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('cancelLiveView, live view is disabled.')
        return;
      }
      Logger.info('cancelLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = TrainLiveViewController.defaultView.sequence;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return;
      }
      if (sequenceNow) {
        TrainLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      TrainLiveViewController.defaultView.liveViewData.primary.title =
        await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Train_cancel_title").id)
          + TrainLiveViewController.trainNumber;
      TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
        await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.HEAVY_SNOW);
      //update liveView
      Logger.info('Request cancelLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(TrainLiveViewController.defaultView);
      Logger.info('Request cancelLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request cancelLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async suspendLiveView(): Promise<boolean> {
    try {
      //live view is disabled
      if (!await TrainLiveViewController.isLiveViewEnabled() || !TrainLiveViewController.defaultView) {
        Logger.warn('suspendLiveView, live view is disabled.')
        return false;
      }
      if (TrainLiveViewController.nowStatus < LiveViewStatus.SET_OFF ||
        TrainLiveViewController.nowStatus > LiveViewStatus.SET_OFF_CONTINUE) {
        Logger.warn('suspendLiveView failed, train is not running.')
        return false;
      }
      Logger.info('suspendLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = TrainLiveViewController.defaultView.sequence;
      TrainLiveViewController.defaultView = await TrainLiveViewController.buildDefaultView();
      if(!TrainLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      if (sequenceNow) {
        TrainLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      TrainLiveViewController.nowStatus = TrainLiveViewController.nowStatus - 1;
      TrainLiveViewController.defaultView.liveViewData.primary.title = await TrainLiveViewController.resourceManager
        .getStringValue($r("app.string.Set_off_break_title").id);
      TrainLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Set_off_break_content1").id),
        },
        {
          text: await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Set_off_break_content2").id),
          textColor: TrainLiveViewController.contentColor
        },
        {
          text: await TrainLiveViewController.resourceManager
            .getStringValue($r("app.string.Set_off_break_content3").id),
        }
      ];
      TrainLiveViewController.defaultView.liveViewData.primary.layoutData =
        await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW);
      TrainLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_train.png',
        backgroundColor: TrainLiveViewController.capsuleColor,
        title: await TrainLiveViewController.resourceManager
          .getStringValue($r("app.string.Set_off_break_capsule_title").id)
      }
      //update liveView
      Logger.info('Request suspendLiveView req: %{public}s', JSON.stringify(TrainLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(TrainLiveViewController.defaultView);
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
        id: 2, // liveView ID, generated by the developer
        event: "TRAIN", // application scenarios of liveView：TRAIN。
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        liveViewData: {
          primary: {
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_title").id) +
            TrainLiveViewController.trainNumber,
            content: [
              { text: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_content1").id) },
              {
                text: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_content2").id),
                textColor: TrainLiveViewController.contentColor
              },
              { text: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_content3").id) },
              {
                text: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_content4").id),
                textColor: TrainLiveViewController.contentColor
              }
            ], // all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('TrainDeparture'),
            layoutData: await TrainLiveViewController.buildLayoutDate(CustomerWeatherType.SUNNY),
            backgroundType: CommonUtil.setFlightBackground(TrainLiveViewController.flightBackGroundType),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'icon_rail.png',
              clickAction: await ContextUtil.buildWantAgent('TrainDeparture')
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_train.png',
            backgroundColor: TrainLiveViewController.capsuleColor,
            title: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_capsule_title").id),
          }
        }
      }
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('BuildDefaultView Failed: %{public}d %{public}s', err.code, err.message);
      return undefined;
    }
  }

  private static async buildLayoutDate(weatherType: CustomerWeatherType): Promise<liveViewManager.FlightLayout | undefined>{
    try {
      return {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_FLIGHT,
        firstTitle: TrainLiveViewController.trainStartTime,
        firstContent: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_first_content").id),
        lastTitle: TrainLiveViewController.trainStopTime,
        lastContent: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_last_content").id),
        spaceIcon: 'train.png',
        isHorizontalLineDisplayed: false,
        additionalText: await TrainLiveViewController.resourceManager.getStringValue($r("app.string.Depart_layout_text").id), // 扩展区底部内容，仅可用于左右文本模板。
        weatherInfo: CommonUtil.setWeather(weatherType)
      }
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('BuildDefaultView Failed: %{public}d %{public}s', err.code, err.message);
      return undefined;
    }
  }
}

enum LiveViewStatus {
  DEPART = 1, //plan to depart
  PASSED_SECURITY_CHECK = 2, //checked and inspected
  TICKET_CHECK = 3, //ticket checking reminder
  CHECKED = 4, //ticket checked
  CHECK_IN_CLOSED = 5, //stop ticket checking
  SET_OFF = 6, //already departed
  SET_OFF_CONTINUE = 7, //train departure
  ARRIVED = 8, //arrived
  TRAIN_DELAY = 0, //train delay
  RESCHEDULE = 0, //user rescheduling
  TRAIN_CANCEL = 9, //train shutdown
  REFUND_TICKET = 10, //refund ticket
}

