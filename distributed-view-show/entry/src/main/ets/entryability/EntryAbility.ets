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

import { abilityAccessCtrl, AbilityConstant, bundleManager, Permissions, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { WindowUtil } from '../utils/WindowUtil';
import Logger from '../utils/Logger';

export default class EntryAbility extends UIAbility {
  contentStorage?: LocalStorage;

  onContinue(wantParam: Record<string, Object>) {
    Logger.info(wantParam.version.toString(), wantParam.targetDevice.toString());
    // Get and save the target device info
    AppStorage.setOrCreate<string>('targetDevice', wantParam.targetDevice.toString());

    // Preparing to Migrate Data
    let activeLive: number = AppStorage.get<number>('activeLive') as number;

    // Save the data to be migrated in the 'data' field of wantParam.
    wantParam['activeLive'] = activeLive;
    // Setting the Source End Not to Exit
    wantParam["ohos.extra.param.key.supportContinueSourceExit"] = false;

    Logger.info(activeLive.toString());
    return AbilityConstant.OnContinueResult.AGREE
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('Ability onCreate');
    if (want.parameters?.deviceId !== undefined) {
      AppStorage.setOrCreate<string>('targetDevice', want.parameters?.deviceId.toString());
    };
    this.checkPermissions();

    // If the invoking reason is migration, set the status to migratable to cope with cold start (ensuring migration continuity)
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        Logger.info(JSON.stringify(result));
      });
    }

    // Cold start of the application: Restore the saved migration data
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      // Restore migrated data from want
      let activeLive = want?.parameters?.activeLive;
      AppStorage.setOrCreate<number>('activeLive', activeLive as number);
      Logger.info(activeLive as string);
      // Explicit invocation of page restore
      this.contentStorage = new LocalStorage();
      Logger.info('Ability onCreate restoreWindowStage');
      try {
        this.context.restoreWindowStage(this.contentStorage);
      } catch (error) {
        Logger.error('Failed to restore window stage. Cause: ' + JSON.stringify(error));
      }
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info('Ability onCreate');
    if (want.parameters?.deviceId !== undefined) {
      AppStorage.setOrCreate<string>('targetDevice', want.parameters?.deviceId.toString());
    };

    // If the invoking reason is migration, set the status to migratable to cope with hot start (ensuring migration continuity)
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        Logger.info(JSON.stringify(result));
      });
    }

    //During the warm start of an application: Restore the saved migration data
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      // Restore migrated data from want
      let activeLive = want?.parameters?.activeLive;
      AppStorage.setOrCreate<number>('activeLive', activeLive as number);
      Logger.info(activeLive as string);
      // Explicit invocation of page restore
      this.contentStorage = new LocalStorage();
      Logger.info('Ability onNewWant restoreWindowStage');
      try {
        this.context.restoreWindowStage(this.contentStorage);
      } catch (error) {
        Logger.error('Failed to restore window stage. Cause: ' + JSON.stringify(error));
      }
    }
  }

  // Check permission granting and dynamically apply for permissions
  async checkPermissions(): Promise<void> {
    const permissions: Array<Permissions> = ['ohos.permission.DISTRIBUTED_DATASYNC'];

    let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permissions[0]);
    // Verifying Permission Granting
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // Granted
      Logger.info('Permission already granted.');
    } else {
      // Not granted. Dynamically apply for authorization in the dialog box displayed to the user
      let atManager = abilityAccessCtrl.createAtManager();
      try {
        atManager.requestPermissionsFromUser(this.context, ['ohos.permission.DISTRIBUTED_DATASYNC'], (err, data) => {
          Logger.info(JSON.stringify(data));
        });
      } catch (err) {
        Logger.error(JSON.stringify(err));
        return;
      }
    }
  }

  // Get the grant status of the current app's permissions
  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = -1;

    // Obtains the token ID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (err) {
      Logger.error(JSON.stringify(err));
    }

    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (err) {
      Logger.error(JSON.stringify(err));
    }
    return grantStatus;
  }

  onDestroy(): void {
    Logger.info('Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info('Ability onWindowStageCreate');

    windowStage.loadContent('pages/LivePage', (err) => {
      WindowUtil.requestFullScreen(windowStage, this.context);
      WindowUtil.updateStatusBarColor(this.context, true);
      if (err.code) {
        Logger.error(JSON.stringify(err) ?? '');
        return;
      }
      Logger.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info('Ability onWindowStageDestroy');
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    WindowUtil.requestFullScreen(windowStage, this.context);
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info('Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info('Ability onBackground');
  }
}