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

import { BasicDataSource, ProductIntroductionModel } from './BasicDataSource';

export class MidListDataSource extends BasicDataSource<ProductIntroductionModel> {
  private dataList: Array<ProductIntroductionModel> = [];

  public totalCount(): number {
    return this.dataList.length;
  }

  public getData(index: number): ProductIntroductionModel {
    return this.dataList[index];
  }

  public pushData(data: ProductIntroductionModel[]): void {
    this.dataList.push(...data);
    this.notifyDataAdd(this.dataList.length - 1);
  }

  public getProductData(): void {
    const productIntroductions: Array<ProductIntroductionModel> =
      [
        new ProductIntroductionModel('0', $r('sys.symbol.car_fill'), $r('app.string.car')),
        new ProductIntroductionModel('1', $r('sys.symbol.creditcard'), $r('app.string.wallet')),
        new ProductIntroductionModel('2', $r('sys.symbol.rectangle_4_group_1'), $r('app.string.jigsaw')),
        new ProductIntroductionModel('3', $r('sys.symbol.star_bookmark'), $r('app.string.favorite')),
        new ProductIntroductionModel('0', $r('sys.symbol.car_fill'), $r('app.string.car')),
        new ProductIntroductionModel('1', $r('sys.symbol.creditcard'), $r('app.string.wallet')),
        new ProductIntroductionModel('2', $r('sys.symbol.rectangle_4_group_1'), $r('app.string.jigsaw')),
        new ProductIntroductionModel('3', $r('sys.symbol.star_bookmark'), $r('app.string.favorite'))
      ];
    this.pushData(productIntroductions);
  }
}