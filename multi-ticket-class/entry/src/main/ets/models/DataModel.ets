/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

export class ShareIndex {
  title: ResourceStr;
  index: string;
  priceLimit: string;

  constructor(title: ResourceStr, index: string, priceLimit: string) {
    this.title = title;
    this.index = index;
    this.priceLimit = priceLimit;
  }
}

export class StockForm {
  title: ResourceStr; // Stock Name
  stockNumber: ResourceStr; // Stock Number
  latestPrice: number; // Latest Price
  highsAndLows: number; // HighLow
  priceLimit: ResourceStr; // Price Limit
  gross: ResourceStr; // Gross
  impressions: ResourceStr; // Impressions
  plate: ResourceStr // Stock sector
  plateFontColor: ResourceColor; // Font color of the stock section
  plateBackgroundColor: ResourceColor; // Background color of the stock section
  volumeTransaction: ResourceStr; // volume of transaction
  amplitude: ResourceStr; // Amplitude
  changeHands: ResourceStr; // Change Hands
  PEG: number; // P/E ratio (price-to-earnings ratio)
  PB: number; // PB(price/book value ratio)

  constructor(title: ResourceStr, stockNumber: ResourceStr, latestPrice: number, highsAndLows: number,
    priceLimit: ResourceStr, gross: ResourceStr, impressions: ResourceStr, plate: ResourceStr,
    plateFontColor: ResourceColor, plateBackgroundColor: ResourceColor, volumeTransaction: ResourceStr,
    amplitude: ResourceStr, changeHands: ResourceStr, PEG: number, PB: number) {
    this.title = title;
    this.stockNumber = stockNumber;
    this.latestPrice = latestPrice;
    this.highsAndLows = highsAndLows;
    this.priceLimit = priceLimit;
    this.gross = gross;
    this.impressions = impressions;
    this.plate = plate;
    this.plateFontColor = plateFontColor;
    this.plateBackgroundColor = plateBackgroundColor;
    this.volumeTransaction = volumeTransaction;
    this.amplitude = amplitude;
    this.changeHands = changeHands;
    this.PEG = PEG;
    this.PB = PB;
  }
}

export class StockInForm {
  title1: ResourceStr;
  value1: ResourceStr;
  color1: ResourceStr;
  title2: ResourceStr;
  value2: ResourceStr;
  color2: ResourceStr;
  title3: ResourceStr;
  value3: ResourceStr;
  color3: ResourceStr;

  constructor(
    title1: ResourceStr, value1: ResourceStr, color1: ResourceStr,
    title2: ResourceStr, value2: ResourceStr, color2: ResourceStr,
    title3: ResourceStr, value3: ResourceStr, color3: ResourceStr
  ) {
    this.title1 = title1;
    this.value1 = value1;
    this.color1 = color1;
    this.title2 = title2;
    this.value2 = value2;
    this.color2 = color2;
    this.title3 = title3;
    this.value3 = value3;
    this.color3 = color3;
  }
}

export class transactionDetails {
  title: ResourceStr;
  price: string;
  amount: number;

  constructor(title: ResourceStr, price: string, amount: number) {
    this.title = title;
    this.price = price;
    this.amount = amount;
  }
}

export const SHARE_INDEX: ShareIndex[] = [
  new ShareIndex($r('app.string.certain_index'), '3088.10', '+19.8 +0.64%'),
  new ShareIndex($r('app.string.deep_number'), '3088.10', '+19.8 -0.64%'),
  new ShareIndex($r('app.string.science_technology'), '3088.10', '+19.8 +0.64%'),
  new ShareIndex($r('app.string.certain_index'), '3088.10', '+19.8 -0.64%'),
  new ShareIndex($r('app.string.deep_number'), '3088.10', '+19.8 +0.64%')
];

export const STOCK_FORM: StockForm[] = [
  new StockForm($r('app.string.somebody_technology'), '60**39', 904, +0.04, '+0.53%', '310511', '1232',
    $r('app.string.securities_margin_trading'), '#9801FF', '#F4E3FD', '12.5', '8.88%', '18.81%', 123, 1.5),
  new StockForm($r('app.string.certain_estate_company'), '60**19', 182104, +3.04, '+0.19%', '30176', '550',
    $r('app.string.securities_margin_trading'), '#9801FF', '#F4E3FD', '15.5', '8.98%', '15.81%', 112, 1.1),
  new StockForm($r('app.string.certain_pharmaceutical_company'), '30**89', 1520, -0.16, '-1.04%', '19593', '3461',
    $r('app.string.growth_enterprise_market'), '#FF5501', '#FFEEE5', '13.5', '6.58%', '19.81%', 116, 1.9),
  new StockForm($r('app.string.somebody_technology'), '60**99', 2001, +3.04, '+0.19%', '7071', '4890',
    $r('app.string.securities_margin_trading'), '#9801FF', '#F4E3FD', '10.5', '8.86%', '13.81%', 105, 1.5),
  new StockForm($r('app.string.certain_estate_company'), '30**59', 2432, -0.16, '-1.04%', '6953', '1321',
    $r('app.string.growth_enterprise_market'), '#FF5501', '#FFEEE5', '19.9', '6.88%', '12.81%', 108, 1.2)
];

export const STOCK_INFORM_LIST: StockInForm[] = [
  new StockInForm($r('app.string.now_begins'), '19.86', '#FA4337', $r('app.string.yesterday_close'), '19.84', '#000000',
    $r('app.string.turnover_rate'), '0.39%', '#000000'),
  new StockInForm($r('app.string.tallest'), '19.86', '#FA4337', $r('app.string.lowest'), '19.84', '#1DB775',
    $r('app.string.PEG'), '95.32', '#000000'),
  new StockInForm($r('app.string.turnover'), $r('app.string.text_hands'), '#000000',
    $r('app.string.volume_transaction'), $r('app.string.turnover_value'), '#000000', $r('app.string.total_value'),
    $r('app.string.text_billion'), '#000000'),
  new StockInForm($r('app.string.now_begins'), '19.86', '#FA4337', $r('app.string.yesterday_close'), '19.84', '#000000',
    $r('app.string.turnover_rate'), '0.39%', '#000000')
];

export const CYCLE_TITLE: ResourceStr[] = [
  $r('app.string.time_share'), $r('app.string.five_days'), $r('app.string.daily_k'), $r('app.string.week_k'),
  $r('app.string.month_k'), $r('app.string.season_k'), $r('app.string.half_year_k'), $r('app.string.year_k')
];

export const OTHER_TITLE: ResourceStr[] = [
  $r('app.string.discussion'), $r('app.string.must_read'), $r('app.string.research_report'),
  $r('app.string.capital'), $r('app.string.datum'), $r('app.string.announcements'),
  $r('app.string.finance'), $r('app.string.information'), $r('app.string.related_fund')
];

export const SELL_SHARES: transactionDetails[] = [
  new transactionDetails($r('app.string.sell'), '20.10', 69),
  new transactionDetails($r('app.string.sell'), '20.09', 12),
  new transactionDetails($r('app.string.sell'), '20.08', 66),
  new transactionDetails($r('app.string.sell'), '20.07', 55),
  new transactionDetails($r('app.string.sell'), '20.06', 33)
];

export const BUY_SELL_SHARES: transactionDetails[] = [
  new transactionDetails($r('app.string.text_buy'), '20.05', 11),
  new transactionDetails($r('app.string.text_buy'), '20.04', 22),
  new transactionDetails($r('app.string.text_buy'), '20.03', 33),
  new transactionDetails($r('app.string.text_buy'), '20.02', 55),
  new transactionDetails($r('app.string.text_buy'), '20.01', 66)
];

export const SUBMISSION_TIME: transactionDetails[] = [
  new transactionDetails('10:02', '20.07', 11),
  new transactionDetails('10:02', '20.07', 22),
  new transactionDetails('10:02', '20.07', 33),
  new transactionDetails('10:02', '20.08', 55),
  new transactionDetails('10:02', '20.08', 66),

  new transactionDetails('10:01', '20.07', 33),
  new transactionDetails('10:01', '20.07', 22),
  new transactionDetails('10:01', '20.07', 66),
  new transactionDetails('10:01', '20.07', 99),
  new transactionDetails('10:01', '20.07', 77),

  new transactionDetails('10:00', '20.06', 33),
  new transactionDetails('10:00', '20.06', 22),
  new transactionDetails('10:00', '20.06', 66),
  new transactionDetails('10:00', '20.05', 99),
  new transactionDetails('10:00', '20.05', 77)
];

export const STOCK_TITLE: Resource[] = [
  $r('app.string.stock_name'), $r('app.string.latest_price'), $r('app.string.highs_and_lows'),
  $r('app.string.price_limit'), $r('app.string.gross'), $r('app.string.impressions'),
  $r('app.string.volume_transaction'), $r('app.string.amplitude'), $r('app.string.change_hands'),
  $r('app.string.PEG'), $r('app.string.PB')
];