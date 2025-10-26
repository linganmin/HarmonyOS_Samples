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
import {
  abilityAccessCtrl,
  AbilityConstant,
  common,
  ConfigurationConstant,
  Permissions,
  UIAbility,
  Want,
  WantAgent,
  wantAgent
} from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { JSON } from '@kit.ArkTS';

const DOMAIN = 0x0000;

const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE', 'ohos.permission.KEEP_BACKGROUND_RUNNING'];

export default class EntryAbility extends UIAbility {
  startContinuousTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.avscreencapturescreenrecord",
          abilityName: "com.example.avscreencapturescreenrecord.entryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_RECORDING, wantAgentObj).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in operation startBackgroundRunning.');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to operation startBackgroundRunning. %{public}s', JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to operation getWantAgent. %{public}s', JSON.stringify(err));
    });
  }

  stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      hilog.info(DOMAIN, 'testTag', 'Succeeded in operation stopBackgroundRunning.');
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to operation stopBackgroundRunning. %{public}s', JSON.stringify(err));
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `setColorMode fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // reqPermissionsFromUser(permissions, this.context);

    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] != 0) {
          return;
        }
      }
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to request permissions from user. %{public}s', JSON.stringify(err));
    })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    try {
      // [Start get_size]
      let displayInfo = display.getDefaultDisplaySync();
      // [End get_size]
      AppStorage.setOrCreate('displayInfo', displayInfo);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `getDefaultDisplaySync fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    this.stopContinuousTask()
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    this.startContinuousTask()
  }
}