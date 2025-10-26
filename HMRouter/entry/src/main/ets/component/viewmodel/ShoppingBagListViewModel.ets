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

import { ShoppingBagConstants } from '../common/constants/ShoppingBagConstants';

export class ShoppingBagListViewModel {
  private ShoppingBagList: ShoppingBagProduct[] = [];
  constructor() {
    ShoppingBagConstants.PRODUCT_NAME_LIST.forEach((item: string, index: number) => {
      this.ShoppingBagList.push(
        new ShoppingBagProduct(item, ShoppingBagConstants.PRODUCT_IMAGE_LIST[index],
          ShoppingBagConstants.PRODUCT_TYPE_LIST[index],
          ShoppingBagConstants.PRODUCT_STATUS_LIST[index], ShoppingBagConstants.PRODUCT_PRICE_LIST[index],
          ShoppingBagConstants.PRODUCT_ORIGINAL_PRICE_LIST[index], ShoppingBagConstants.PRODUCT_PRESENT_LIST[index],
          ShoppingBagConstants.PRODUCT_SERVICE_LIST[index]));
    });
  }

  getShoppingBagItemData(): ShoppingBagProduct[] {
    return this.ShoppingBagList;
  }
}

export class ShoppingBagProduct {
  private name: string;
  private image: Resource;
  private type: string;
  private preferentialList: Array<string>;
  private price: number;
  private originalPrice: number;
  private present: string;
  private service: string;
  constructor(name: string, image: Resource, type: string, preferentialList: Array<string>, price: number,
    originalPrice: number, present: string, service: string) {
    this.name = name;
    this.image = image;
    this.type = type;
    this.preferentialList = preferentialList;
    this.price = price;
    this.originalPrice = originalPrice;
    this.present = present;
    this.service = service;
  }

  getName(): string {
    return this.name;
  }

  getImage(): Resource {
    return this.image;
  }

  getType(): string {
    return this.type;
  }

  getPreferentialList(): Array<string> {
    return this.preferentialList;
  }

  getPrice(): number {
    return this.price;
  }

  getOriginalPrice(): number {
    return this.originalPrice;
  }

  getPresent(): string {
    return this.present;
  }

  getService(): string {
    return this.service;
  }
}

export class PreferenceDetailsList {
  private preferenceDetailsList: PreferenceDetails[] = [];
  constructor() {
    ShoppingBagConstants.PREFERENCE_DETAILS_TITLE.forEach((item, index) => {
      this.preferenceDetailsList.push(new PreferenceDetails(item,
        ShoppingBagConstants.PREFERENCE_DETAILS_PRICE[index]));
    });
  }

  getPreferenceDetailsList(): PreferenceDetails[] {
    return this.preferenceDetailsList;
  }
}

export class PreferenceDetails {
  private title: string;
  private price: string;
  constructor(title: string, price: string) {
    this.title = title;
    this.price = price;
  }

  getTitle(): string {
    return this.title;
  }

  getPrice(): string {
    return this.price;
  }
}