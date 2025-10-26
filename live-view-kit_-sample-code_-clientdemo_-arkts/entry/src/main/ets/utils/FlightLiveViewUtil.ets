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

export class FlightLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static contentColor: string = '#FF0A59F7';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static flightNumber: string = '';
  private static flightStartTime: string = '';
  private static flightStopTime: string = '';
  private static flightBackGroundType: liveViewManager.BackgroundType =
    liveViewManager.BackgroundType.SYS_BACKGROUND_UNDEFINED;
  private static nowStatus: number = 1;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await FlightLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //start live view
    try {
      //initialize live window parameters
      FlightLiveViewController.flightNumber =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_number").id);
      FlightLiveViewController.flightStartTime =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_first_title").id);
      FlightLiveViewController.flightStopTime =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_last_title").id);
      FlightLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_SUNSET;
      FlightLiveViewController.nowStatus = LiveViewStatus.DEPART;
      FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
      if(!FlightLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }

      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(FlightLiveViewController.defaultView);
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
      if (!FlightLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', FlightLiveViewController.defaultView.id);
      //update liveView parameters
      if (FlightLiveViewController.defaultView.sequence) {
        FlightLiveViewController.defaultView.sequence += 1;
      }
      FlightLiveViewController.nowStatus += 1;
      switch (FlightLiveViewController.nowStatus) {
        case LiveViewStatus.DEPART:
          //plan to depart
          let sequenceNow = FlightLiveViewController.defaultView.sequence;
          FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
          if(!FlightLiveViewController.defaultView){
            Logger.warn('buildDefaultView Failed.')
            return false;
          }
          FlightLiveViewController.defaultView.sequence = sequenceNow;
          break;
        case LiveViewStatus.WAITING_FOR_CHECK_IN:
          //waiting for check-in
          FlightLiveViewController.defaultView.isMute = true;
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Waiting_for_check_in_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData =
            await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW2);
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Waiting_for_check_in_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Waiting_for_check_in_capsule_content").id)
          }
          break;
        case LiveViewStatus.CHECKED_IN:
          //checked in
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Checked_in_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Checked_in_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Checked_in_capsule_content").id)
          }
          break;
        case LiveViewStatus.PASSED_SECURITY_CHECK:
          //checked and inspected
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Passed_security_check_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Passed_security_check_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Checked_in_capsule_content").id)
          }
          break;
        case LiveViewStatus.START_BOARDING:
          //start boarding
          FlightLiveViewController.defaultView.isMute = false;
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Start_boarding_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData =
            await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.LIGHT_RAIN);
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Start_boarding_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Checked_in_capsule_content").id)
          }
          break;
        case LiveViewStatus.URGE_BOARDING:
          //urge boarding
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Urge_boarding_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Urge_boarding_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Checked_in_capsule_content").id)
          }
          break;
        case LiveViewStatus.BOARDED:
          //boarded already
          FlightLiveViewController.defaultView.isMute = true;
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Boarded_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Boarded_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Boarded_capsule_content").id),
          }
          break;
        case LiveViewStatus.END_BOARDING:
          //end boarding
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.End_boarding_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData =
            await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_RAIN);
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.End_boarding_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Boarded_capsule_content").id),
          }
          break;
        case LiveViewStatus.ABOUT_TO_TAKE_OFF:
          //about to take off
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.About_to_take_off_title").id) + FlightLiveViewController.flightNumber;
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.About_to_take_off_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.About_to_take_off_capsule_content").id)
          }
          break;
        case LiveViewStatus.TAKEN_OFF:
          //already taken off
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Taken_off_title").id);
          FlightLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await FlightLiveViewController.resourceManager
                .getStringValue($r("app.string.Taken_off_content1").id),
            },
            {
              text: await FlightLiveViewController.resourceManager
                .getStringValue($r("app.string.Taken_off_content2").id),
              textColor: FlightLiveViewController.contentColor
            },
            {
              text: await FlightLiveViewController.resourceManager
                .getStringValue($r("app.string.Taken_off_content3").id),
            }
          ];
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 0,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'transport_travel.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Taken_off_capsule_title").id),
            content: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.About_to_take_off_capsule_content").id)
          }
          break;
        case LiveViewStatus.ARRIVED:
          //arrived
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Flight_arrived_title").id);
          FlightLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await FlightLiveViewController.resourceManager
                .getStringValue($r("app.string.Flight_arrived_content").id)
            }
          ];
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 100,
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_UP,
            indicatorIcon: 'transport_travel.png',
            nodeIcons: [
              'icon_order.png',
              'icon_finish.png'
            ]
          };
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Flight_arrived_capsule_title").id),
            content: await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Flight_arrived_capsule_content").id),
          }
          break;
        case LiveViewStatus.LUGGAGE_PROMPT:
          //reminder luggage carousel
          FlightLiveViewController.defaultView.liveViewData.primary.title =
            await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Luggage_prompt_title").id);
          FlightLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Luggage_prompt_content1").id)
            },
            {
              text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Luggage_prompt_content2").id),
              textColor: FlightLiveViewController.contentColor
            },
          ];
          FlightLiveViewController.defaultView.liveViewData.primary.layoutData = await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.MODERATE_SNOW);
          FlightLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Luggage_prompt_capsule_title").id),
            content: await FlightLiveViewController.resourceManager
              .getStringValue($r("app.string.Flight_arrived_capsule_content").id),
          }
          break;
        case LiveViewStatus.FLIGHT_TRAVEL_END:
          //end reminder
          await this.stopLiveView();
          return false;
        default:
        //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView parameters
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(FlightLiveViewController.defaultView);
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
      if (!await FlightLiveViewController.isLiveViewEnabled() || !FlightLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      //update liveView parameters
      if (FlightLiveViewController.defaultView.sequence) {
        FlightLiveViewController.defaultView.sequence += 1;
      }
      FlightLiveViewController.defaultView.liveViewData.primary.title = await FlightLiveViewController.resourceManager
        .getStringValue($r("app.string.Flight_travel_end_title").id);
      FlightLiveViewController.defaultView.liveViewData.primary.content = [
        {
          text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_travel_end_content").id)
        },
      ];
      FlightLiveViewController.defaultView.liveViewData.primary.layoutData = await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.LIGHT_SNOW);
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(FlightLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async delayedLiveView(): Promise<Boolean> {
    try {
      //live view is disabled
      if (!await FlightLiveViewController.isLiveViewEnabled() || !FlightLiveViewController.defaultView) {
        Logger.warn('delayedLiveView, live view is disabled.')
        return false;
      }
      //update liveView parameters
      FlightLiveViewController.flightStartTime =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_first_title_two").id);
      FlightLiveViewController.flightStopTime =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_last_title_two").id);
      FlightLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_MOON;
      let sequenceNow = FlightLiveViewController.defaultView.sequence;
      FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
      if(!FlightLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      if (sequenceNow) {
        FlightLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      FlightLiveViewController.nowStatus = LiveViewStatus.FLIGHT_DELAY;
      FlightLiveViewController.defaultView.isMute = false;
      FlightLiveViewController.defaultView.liveViewData.primary.title =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_delay_title").id) +
        FlightLiveViewController.flightNumber;
      FlightLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        title: await FlightLiveViewController.resourceManager
          .getStringValue($r("app.string.Flight_delay_capsule_title").id),
        content: await FlightLiveViewController.resourceManager
          .getStringValue($r("app.string.Flight_delay_capsule_content").id),
      }
      //update liveView
      Logger.info('Request delayedLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(FlightLiveViewController.defaultView);
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
      if (!await FlightLiveViewController.isLiveViewEnabled() || !FlightLiveViewController.defaultView) {
        Logger.warn('rescheduleLiveView, live view is disabled.')
        return false;
      }
      //update liveView parameters
      if (await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_number").id) ==
      FlightLiveViewController.flightNumber) {
        FlightLiveViewController.flightNumber =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_number_two").id);
        FlightLiveViewController.flightStartTime =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_first_title_two").id);
        FlightLiveViewController.flightStopTime =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_last_title_two").id);
        FlightLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_MOON;
      } else {
        FlightLiveViewController.flightNumber =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_number").id);
        FlightLiveViewController.flightStartTime =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_first_title").id);
        FlightLiveViewController.flightStopTime =
          await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_last_title").id);
        FlightLiveViewController.flightBackGroundType = liveViewManager.BackgroundType.SYS_BACKGROUND_FLIGHT_SUNSET;
      }
      let sequenceNow = FlightLiveViewController.defaultView.sequence;
      FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
      if(!FlightLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return false;
      }
      if (sequenceNow) {
        FlightLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      FlightLiveViewController.nowStatus = LiveViewStatus.FLIGHT_RESCHEDULE;
      FlightLiveViewController.defaultView.liveViewData.primary.title =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Train_reschedule_title").id)
          + FlightLiveViewController.flightNumber;
      FlightLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'capsule_flight.png',
        backgroundColor: FlightLiveViewController.capsuleColor,
        title: await FlightLiveViewController.resourceManager
          .getStringValue($r("app.string.Train_reschedule_capsule_title").id),
        content: FlightLiveViewController.flightNumber.substring(3)
      }
      //update liveView
      Logger.info('Request rescheduleLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(FlightLiveViewController.defaultView);
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
      if (!await FlightLiveViewController.isLiveViewEnabled() || !FlightLiveViewController.defaultView) {
        Logger.warn('refundTicketLiveView, live view is disabled.')
        return;
      }
      Logger.info('refundTicketLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = FlightLiveViewController.defaultView.sequence;
      FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
      if(!FlightLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return;
      }
      if (sequenceNow) {
        FlightLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      FlightLiveViewController.defaultView.liveViewData.primary.layoutData = await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.LIGHT_RAIN);
      FlightLiveViewController.defaultView.liveViewData.primary.title =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_refund_ticket_title").id)
          + FlightLiveViewController.flightNumber;
      //destroy the liveView
      Logger.info('Request refundTicketLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(FlightLiveViewController.defaultView);
      Logger.info('Request refundTicketLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request refundTicketLiveView error: %{public}d %{public}s', err.code, err.message);
    }
  }

  public async cancelLiveView(): Promise<void> {
    try {
      //live view is disabled
      if (!await FlightLiveViewController.isLiveViewEnabled() || !FlightLiveViewController.defaultView) {
        Logger.warn('cancelLiveView, live view is disabled.')
        return;
      }
      Logger.info('cancelLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = FlightLiveViewController.defaultView.sequence;
      FlightLiveViewController.defaultView = await FlightLiveViewController.buildDefaultView();
      if(!FlightLiveViewController.defaultView){
        Logger.warn('buildDefaultView Failed.')
        return;
      }
      if(!FlightLiveViewController.defaultView){
        return;
      }
      if (sequenceNow) {
        FlightLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      FlightLiveViewController.defaultView.isMute = false;
      FlightLiveViewController.defaultView.liveViewData.primary.layoutData = await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.CLOUDY);
      FlightLiveViewController.defaultView.liveViewData.primary.title =
        await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_cancel_title").id)
          + FlightLiveViewController.flightNumber;
      //update liveView
      Logger.info('Request cancelLiveView req: %{public}s', JSON.stringify(FlightLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(FlightLiveViewController.defaultView);
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
      Logger.error('Request isLiveViewEnabled error: %{public}s', e);
    }
    Logger.info('Request isLiveViewEnabled result: %{public}s', result);
    return result;
  }

  private static async buildDefaultView(): Promise<liveViewManager.LiveView | undefined>{
    try {
      return {
        id: 6, //liveView ID, generated by the developer
        event: "FLIGHT", // application scenarios of liveView：FLIGHT。
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        liveViewData: {
          primary: {
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_title").id) +
            FlightLiveViewController.flightNumber,
            content: [
              {
                text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_content1").id)
              },
              {
                text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_content2").id),
                textColor: FlightLiveViewController.contentColor
              },
              {
                text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_content3").id)
              },
              {
                text: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_content4").id),
                textColor: FlightLiveViewController.contentColor
              }
            ], //all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('FlightTravel'),
            layoutData: await FlightLiveViewController.buildLayoutDate(CustomerWeatherType.SUNNY),
            backgroundType: CommonUtil.setFlightBackground(FlightLiveViewController.flightBackGroundType),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'flight.png',
              clickAction: await ContextUtil.buildWantAgent('FlightTravel')
            },
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_flight.png',
            backgroundColor: FlightLiveViewController.capsuleColor,
            title: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_capsule_title").id),
            content: FlightLiveViewController.flightNumber.substring(3)
          }
        }
      }
    }catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('BuildDefaultView Failed: %{public}d %{public}s', err.code, err.message);
      return undefined;
    }
  }

  private static async buildLayoutDate(weatherType: CustomerWeatherType): Promise<liveViewManager.FlightLayout | undefined>{
    try {
      return {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_FLIGHT,
        firstTitle: FlightLiveViewController.flightStartTime,
        firstContent: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_first_content").id),
        lastTitle: FlightLiveViewController.flightStopTime,
        lastContent: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_last_content").id),
        spaceIcon: "icon_plane.png",
        isHorizontalLineDisplayed: false,
        additionalText: await FlightLiveViewController.resourceManager.getStringValue($r("app.string.Flight_depart_layout_text").id),
        style: liveViewManager.FlightLayoutStyle.STYLE_FLIGHT_BALANCE,
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
  WAITING_FOR_CHECK_IN = 2, //waiting for check-in
  CHECKED_IN = 3, //checked in
  PASSED_SECURITY_CHECK = 4, //checked and inspected
  START_BOARDING = 5, //start boarding
  URGE_BOARDING = 6, //urge boarding
  BOARDED = 7, //boarded already
  END_BOARDING = 8, //end boarding
  ABOUT_TO_TAKE_OFF = 9, //about to take off
  TAKEN_OFF = 10, //already taken off
  ARRIVED = 11, //arrived
  LUGGAGE_PROMPT = 12, //reminder luggage carousel
  FLIGHT_TRAVEL_END = 13, //end reminder
  REFUND_TICKET = 14, //user ticket refund
  FLIGHT_CANCEL = 15, //flight cancellation
  FLIGHT_DELAY = 0, //flight delayed
  FLIGHT_RESCHEDULE = 0 //ticket changes
}

