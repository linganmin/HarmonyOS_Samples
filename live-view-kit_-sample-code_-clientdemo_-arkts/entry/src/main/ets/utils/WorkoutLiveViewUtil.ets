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

export class WorkoutLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static processColor: string = '#ff10c1f7';
  private static capsuleColor: string = '#FF60c560';
  private static underLineColor: string = '#FF0A59F7';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 1;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await WorkoutLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    WorkoutLiveViewController.defaultView = await WorkoutLiveViewController.buildDefaultView();
    if(!WorkoutLiveViewController.defaultView){
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start liveView
    WorkoutLiveViewController.nowStatus = LiveViewStatus.WORKOUT_START;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(WorkoutLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(WorkoutLiveViewController.defaultView);
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
      if (!WorkoutLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', WorkoutLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (WorkoutLiveViewController.defaultView.sequence) {
        WorkoutLiveViewController.defaultView.sequence += 1;
      }
      WorkoutLiveViewController.nowStatus += 1;
      switch (WorkoutLiveViewController.nowStatus) {
        case LiveViewStatus.WORKOUT_START:
          //start exercising
          WorkoutLiveViewController.defaultView.liveViewData.primary.title =
            await WorkoutLiveViewController.resourceManager
              .getStringValue($r("app.string.Workout_start_title").id);
          WorkoutLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content3").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_start_content").id),
              textColor: WorkoutLiveViewController.processColor
            },
            {
              text: ' | '
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
              textColor: WorkoutLiveViewController.processColor
            }
          ];
          WorkoutLiveViewController.defaultView.timer = {
            isPaused: false
          };
          WorkoutLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: false,
          }
          break;
        case LiveViewStatus.WORKOUT_PROCESS_ONE:
          //process one
          WorkoutLiveViewController.defaultView.liveViewData.primary.title =
            await WorkoutLiveViewController.resourceManager
              .getStringValue($r("app.string.Workout_start_title").id);
          WorkoutLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content3").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_process_one_content").id),
              textColor: WorkoutLiveViewController.processColor
            },
            {
              text: ' | '
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
              textColor: WorkoutLiveViewController.processColor
            }
          ];
          WorkoutLiveViewController.defaultView.timer = {
            isPaused: false
          };
          WorkoutLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: false,
          }
          break;
        case LiveViewStatus.WORKOUT_PROCESS_TWO:
          //process two
          WorkoutLiveViewController.defaultView.liveViewData.primary.title =
            await WorkoutLiveViewController.resourceManager
              .getStringValue($r("app.string.Workout_start_title").id);
          WorkoutLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content3").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_process_two_content").id),
              textColor: WorkoutLiveViewController.processColor
            },
            {
              text: ' | '
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
              textColor: WorkoutLiveViewController.processColor
            }
          ];
          WorkoutLiveViewController.defaultView.timer = {
            isPaused: false
          };
          WorkoutLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: false,
          }
          break;
        case LiveViewStatus.WORKOUT_PROCESS_THREE:
          //process three
          WorkoutLiveViewController.defaultView.liveViewData.primary.title =
            await WorkoutLiveViewController.resourceManager
              .getStringValue($r("app.string.Workout_start_title").id);
          WorkoutLiveViewController.defaultView.liveViewData.primary.content = [
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content3").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_process_three_content").id),
              textColor: WorkoutLiveViewController.processColor
            },
            {
              text: ' | '
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content").id)
            },
            {
              text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
              textColor: WorkoutLiveViewController.processColor
            }
          ];
          WorkoutLiveViewController.defaultView.timer = {
            isPaused: false
          };
          WorkoutLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            isPaused: false,
          }
          break;
        case LiveViewStatus.WORKOUT_END:
          //end of exercise
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(WorkoutLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(WorkoutLiveViewController.defaultView);
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
      if (!await WorkoutLiveViewController.isLiveViewEnabled() || !WorkoutLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (WorkoutLiveViewController.defaultView.sequence) {
        WorkoutLiveViewController.defaultView.sequence += 1;
      }
      WorkoutLiveViewController.defaultView.liveViewData.primary.title = await WorkoutLiveViewController.resourceManager
        .getStringValue($r("app.string.Workout_end_title").id);
      WorkoutLiveViewController.defaultView.liveViewData.primary.content = [
        { text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_end_content").id) },
        {
          text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
          textColor: WorkoutLiveViewController.processColor
        }
      ];
      WorkoutLiveViewController.defaultView.timer = {
        isPaused: true
      };
      WorkoutLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
        status: 1,
        isPaused: true,
      }
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(WorkoutLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(WorkoutLiveViewController.defaultView);
      Logger.info('Request stopLiveView result: %{public}s', JSON.stringify(result));
    } catch (e) {
      const err: BusinessError = e as BusinessError;
      Logger.error('Request stopLiveView error: %{public}s', err.message);
    }
  }

  public async suspendLiveView(): Promise<boolean> {
    try {
      //live view is disabled
      if (!await WorkoutLiveViewController.isLiveViewEnabled() || !WorkoutLiveViewController.defaultView) {
        Logger.warn('suspendLiveView, live view is disabled.')
        return false;
      }
      if (WorkoutLiveViewController.nowStatus >= LiveViewStatus.WORKOUT_END) {
        Logger.warn('suspendLiveView failed, workout is not running.')
        return false;
      }
      Logger.info('suspendLiveView, get active live view succeed.');
      //update liveView parameters
      let sequenceNow = WorkoutLiveViewController.defaultView.sequence;
      if (sequenceNow) {
        WorkoutLiveViewController.defaultView.sequence = sequenceNow + 1;
      }
      WorkoutLiveViewController.nowStatus = WorkoutLiveViewController.nowStatus - 1;
      WorkoutLiveViewController.defaultView.liveViewData.primary.title = await WorkoutLiveViewController.resourceManager
        .getStringValue($r("app.string.Workout_suspend_title").id);
      WorkoutLiveViewController.defaultView.timer = {
        isPaused: true
      };
      WorkoutLiveViewController.defaultView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
        status: 1,
        isPaused: true,
      }
      //update liveView
      Logger.info('Request suspendLiveView req: %{public}s', JSON.stringify(WorkoutLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(WorkoutLiveViewController.defaultView);
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
        id: 9, // liveView ID, generated by the developer
        event: "WORKOUT", // application scenarios of liveView：WORKOUT
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        timer: {//liveView timer
          time: 0,
          isCountdown: false,
          isPaused: false
        },
        liveViewData: {
          primary: {
            title: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_start_title").id),
            content: [
              {
                text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content3").id)
              },
              {
                text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_start_content").id),
                textColor: WorkoutLiveViewController.processColor
              },
              {
                text: ' | '
              },
              {
                text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content").id)
              },
              {
                text: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_content2").id),
                textColor: WorkoutLiveViewController.processColor
              }
            ],//all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('Workout'),
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'sport_extension.png',
              clickAction: await ContextUtil.buildWantAgent('Workout')
            },
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP,
              title: await WorkoutLiveViewController.resourceManager.getStringValue($r("app.string.Workout_start_layout_title").id),
              content: "${placeholder.timer}",
              underlineColor: WorkoutLiveViewController.underLineColor,
              descPic: 'workout.png'
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER,
            status: 1,
            icon: 'capsule_workout.png',
            backgroundColor: WorkoutLiveViewController.capsuleColor,
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
  WORKOUT_START = 1, //start exercising
  WORKOUT_PROCESS_ONE = 2, //process one
  WORKOUT_PROCESS_TWO = 3, //process two
  WORKOUT_PROCESS_THREE = 4, //process three
  WORKOUT_END = 5, //end of exercise
}

