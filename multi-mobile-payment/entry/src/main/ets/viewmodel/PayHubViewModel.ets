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

import { Constants } from '../common/Constants';

export class PayHubViewModel {
  private functions: Array<QuickFunctionItem> = [];
  private moreFunction: QuickFunctionItem = new QuickFunctionItem($r('app.media.ic_more'),
    $r('app.string.more'));

  constructor() {
    this.functions.push(new QuickFunctionItem($r('app.media.fund_investment'), $r('app.string.fund_investment')));
    this.functions.push(new QuickFunctionItem($r('app.media.wealth_management_products'),
      $r('app.string.fund_investment')));
    this.functions.push(new QuickFunctionItem($r('app.media.credit_card'), $r('app.string.credit_card')));
    this.functions.push(new QuickFunctionItem($r('app.media.bill'), $r('app.string.bill')));
    this.functions.push(new QuickFunctionItem($r('app.media.speed_gain'), $r('app.string.speedy_earnings')));
    this.functions.push(new QuickFunctionItem($r('app.media.precious_metals'), $r('app.string.precious_metal')));
    this.functions.push(new QuickFunctionItem($r('app.media.deposit_products'), $r('app.string.deposit_product')));
    this.functions.push(new QuickFunctionItem($r('app.media.payment_fees'), $r('app.string.payment')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
    this.functions.push(new QuickFunctionItem($r('app.media.quick_loan'), $r('app.string.quick_loan')));
  }


  getFunctionsByBreakpoints(bp: string): Array<QuickFunctionItem> {
    if (bp === Constants.BREAKPOINTS[0]) {
      return [...this.functions.slice(0, 7), this.moreFunction]
    } else if (bp === Constants.BREAKPOINTS[1]) {
      return [...this.functions.slice(0, 11), this.moreFunction]
    } else {
      return [...this.functions, this.moreFunction];
    }
  }
}

export class QuickFunctionItem {
  /**
   * Quick function icon
   */
  private img: Resource;
  /**
   * Quick function name
   */
  private text: Resource;
  /**
   * Quick function click function
   */
  private clickCallback: Function;

  constructor(img: Resource, text: Resource, clickCallback: Function = () => {
  }) {
    this.img = img;
    this.text = text;
    this.clickCallback = clickCallback;
  }

  public setClickCallback(func: Function) {
    this.clickCallback = func;
  }

  public getImg() {
    return this.img;
  }

  public getText() {
    return this.text;
  }

  public getClickCallback() {
    return this.clickCallback;
  }
}