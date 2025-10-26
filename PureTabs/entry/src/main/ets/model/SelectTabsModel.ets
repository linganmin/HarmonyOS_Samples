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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import TabItemModel from './TabItemModel';
import StringUtil from '../common/utils/StringUtil';

export default class SelectTabsModel {
  allTabs: TabItemModel[] = [];

  async loadAllTabs(ctx: Context) {
    let filename = '';
    try {
      filename = await ctx.resourceManager.getStringValue($r('app.string.default_all_tabs_file').id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'SelectTabsModel', `getStringValue failed, error code=${err.code}, message=${err.message}`);
    }
    let result = await StringUtil.getStringFromRawFile(ctx, filename);
    this.allTabs = JSON.parse(result);
  }
}