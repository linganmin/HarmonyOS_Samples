/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { abilityAccessCtrl, bundleManager } from '@kit.AbilityKit'
import { promptAction, UIContext } from '@kit.ArkUI';
import Logger from '../util/Logger';

const TAG: string = 'AbilityAccessCtrlController';


export default class AbilityAccessCtrlController {
  private UIContext: UIContext;

  constructor(UIContext: UIContext) {
    this.UIContext = UIContext;
  }

  // Checks whether the permission is granted to the application and returns the result asynchronously in Promise mode.
  // Corresponding to verifyPermission() of the FA model
  verifyAccessToken() {
    let AtManager = abilityAccessCtrl.createAtManager();
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    let bundledata;
    try {
      bundledata = bundleManager.getBundleInfoForSelfSync(bundleFlags);
    } catch (err) {
      Logger.info(TAG, `getBundleInfoForSelfSync error: ${err}`);
    }
    let tokenID = bundledata.appInfo.accessTokenId;
    try {
      let data: abilityAccessCtrl.GrantStatus =
        AtManager.verifyAccessTokenSync(tokenID, "ohos.permission.GRANT_SENSITIVE_PERMISSIONS");
      Logger.info(TAG, `verifyAccessTokenSync success, result: ${data}`);
      this.UIContext.getPromptAction().showToast({
        message: `promise: data: ${JSON.stringify(data)}`
      })
    } catch (err) {
      Logger.error(TAG, `verifyAccessTokenSync fail, code: ${err.code}, message: ${err.message}`);
    }
  }
}