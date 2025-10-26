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

import CommonConstants from '../common/CommonConstants';
import { AppInfoItem } from './AppInfoItem';

/*
 * Initial Data of Application Package Information on the Native Side.w
 */
export class NativeAppInfoData {
  private nativeAppInfoItems: Array<AppInfoItem> = [];

  constructor() {
    const bundleName: AppInfoItem = new AppInfoItem($r('app.string.app_bundleName'), CommonConstants.DEFAULT_VALUE);
    const appId: AppInfoItem = new AppInfoItem(CommonConstants.APPID_TITLE, CommonConstants.DEFAULT_VALUE);
    const fingerprint: AppInfoItem = new AppInfoItem(CommonConstants.FINGERPRINT_TITLE, CommonConstants.DEFAULT_VALUE);
    const appIdentifier: AppInfoItem =
      new AppInfoItem(CommonConstants.APP_IDENTIFIER_TITLE, CommonConstants.DEFAULT_VALUE);
    this.nativeAppInfoItems.push(bundleName, appId, fingerprint, appIdentifier);
  }

  public getNativeAppInfoItems(): Array<AppInfoItem> {
    return this.nativeAppInfoItems;
  }
}