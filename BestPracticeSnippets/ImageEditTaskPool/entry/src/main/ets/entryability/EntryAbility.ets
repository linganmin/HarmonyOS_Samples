/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { UIAbility, abilityAccessCtrl, Permissions, Want, AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    hilog.info(0x0000, TAG, '%{public}s', `want: ${JSON.stringify(want)}`);
    hilog.info(0x0000, TAG, '%{public}s', `launchParam: ${JSON.stringify(launchParam)}`);
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    const permissions: Array<Permissions> = [
      'ohos.permission.WRITE_IMAGEVIDEO'
    ];
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, permissions, (err, data) => {
      if (err) {
        hilog.error(0x0000, TAG, 'Failed to requestPermission. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      } else {
        hilog.info(0x0000, TAG, 'Succeeded in requestPermission. Data: %{public}s',
          JSON.stringify(data) ?? '');
      }
    });

    let windowClass: window.Window;
    try {
      windowClass = windowStage.getMainWindowSync();
      windowClass.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, 'Failed to set window layout full screen. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      });
      let SystemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF'
      };
      windowClass.setWindowSystemBarProperties(SystemBarProperties).then(() => {
        hilog.info(0x0000, TAG, 'Succeeded in setting the system bar properties.');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Failed to set the system bar properties. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to get main window. Cause: %{public}s',
        JSON.stringify(err) ?? '');
    }

    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s',
          JSON.stringify(err) ?? '');
        return;
      }
      try {
        const uiContext = windowClass.getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
        let navigationBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        AppStorage.setOrCreate<number>('naviIndicatorHeight', uiContext.px2vp(navigationBarArea.bottomRect.height));
        AppStorage.setOrCreate<number>('statusBarHeight', uiContext.px2vp(area.topRect.height));
      } catch (err) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onBackground');
  }
}
