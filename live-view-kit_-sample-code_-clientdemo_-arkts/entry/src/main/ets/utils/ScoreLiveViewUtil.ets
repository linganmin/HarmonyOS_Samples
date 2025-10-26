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

export class ScoreLiveViewController {
  private static defaultView: liveViewManager.LiveView | undefined = undefined;
  private static comDescColor: string = '#FFFF0000';
  private static contentColor: string = '#f7b7b1b3';
  private static capsuleColor: string = '#FF308977';
  private static resourceManager = ContextUtil.applicationContext.resourceManager;
  private static nowStatus: number = 0;

  public async startLiveView(): Promise<boolean> {
    //live view is disabled
    if (!await ScoreLiveViewController.isLiveViewEnabled()) {
      Logger.warn('startLiveView, live view is disabled.')
      return false;
    }
    //initialize live window parameters
    ScoreLiveViewController.defaultView = await ScoreLiveViewController.buildDefaultView();
    if (!ScoreLiveViewController.defaultView) {
      Logger.warn('buildDefaultView Failed.')
      return false;
    }
    //start live view
    ScoreLiveViewController.nowStatus = LiveViewStatus.SECTION_ONE;
    try {
      Logger.info('Request startLiveView req: %{public}s', JSON.stringify(ScoreLiveViewController.defaultView));
      const result = await liveViewManager.startLiveView(ScoreLiveViewController.defaultView);
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
      if (!ScoreLiveViewController.defaultView) {
        Logger.warn('updateLiveView, live view is disabled.')
        return false;
      }
      Logger.info('updateLiveView, id: %{public}d', ScoreLiveViewController.defaultView.id);
      Logger.info('updateLiveView, get active live view succeed.');
      //update liveView parameters
      if (ScoreLiveViewController.defaultView.sequence) {
        ScoreLiveViewController.defaultView.sequence += 1;
      }
      ScoreLiveViewController.nowStatus += 1;
      switch (ScoreLiveViewController.nowStatus) {
        case LiveViewStatus.PROCESS_ONE:
          //process one
          ScoreLiveViewController.defaultView.timer = {};
          ScoreLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
            hostScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_one_layout_host_score").id)
          };
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_one_layout_host_score").id) +
              ' : ' +
              await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_guest_score").id)
          }
          break;
        case LiveViewStatus.PAUSED:
          //paused
          ScoreLiveViewController.defaultView.timer = {
            isPaused: true
          }
          ScoreLiveViewController.defaultView.liveViewData.primary.title =
            await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Paused_title").id);
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Score_capsule_pause").id)
          }
          break;
        case LiveViewStatus.PAUSED_END:
          //paused end
          ScoreLiveViewController.defaultView.timer = {
            isPaused: false
          }
          ScoreLiveViewController.defaultView.liveViewData.primary.title =
            await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_title").id);
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_one_layout_host_score").id) +
              ' : ' +
              await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_guest_score").id)
          }
          break;
        case LiveViewStatus.PROCESS_TWO:
          //process two
          ScoreLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
            guestScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_two_layout_guest_score").id)
          };
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_one_layout_host_score").id) +
              ' : ' +
              await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_two_layout_guest_score").id)
          }
          break;
        case LiveViewStatus.HALFTIME_BREAK:
          //halftime break
          ScoreLiveViewController.defaultView.timer = {
            time: 10 * 60 * 1000,
            isPaused: true
          };
          ScoreLiveViewController.defaultView.liveViewData.primary.title =
            await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Halftime_break_title").id);
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            title: await ScoreLiveViewController.resourceManager
              .getStringValue($r("app.string.Halftime_break_capsule_title").id)
          }
          break;
        case LiveViewStatus.SECTION_TWO:
          //the second section begins
          ScoreLiveViewController.defaultView.timer = {
            time: 0,
            isPaused: false
          };
          ScoreLiveViewController.defaultView.liveViewData.primary.title =
            await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_two_title").id);
          ScoreLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
            competitionDesc: [
              {
                text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Score_competition_desc").id),
                textColor: ScoreLiveViewController.comDescColor
              },
              {
                text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_two_layout_competition_desc").id)
              }
            ],
          };
          break;
        case LiveViewStatus.PROCESS_THREE:
          //process three
          ScoreLiveViewController.defaultView.timer = {};
          ScoreLiveViewController.defaultView.liveViewData.primary.layoutData = {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
            hostScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_host_score").id),
            guestScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_guest_score").id)
          };
          ScoreLiveViewController.defaultView.liveViewData.capsule = {
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_host_score").id) +
              ' : ' +
              await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_guest_score").id)
          }
          break;
        case LiveViewStatus.END:
          //the competition is over
          await this.stopLiveView();
          return false;
        default:
          //default processing, destroy the liveView
          await this.stopLiveView();
          return false;
      }
      //update liveView
      Logger.info('Request updateLiveView req: %{public}s', JSON.stringify(ScoreLiveViewController.defaultView));
      const result = await liveViewManager.updateLiveView(ScoreLiveViewController.defaultView);
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
      if (!await ScoreLiveViewController.isLiveViewEnabled() || !ScoreLiveViewController.defaultView) {
        Logger.warn('stopLiveView, live view is disabled.')
        return;
      }
      Logger.info('stopLiveView, get active live view succeed.');
      //update liveView parameters
      if (ScoreLiveViewController.defaultView.sequence) {
        ScoreLiveViewController.defaultView.sequence += 1;
      }
      ScoreLiveViewController.defaultView.timer = {
        time: 10 * 60 * 1000,
        isPaused: true
      };
      ScoreLiveViewController.defaultView.liveViewData.primary.title = await ScoreLiveViewController.resourceManager
        .getStringValue($r("app.string.Score_end_title").id);
      ScoreLiveViewController.defaultView.liveViewData.primary.layoutData = {
        layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
        hostScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_host_score").id),
        guestScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Process_three_layout_guest_score").id),
        competitionDesc: [
          {
            text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Score_competition_desc").id),
            textColor: ScoreLiveViewController.comDescColor
          },
          { text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_two_title").id) }
        ]
      };
      //destroy the liveView
      Logger.info('Request stopLiveView req: %{public}s', JSON.stringify(ScoreLiveViewController.defaultView));
      const result = await liveViewManager.stopLiveView(ScoreLiveViewController.defaultView);
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
        id: 4, // liveView ID, generated by the developer
        event: "SCORE", // application scenarios of liveView：SCORE
        sequence: 1,//serial number
        isMute: false,//is ringing reminder
        timer: {//liveView timer
          time: 0,
          isCountdown: false,
          isPaused: false
        },
        liveViewData: {
          primary: {
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_title").id),
            content: [
              {
                text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_content_text_one").id)
              },
              {
                text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_content_text_two").id),
                textColor: ScoreLiveViewController.contentColor
              },
              {
                text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_content_text_three").id)
              }
            ],// all text can only be set to one color. When textColor is not set, # FF000000 will be displayed by default
            keepTime: 15,
            clickAction: await ContextUtil.buildWantAgent('MatchScore'),
            layoutData: {//auxiliary area
              layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_SCORE,
              hostName: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_host_name").id),
              hostIcon: "score_firefox.png",
              hostScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_host_score").id),
              guestName: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_guest_name").id),
              guestIcon: "score_m.png",
              guestScore: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_guest_score").id),
              competitionDesc: [
                {
                  text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Score_competition_desc").id),
                  textColor: ScoreLiveViewController.comDescColor
                },
                {
                  text: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_competition_desc").id)
                }
              ],
              competitionTime: "${placeholder.timer}",
              isHorizontalLineDisplayed: true
            },
            extensionData: {//expansion Zone
              type: liveViewManager.ExtensionType.EXTENSION_TYPE_ICON,
              pic: 'icon_trophy.png',
              clickAction: await ContextUtil.buildWantAgent('MatchScore')
            }
          },
          capsule: {//capsule
            type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
            status: 1,
            icon: 'capsule_trophy.png',
            backgroundColor: ScoreLiveViewController.capsuleColor,
            title: await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_host_score").id) +
              ' : ' +
              await ScoreLiveViewController.resourceManager.getStringValue($r("app.string.Section_one_layout_guest_score").id)
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
  SECTION_ONE = 1, //the first section begins
  PROCESS_ONE = 2, //process one
  PAUSED = 3, //paused.
  PAUSED_END = 4, //paused end
  PROCESS_TWO = 5, //process two
  HALFTIME_BREAK = 6, //halftime break
  SECTION_TWO = 7, //the second section begins
  PROCESS_THREE = 8, //process three
  END = 9, //the competition is over
}

