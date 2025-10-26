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

import { BasicDataSource, ProductDetailModel } from './BasicDataSource';

export class ProductDetailSource extends BasicDataSource<ProductDetailModel> {
  private dataList: Array<ProductDetailModel> = [];
  private itemId: number = 0;

  public totalCount(): number {
    return this.dataList.length;
  }

  public getData(index: number): ProductDetailModel {
    return this.dataList[index];
  }

  private pushData(data: ProductDetailModel[]): void {
    let startIndex: number = this.dataList.length === 0 ? 0 : this.dataList.length - 1;
    let endIndex: number = startIndex + data.length;
    this.dataList.push(...data);
    for (let i = startIndex; i < endIndex; i++) {
      this.notifyDataAdd(i);
    }
  }

  public getProductData(startIndex?: number, endIndex?: number): void {
    const productIntroductions: Array<ProductDetailModel> =
      [
        new ProductDetailModel(`${this.itemId}`, $r('app.string.product_title01'), $r('app.media.product01'),
          $r('app.string.product_des01'), $r('app.string.product_price01')),
        new ProductDetailModel(`${this.itemId + 1}`, $r('app.string.product_title02'), $r('app.media.product02'),
          $r('app.string.product_des02'), $r('app.string.product_price02')),
        new ProductDetailModel(`${this.itemId + 2}`, $r('app.string.product_title03'), $r('app.media.product03'),
          $r('app.string.product_des03'), $r('app.string.product_price03')),
        new ProductDetailModel(`${this.itemId + 3}`, $r('app.string.product_title04'), $r('app.media.product04'),
          $r('app.string.product_des04'), $r('app.string.product_price04')),
        new ProductDetailModel(`${this.itemId + 4}`, $r('app.string.product_title01'), $r('app.media.product01'),
          $r('app.string.product_des01'), $r('app.string.product_price01')),
        new ProductDetailModel(`${this.itemId + 5}`, $r('app.string.product_title02'), $r('app.media.product02'),
          $r('app.string.product_des02'), $r('app.string.product_price02')),
        new ProductDetailModel(`${this.itemId + 6}`, $r('app.string.product_title03'), $r('app.media.product03'),
          $r('app.string.product_des03'), $r('app.string.product_price03')),
        new ProductDetailModel(`${this.itemId + 7}`, $r('app.string.product_title04'), $r('app.media.product04'),
          $r('app.string.product_des04'), $r('app.string.product_price04')),
        new ProductDetailModel(`${this.itemId + 8}`, $r('app.string.product_title01'), $r('app.media.product01'),
          $r('app.string.product_des01'), $r('app.string.product_price01')),
        new ProductDetailModel(`${this.itemId + 9}`, $r('app.string.product_title02'), $r('app.media.product02'),
          $r('app.string.product_des02'), $r('app.string.product_price02'))
      ];
    this.itemId += 10;
    this.pushData(productIntroductions.slice(startIndex, endIndex));
  }
}