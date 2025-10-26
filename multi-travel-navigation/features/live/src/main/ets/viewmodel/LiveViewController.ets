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
import { Want, wantAgent } from '@kit.AbilityKit';
import { Logger } from '@ohos/commons/Index';
import { LiveConstants } from '../constants/LiveConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class LiveViewController {
  private static defaultView = LiveViewController.buildDefaultView();

  /**
   * Start the live view.
   * @returns
   */
  public async startLiveView(): Promise<liveViewManager.LiveViewResult> {
    if (!await LiveViewController.isLiveViewEnabled()) {
      throw new Error('Live view is disabled.');
    } else {
      Logger.info('Live view success');
    }
    try {
      return await liveViewManager.startLiveView(await LiveViewController.defaultView);
    } catch (error) {
      throw new Error('Live view is disabled.');
    }
  }

  /**
   * Build the default live view.
   * @returns
   */
  // [Start build_default_view]
  private static async buildDefaultView(): Promise<liveViewManager.LiveView> {
    return {
      id: 0,
      event: 'PICK_UP',
      liveViewData: {
        primary: {
          title: 'The driver has taken the order',
          content: [
            {
              text: 'distance from you',
            },
            {
              text: '1 km',
              textColor: '#FF0A59F7'
            }
          ],
          keepTime: 15,
          clickAction: await LiveViewController.buildWantAgent(),
          layoutData: {
            layoutType: 4,
            underlineColor: '#00ffffff',
            title: 'Deep Space Gray · Question M7',
            content: 'Pard 123456',
            descPic: 'taxi.png'
          }
        },
        capsule: {
          type: 1,
          status: 1,
          icon: 'navigate.png',
          backgroundColor: '#FF0A59F7',
          title: '1 km'
        }
      }
    };
  }

  // [End build_default_view]
  /**
   * Judge if the live view in enabled.
   * @returns
   */
  private static async isLiveViewEnabled(): Promise<boolean> {
    try {
      return await liveViewManager.isLiveViewEnabled();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'LiveViewController',
        `isLiveViewEnabled failed, error code=${err.code}, message=${err.message}`);
      return false;
    }
  }

  /**
   * Build the want agent.
   * @returns
   */
  private static async buildWantAgent(): Promise<Want | undefined> {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: LiveConstants.BUNDLE_NAME,
          abilityName: LiveConstants.ABILITY_NAME,
        } as Want
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      return agent;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'LiveViewController', `getWantAgent failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  /**
   * Stop the live view.
   * @returns
   */
  public async stopLiveView() {
    if (!LiveViewController.isLiveViewEnabled()) {
      throw new Error('Live view is disabled.');
    }
    liveViewManager.stopLiveView(await LiveViewController.defaultView).catch((err: BusinessError) => {
      hilog.error(0x0000, 'LiveViewController', `getWantAgent failed, error code=${err.code}, message=${err.message}`);
    });
  }
}

export default new LiveViewController();