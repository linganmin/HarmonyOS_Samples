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

import { HomeConstants } from '../constants/HomeConstants';

export class FooterTabData {
  public tabList: FooterTab[] = [];

  constructor() {
    HomeConstants.FOOTER_TOPIC_LIST.forEach((item: string, index: number) => {
      this.tabList.push(new FooterTab(item, HomeConstants.FOOTER_TOPIC_ICONS[index],
        HomeConstants.FOOTER_TOPIC_ICONS_SELECTED[index]));
    });
  }
}

export class FooterTabDataEn {
  public tabList: FooterTab[] = [];

  constructor() {
    HomeConstants.FOOTER_TOPIC_LIST_EN.forEach((item: string, index: number) => {
      this.tabList.push(new FooterTab(item, HomeConstants.FOOTER_TOPIC_ICONS[index],
        HomeConstants.FOOTER_TOPIC_ICONS_SELECTED[index]));
    });
  }
}

export class FooterTab {
  /**
   * Name of the tab.
   */
  public name: string;
  /**
   * Icon of the tab.
   */
  public icon: Resource;
  /**
   * Icon selected.
   */
  public iconSelected: Resource;

  constructor(name: string, icon: Resource, iconSelected: Resource) {
    this.name = name;
    this.icon = icon;
    this.iconSelected = iconSelected;
  }
}