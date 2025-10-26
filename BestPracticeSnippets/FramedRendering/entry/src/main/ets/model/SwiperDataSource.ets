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

export class SwiperDataSource extends BasicDataSource<ProductIntroductionModel> {
  private dataList: Array<ProductIntroductionModel> = [];

  public totalCount(): number {
    return this.dataList.length;
  }

  public getData(index: number): ProductIntroductionModel {
    return this.dataList[index];
  }

  private pushData(data: ProductIntroductionModel[]): void {
    this.dataList.push(...data);
    this.notifyDataAdd(this.dataList.length - 1);
  }

  public getProductData(): void {
    if (this.dataList.length > 0) {
      return;
    }
    const productIntroductions: Array<ProductIntroductionModel> =
      [
        new ProductIntroductionModel('0', $r('sys.symbol.matebook_fill'), $r('app.string.computer')),
        new ProductIntroductionModel('1', $r('sys.symbol.smartscreen_fill'), $r('app.string.vision')),
        new ProductIntroductionModel('2', $r('sys.symbol.soundx_fill'), $r('app.string.sound_box')),
        new ProductIntroductionModel('3', $r('sys.symbol.phone_fill_1'), $r('app.string.mobile_phone')),
        new ProductIntroductionModel('4', $r('sys.symbol.earphone_case_16896'), $r('app.string.watches')),
        new ProductIntroductionModel('5', $r('sys.symbol.matebook_fill'), $r('app.string.computer')),
        new ProductIntroductionModel('6', $r('sys.symbol.smartscreen_fill'), $r('app.string.vision')),
        new ProductIntroductionModel('7', $r('sys.symbol.soundx_fill'), $r('app.string.sound_box')),
        new ProductIntroductionModel('8', $r('sys.symbol.phone_fill_1'), $r('app.string.mobile_phone')),
        new ProductIntroductionModel('9', $r('sys.symbol.earphone_case_16896'), $r('app.string.watches'))
      ];
    this.pushData(productIntroductions);
  }
}