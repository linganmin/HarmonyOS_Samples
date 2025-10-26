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
import { AppInfo } from './AppInfoModel'

export default class MockDataModel {
  private arrayAppInfo: Array<AppInfo> = [];

  constructor() {
    const huaweiCloud: AppInfo =
      new AppInfo('ic_app_icon_cloud_space.png', $r('app.string.cloud_space'), $r('app.string.cloud_space_description'));
    const huaweiEmail: AppInfo =
      new AppInfo('ic_app_icon_settings.png', $r('app.string.settings'), $r('app.string.settings_description'));
    const huaweiLiving: AppInfo =
      new AppInfo('ic_app_icon_phone.png', $r('app.string.phone'), $r('app.string.phone_description'));
    const huaweiShop: AppInfo =
      new AppInfo('ic_app_icon_v_mall.png', $r('app.string.v_mall'), $r('app.string.v_mall_description'));
    this.arrayAppInfo.push(huaweiCloud, huaweiEmail, huaweiLiving, huaweiShop);
  }

  public getArrayAppInfo(): Array<AppInfo> {
    return this.arrayAppInfo;
  }
}