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

import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = 'RequestPermissionUtil';

export class RequestPermissionUtil {
  static async checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }

  static async checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await RequestPermissionUtil.checkPermissionGrant(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    } else {
      return false;
    }
  }

  static async openPermissionOnSetting(permissions: Permissions) {
    let context: common.UIAbilityContext | undefined = AppStorage.get('context');
    if (!context) {
      Logger.error(TAG, 'context is undefined');
      return false;
    }
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus[] =
      await atManager.requestPermissionOnSetting(context, [permissions]);
    if (grantStatus[0] === 0) {
      return true;
    } else {
      return false;
    }
  }

  static async reqPermissionsFromUser(permissions: Permissions): Promise<boolean> {
    let context: common.UIAbilityContext | undefined = AppStorage.get('context');
    if (!context) {
      Logger.error(TAG, 'context is undefined');
      return false;
    }
    let isGranted = await RequestPermissionUtil.checkPermissions(permissions);
    if (isGranted) {
      Logger.info(TAG, `${permissions}} is Granted`);
      return true;
    }
    Logger.info(TAG, `${permissions}} is not Granted`);
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      let permissionRequestResult = await atManager.requestPermissionsFromUser(context, [permissions]);
      let grantStatus: Array<number> = permissionRequestResult.authResults;
      if (grantStatus[0] === 0) {
        isGranted = true;
      } else {
        Logger.error(TAG, 'user is not granted MICROPHONE permission');
        isGranted = await RequestPermissionUtil.openPermissionOnSetting(permissions);
      }
      return isGranted;
    } catch (error) {
      Logger.error(TAG, `Failed to request permissions from user. Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
}