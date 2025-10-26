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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CyclingConstants } from '../constants/CyclingConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';
import { liveViewManager } from '@kit.LiveViewKit';
import { liveViewController } from '../liveview/LiveViewController';
import { LiveViewContext } from '../liveview/LiveViewContext';

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    const bundleName = this.context.abilityInfo.bundleName;
    const abilityName = this.context.abilityInfo.name;
    const liveViewContext: LiveViewContext = {
      want: {
        bundleName,
        abilityName
      },
    }

    let target: string = CyclingConstants.CYCLING_PAGE;
    try {
      const liveView = await liveViewManager.getActiveLiveView(liveViewController.getLiveViewEnvironment().id);
      liveViewController.rebuild(liveViewContext, liveView);
      const capsule = liveView.liveViewData.capsule as liveViewManager.TextCapsule;
      const title = capsule.title;
      if (title !== undefined && title.includes(CyclingConstants.DEFAULT_VIEW_RIDING)) {
        target = CyclingConstants.RIDDING_PAGE;
      }
      if (title !== undefined && title.includes(CyclingConstants.WAITING_PAYMENT_LAYOUT_TITLE)) {
        target = CyclingConstants.PAY_PAGE;
      }
    } catch (err) {
      Logger.warn('getActiveLiveView failed', err);
    }

    windowStage.loadContent(target, (err) => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      windowStage.getMainWindow((err: BusinessError, data) => {
        let errCode: number = err.code;
        if (errCode) {
          Logger.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
          return;
        }
        Logger.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));
      })
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
