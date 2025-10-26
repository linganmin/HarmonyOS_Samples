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

export class SearchTicketDateItem {
  /**
   * The date of the date.
   */
  private date: string;

  /**
   * The week of the date.
   */
  private week: string | Resource;

  /**
   * constructor method.
   */
  constructor( week: string | Resource,date: string,) {
    this.date = date;
    this.week = week;
  }

  /**
   * The getter of the date.
   */
  getDate() {
    return this.date;
  }

  /**
   * The getter  of the week.
   */
  getWeek() {
    return this.week;
  }
}