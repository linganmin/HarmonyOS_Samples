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

import { abilityAccessCtrl, bundleManager, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';

const TAG = 'PermissionUtil'

export class PermissionUtil {
  private static locationPermission: Array<Permissions> =
    ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

  /**
   * Request location permission
   * @param context The context
   * @returns The request result
   */
  public static async requestLocationPermission(context: Context): Promise<boolean> {
    return new Promise<boolean>(async (resolve) => {
      try {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        let data: PermissionRequestResult =
          await atManager.requestPermissionsFromUser(context, PermissionUtil.locationPermission);
        let authResult: number = data.authResults[0];
        if (authResult === 0) {
          resolve(true);
          return;
        }
        resolve(false);
      } catch (err) {
        hilog.error(0x0000, TAG, `request location permission failed, errorCode：${err.code}`);
      }
    })
  }

  /**
   * 校验位置权限
   * @returns 校验结果
   */
  public static async hasLocationPermission(): Promise<boolean> {
    return new Promise<boolean>(async (resolve) => {
      try {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        let bundleFlag: bundleManager.BundleFlag = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
        let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlag);
        let tokenId = bundleInfo.appInfo.accessTokenId;
        let location: abilityAccessCtrl.GrantStatus =
          atManager.verifyAccessTokenSync(tokenId, 'ohos.permission.LOCATION');
        let approximatelyLocation: abilityAccessCtrl.GrantStatus =
          atManager.verifyAccessTokenSync(tokenId, 'ohos.permission.APPROXIMATELY_LOCATION');
        if (location === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED &&
          approximatelyLocation === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          resolve(true);
        } else {
          resolve(false);
        }
      } catch (err) {
        hilog.error(0x0000, TAG, `verify location permission failed, errorCode：${err.code}`);
      }
    });
  }
}