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

export class SectionProductsViewModel {
  private sectionProductList: SectionProduct[] = [];
  private flashSaleProductList: SectionProduct[] = [];
  constructor() {
    HomeConstants.SECTION_PRODUCT_IMAGES.forEach((item: Resource, index: number) => {
      this.sectionProductList.push(new SectionProduct(item, HomeConstants.SECTION_PRODUCTS_TITLES[index],
        HomeConstants.SECTION_PRODUCTS_PRICES[index], HomeConstants.SECTION_PRODUCTS_FEATURES[index],
        HomeConstants.SECTION_PRODUCTS_COMMENTS, HomeConstants.SECTION_PRODUCTS_INFO[index]));
    });
    HomeConstants.FLASH_SALE_PRODUCT_IMAGES.forEach((item: Resource, index: number) => {
      this.flashSaleProductList.push(new SectionProduct(item, HomeConstants.FLASH_SALE_PRODUCT_TITLES[index],
        HomeConstants.FLASH_SALE_PRODUCT_PRICES[index], HomeConstants.FLASH_SALE_PRODUCT_FEATURES[index], '',
        HomeConstants.FLASH_SALE_PRODUCT_INFO[index], HomeConstants.FLASH_SALE_PRODUCT_ORIGINAL_PRICES[index]));
    });
  }

  getSectionProductList(): SectionProduct[] {
    return this.sectionProductList;
  }

  getFlashSaleProductList(): SectionProduct[] {
    return this.flashSaleProductList;
  }
}

export class SectionProduct {
  private productImg: Resource;
  private title: string[];
  private price: string;
  private feature: string[];
  private comments: string;
  private info: string;
  private originalPrice?: string;
  constructor(productImg: Resource, title: string[], price: string, feature: string[], comments: string, info: string,
    originalPrice?: string) {
    this.productImg = productImg;
    this.title = title;
    this.price = price;
    this.feature = feature;
    this.comments = comments;
    this.info = info;
    if(originalPrice !== undefined) {
      this.originalPrice = originalPrice;
    }
  }

  getProductImg(): Resource {
    return this.productImg;
  }

  getTitle(): string[] {
    return this.title;
  }

  getPrice(): string {
    return this.price;
  }

  getFeature(): string[] {
    return this.feature;
  }

  getComments(): string {
    return this.comments;
  }

  getInfo(): string {
    return this.info;
  }

  getOriginalPrice(): string | undefined {
    return this.originalPrice;
  }
}