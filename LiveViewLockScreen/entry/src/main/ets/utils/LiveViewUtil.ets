/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { Want, wantAgent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
// [Start createLiveView]
import { liveViewManager } from '@kit.LiveViewKit';
// [StartExclude createLiveView]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RouteData } from '../model/RouteDataModel';

const TAG: string = '[LiveViewUtil]';

export class LiveViewUtil {
  private context: Context;
  private defaultLiveView?: liveViewManager.LiveView;
  private sequence: number = 0;

  public constructor(context: Context) {
    this.context = context;
  }

  public async startLiveView(params: RouteData): Promise<void> {
    // Verify that the live view switch is turned on
    if (!await LiveViewUtil.isLiveViewEnabled()) {
      hilog.error(0x0000, TAG, '%{public}s', 'Live view is disabled.');
      return;
    }
    this.defaultLiveView = await this.createPrimaryLiveView();
    this.updateLiveViewInfo(params);

    try {
      await liveViewManager.startLiveView(this.defaultLiveView);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, '%{public}s',
        `Failed to start live view. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  public async updateLiveView(params: RouteData): Promise<boolean> {
    try {
      // live view is disabled or default view is not init
      if (!await LiveViewUtil.isLiveViewEnabled() || !this.defaultLiveView) {
        hilog.error(0x0000, TAG, '%{public}s', 'updateLiveView, live view is disabled.');
        return false;
      }
      this.updateLiveViewInfo(params);
      const result = await liveViewManager.updateLiveView(this.defaultLiveView);
      if (result) {
        hilog.info(0x0000, TAG, '%{public}s', 'updateLiveView.');
      }
      return true;
    } catch (error) {
      hilog.error(0x0000, TAG,
        `Failed to update live view. Cause code: ${(error as BusinessError).code}, message: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // [Start closeLiveView]
  // Close live view.
  public async closeLiveView() {
    // Ensure that the sequence is greater than the current live window page.
    this.sequence++;
    this.defaultLiveView = await this.createPrimaryLiveView();
    await liveViewManager.stopLiveView(this.defaultLiveView).then(() => {
      this.sequence = 0;
      this.defaultLiveView = undefined;
      hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in stopping liveView, result: %{public}');
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, '%{public}s',
        `Failed to stop liveView. Cause code: ${error.code}, message: ${error.message}`);
    });
    return;
  }

  // [End closeLiveView]

  private static async isLiveViewEnabled(): Promise<boolean> {
    try {
      liveViewManager.isLiveViewEnabled().then((isEnabled: boolean) => {
        hilog.info(0x0000, TAG, '%{public}s',
          'Succeeded in checking whether liveView is enabled.');
        return isEnabled;
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, '%{public}s',
          `Failed to check whether liveView is enabled. Cause code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, '%{public}s',
        `Failed to check whether liveView is enabled. Cause code: ${err.code}, message: ${err.message}`);
    }
    return true;
  }

  private updateLiveViewInfo(params: RouteData) {
    let liveView: liveViewManager.LiveView = this.defaultLiveView!;
    if (params) {
      liveView.sequence = this.sequence
      this.sequence++;
      liveView.liveViewData.capsule = {
        type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
        status: 1,
        icon: 'turn_right_light_square.png',
        backgroundColor: this.getStringSync($r('app.string.live_view_background').id),
        title: `${params.distance}${this.getStringSync($r('app.string.meter').id)}`,
      }
      liveView.liveViewData.primary.title =
        `${this.getStringSync($r('app.string.live_view_primary_title_first')
          .id)}${params.distance}${this.getStringSync($r('app.string.live_view_primary_title_second')
          .id)}`;
      liveView.liveViewData.primary.content =
        [{ text: this.getStringSync(params.roadName.id) }];
      liveView.liveViewData.primary.liveViewLockScreenAbilityName = 'LiveViewExtAbility';
      liveView.liveViewData.primary.liveViewLockScreenAbilityParameters = { '': '' };
      if (params.laneData.laneNum === 1) {
        liveView.liveViewData.primary.layoutData = {
          layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
          currentNavigationIcon: 'turn_straight_light_rectangle.png',
          navigationIcons: ['turn_straight_light_rectangle.png', 'turn_right_dark_rectangle.png']
        };
      } else {
        liveView.liveViewData.primary.layoutData = {
          layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_NAVIGATION,
          currentNavigationIcon: 'turn_right_light_rectangle.png',
          navigationIcons: ['turn_straight_dark_rectangle.png', 'turn_right_light_rectangle.png']
        }
      }
    }
    this.defaultLiveView = liveView;
  }

  private async createPrimaryLiveView(): Promise<liveViewManager.LiveView> {
    // [EndExclude createLiveView]
    // Construct live window request body.
    let liveView: liveViewManager.LiveView = {
      id: 0,
      sequence: this.sequence,
      // Application scenarios of the live window. NAVIGATION: Navigation.
      event: 'NAVIGATION',
      liveViewData: {
        // Live view capsule related parameters
        capsule: {
          type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
          status: 1,
          icon: 'turn_right_light_square.png',
          backgroundColor: this.getStringSync($r('app.string.live_view_background').id),
          title: this.getStringSync($r('app.string.live_view_title').id),
        },
        // Live view card related parameters
        primary: {
          title: this.getStringSync($r('app.string.live_view_title').id),
          content: [{ text: this.getStringSync($r('app.string.live_view_content').id) }],
          // Add LiveViewLockScreenExtensionAbility name to build lock screen live view
          liveViewLockScreenAbilityName: 'LiveViewExtAbility',
          liveViewLockScreenAbilityParameters: { liveViewParameters: '' },
          keepTime: 0,
          clickAction: await LiveViewUtil.buildWantAgent()
        }
      }
    };
    // [End createLiveView]
    return liveView;
  }

  private static async buildWantAgent(): Promise<Want | undefined> {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: 'com.example.mapliveviewsample',
        abilityName: 'EntryAbility'
      } as Want],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s',
        `Failed to build WantAgent. code: ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
      return undefined;
    }
  }

  private getStringSync(resId: number): string {
    let stringSyn: string = '';
    try {
      stringSyn = this.context.resourceManager.getStringSync(resId);
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s',
        `Get string failed. code: ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
    return stringSyn;
  }
}