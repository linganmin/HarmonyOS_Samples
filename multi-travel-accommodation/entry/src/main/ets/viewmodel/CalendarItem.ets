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

export class CalendarItem {
  /**
   * Calendar date.
   */
  public date: string;

  /**
   * Price of the day.
   */
  public money: string;

  /**
   * Is it cheap this day.
   */
  public isLowPrice :boolean;

  /**
   * Is this day in the past.
   */
  public isLast : boolean | undefined = false;

  /**
   * Is this day today.
   */
  public isToday : Boolean | undefined = false;

  /**
   * constructor method.
   */
  constructor(date: string, money: string,isLowPrice :boolean,isLast? :boolean,isToday ? :boolean) {
    this.date = date;
    this.money = money;
    this.isLowPrice = isLowPrice;
    this.isLast =isLast;
    this.isToday = isToday;
  }
}