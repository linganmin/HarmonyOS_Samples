/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HomeConstants } from '../common/constants/HomeConstants';

export class FooterTabViewModel {
  private tabList: FooterTab[] = [];
  constructor() {
    HomeConstants.FOOTER_TOPIC_LIST.forEach((item: string, index: number) => {
      this.tabList.push(new FooterTab(item, HomeConstants.FOOTER_TOPIC_ICONS[index],
        HomeConstants.FOOTER_TOPIC_ICONS_SELECTED[index]));
    });
  }

  getTabList(): FooterTab[] {
    return this.tabList;
  }
}

export class FooterTab {
  /**
   * Name of the tab.
   */
  private name: string;
  /**
   * Icon of the tab.
   */
  private icon: Resource;
  /**
   * Icon selected.
   */
  private iconSelected: Resource;
  constructor(name: string, icon: Resource, iconSelected: Resource) {
    this.name = name;
    this.icon = icon;
    this.iconSelected = iconSelected;
  }

  getName(): string {
    return this.name;
  }

  getIcon(): Resource {
    return this.icon;
  }

  getIconSelected(): Resource {
    return this.iconSelected;
  }
}