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

import { ColumnTab } from '@ohos/commons/Index';
import { RouteConstants } from '../constants/RouteConstants';

export class TabViewModel {
  private tabList: ColumnTab[] = [];

  constructor(context: Context) {
    RouteConstants.TOPIC_LIST(context).forEach((item: string, index: number) => {
      this.tabList.push(new ColumnTab(item, '', RouteConstants.TOPIC_ICONS_SELECTED[index]));
    });
  }

  getTabList(): ColumnTab[] {
    return this.tabList;
  }
}