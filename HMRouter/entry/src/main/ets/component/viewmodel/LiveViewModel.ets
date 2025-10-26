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

import { LiveConstants } from '../common/constants/LiveConstants';

export class LiveViewModel {
  private liveProductList: LiveProduct[] = [];
  constructor() {
    LiveConstants.LIVE_PRODUCT_NAME_LIST.forEach((item: string, index: number) => {
      this.liveProductList.push(new LiveProduct(item, LiveConstants.LIVE_PRODUCT_IMAGE_LIST[index],
        LiveConstants.LIVE_PRODUCT_PRICE_LIST[index], LiveConstants.LIVE_PRODUCT_INDEX_LIST[index]));
    });
  }

  getProductList(): LiveProduct[] {
    return this.liveProductList;
  }
}

export class LiveProduct {
  private name: string;
  private image: Resource;
  private price: string;
  private index: number;
  constructor(name: string, image: Resource, price: string, index: number) {
    this.name = name;
    this.image = image;
    this.price = price;
    this.index = index;
  }

  getName(): string {
    return this.name;
  }

  getImage(): Resource {
    return this.image;
  }

  getPrice(): string {
    return this.price;
  }

  getIndex(): number {
    return this.index;
  }
}