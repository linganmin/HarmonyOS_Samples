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

export class IconInfoViewModel {
  private categoryList: IconInfo[] = [];
  private welfareList: IconInfo[] = [];
  constructor() {
    HomeConstants.GOOD_CATEGORIES.forEach((item: string, index: number) => {
      this.categoryList.push(new IconInfo(item, HomeConstants.GOOD_CATEGORY_IMG[index]));
    });
    HomeConstants.WELFARE_PRODUCTS.forEach((item: string, index: number) => {
      this.welfareList.push(new IconInfo(this.makeUpPrice(item), HomeConstants.WELFARE_PRODUCT_IMG[index]));
    });
  }

  getCategoryList(): IconInfo[] {
    return this.categoryList;
  }

  makeUpPrice(price: string): string {
    return HomeConstants.PRICE_UNIT[0] + price + HomeConstants.PRICE_UNIT[1];
  }

  getWelfareList(): IconInfo[] {
    return this.welfareList;
  }
}

export class IconInfo {
  /**
   * Info of the icon.
   */
  private info: string;
  /**
   * Icon image.
   */
  private icon: Resource;
  constructor(info: string, icon: Resource) {
    this.info = info;
    this.icon = icon;
  }

  getInfo(): string {
    return this.info;
  }

  getIcon(): Resource {
    return this.icon;
  }
}