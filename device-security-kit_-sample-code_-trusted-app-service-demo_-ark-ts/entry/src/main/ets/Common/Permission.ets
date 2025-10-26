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

class Permission {
  private cameraPermissions: Array<Permissions> = [
    'ohos.permission.CAMERA'
  ];
  private locationPermissions: Array<Permissions> = [
    'ohos.permission.LOCATION',
    'ohos.permission.APPROXIMATELY_LOCATION'
  ];

  private async checkPermission(permissions: Array<Permissions>): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const bundle = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const tokenId = bundle.appInfo.accessTokenId;
      const results = await Promise.all(permissions.map(permission => {
        return atManager.checkAccessToken(tokenId, permission);
      }));
      const grantStatus = results.some(result => result === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED)
        ? abilityAccessCtrl.GrantStatus.PERMISSION_DENIED
        : abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  public async checkCameraPermission(): Promise<boolean> {
    return this.checkPermission(this.cameraPermissions);
  }

  public async checkLocationPermission(): Promise<boolean> {
    return this.checkPermission(this.locationPermissions);
  }

  private async requestPermission(permissions: Array<Permissions>, UIContext: common.BaseContext): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const requestResults = await atManager.requestPermissionsFromUser(UIContext as common.UIAbilityContext, permissions);
      if (requestResults.authResults.some(result => result === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED)) {
        throw new Error('failed to request permission');
      }
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  public async requestCameraPermission(UIContext: common.BaseContext): Promise<void> {
    return this.requestPermission(this.cameraPermissions, UIContext);
  }

  public async requestLocationPermission(UIContext: common.BaseContext): Promise<void> {
    return this.requestPermission(this.locationPermissions, UIContext);
  }
}

export default new Permission();