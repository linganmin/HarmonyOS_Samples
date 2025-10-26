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
 * Initial Data of Application Package Information.
 */
export class AppInfoData {
  private appInfoItems: Array<AppInfoItem> = [];

  constructor() {
    const label: AppInfoItem = new AppInfoItem($r('app.string.app_name'), CommonConstants.DEFAULT_VALUE);
    const bundleName: AppInfoItem = new AppInfoItem($r('app.string.app_bundleName'), CommonConstants.DEFAULT_VALUE);
    const versionName: AppInfoItem = new AppInfoItem($r('app.string.version_name'), CommonConstants.DEFAULT_VALUE);
    const versionCode: AppInfoItem = new AppInfoItem($r('app.string.version_code'), CommonConstants.DEFAULT_VALUE);
    this.appInfoItems.push(label, bundleName, versionName, versionCode);
  }

  public getAppInfoItems(): Array<AppInfoItem> {
    return this.appInfoItems;
  }
}
