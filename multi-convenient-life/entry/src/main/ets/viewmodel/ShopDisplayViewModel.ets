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

import { ShopDisplayConstants } from '../constants/ShopDisplayConstants';

export class ShopInformation {
  private shopName: string = ShopDisplayConstants.SHOP_NAME;
  private shopRating: number = ShopDisplayConstants.SHOP_RATING;
  private shopProfile: string = ShopDisplayConstants.SHOP_PROFILE;
  private shopRanking: string = ShopDisplayConstants.SHOP_RANKING;
  private shopAnnouncements: string = ShopDisplayConstants.SHOP_ANNOUNCEMENTS;
  private shopTags: string[] = ShopDisplayConstants.SHOP_TAGS;
  private shopImages: Resource = $r('app.media.shopPicture');

  getShopName(): string {
    return this.shopName;
  }

  getShopRating(): number {
    return this.shopRating;
  }

  getShopProfile(): string {
    return this.shopProfile;
  }

  getShopRanking(): string {
    return this.shopRanking;
  }

  getShopAnnouncements(): string {
    return this.shopAnnouncements;
  }

  getShopTags(): string[] {
    return this.shopTags;
  }

  getShopImages(): Resource {
    return this.shopImages;
  }
}


export class ShopMenuData {
  private menuList: ShopMenuItem[] = [];

  constructor() {
    ShopDisplayConstants.DISH_NAME_LIST.forEach((item, index) => {
      this.menuList.push(new ShopMenuItem(ShopDisplayConstants.DISH_NAME_LIST[index],
        ShopDisplayConstants.DISH_TAG_LIST[index],
        ShopDisplayConstants.DISH_PROFILE_LIST[index], ShopDisplayConstants.DISH_PRICE_LIST[index],
        ShopDisplayConstants.DISH_ORIGINAL_PRICE_LIST[index], ShopDisplayConstants.DISH_ADD_OR_CHOICE[index],
        ShopDisplayConstants.DISH_IMAGE_LIST[index]))
    })
  }

  getMenuList(): ShopMenuItem[] {
    return this.menuList;
  }
}

export class ShopMenuItem {
  private dishName: string;
  private dishTag: string;
  private dishProfile: string;
  private dishPrice: string;
  private dishOriginalPrice: string;
  private dishAddOrChoice: number;
  private dishImage: Resource;

  constructor(dishName: string, dishTag: string, dishProfile: string, dishPrice: string, dishOriginalPrice: string,
    dishAddOrChoice: number, dishImage: Resource) {
    this.dishName = dishName;
    this.dishTag = dishTag;
    this.dishProfile = dishProfile;
    this.dishPrice = dishPrice;
    this.dishOriginalPrice = dishOriginalPrice;
    this.dishAddOrChoice = dishAddOrChoice;
    this.dishImage = dishImage;
  }

  getDishName(): string {
    return this.dishName;
  }

  getDishTag(): string {
    return this.dishTag;
  }

  getDishProfile(): string {
    return this.dishProfile;
  }

  getDishPrice(): string {
    return this.dishPrice;
  }

  getDishOriginalPrice(): string {
    return this.dishOriginalPrice;
  }

  getDishAddOrChoice(): number {
    return this.dishAddOrChoice;
  }

  getDishImage(): Resource {
    return this.dishImage;
  }
}