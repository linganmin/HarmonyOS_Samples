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

export class MenuViewMode {
  private menus: Menu[] = [];

  constructor() {
    this.menus.push(new Menu($r('app.string.home'), $r('app.media.ic_public_home_filled')));
    this.menus.push(new Menu($r('app.string.finance'), $r('app.media.ic_financial_management')));
    this.menus.push(new Menu($r('app.string.life'), $r('app.media.ic_life')));
    this.menus.push(new Menu($r('app.string.message'), $r('app.media.ic_message')));
    this.menus.push(new Menu($r('app.string.mine'), $r('app.media.ic_my')));
  }

  getMenus(): Menu[] {
    return this.menus;
  }
}

export class Menu {
  /**
   * Menu title
   */
  private title: Resource;
  /**
   * Menu icon
   */
  private icon: Resource;

  constructor(title: Resource, icon: Resource) {
    this.title = title;
    this.icon = icon;
  }

  public getTitle(): Resource {
    return this.title;
  }

  public getIcon(): Resource {
    return this.icon
  }
}