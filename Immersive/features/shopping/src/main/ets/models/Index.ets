/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { TAB_BAR_ICONS, TAB_BAR_ICONS_ACTIVE, TAB_BAR_TITLES } from '../constants/Index';

export interface TabBar {
  text: ResourceStr
  icon: ResourceStr
  activeIcon: ResourceStr
}

export function getTabBars(): TabBar[] {
  return TAB_BAR_TITLES.map((text, index) => {
    const tabBar: TabBar = {
      text,
      icon: TAB_BAR_ICONS[index],
      activeIcon: TAB_BAR_ICONS_ACTIVE[index]
    };
    return tabBar;
  });
}