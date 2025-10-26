/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

export default class DateTimeUtils {

  getTime(): string {
    const DATETIME = new Date();
    return this.concatTime(DATETIME.getHours(), DATETIME.getMinutes(), DATETIME.getSeconds(), DATETIME.getMilliseconds());
  }

  getDate(): string {
    const DATETIME = new Date();
    return this.concatDate(DATETIME.getFullYear(), DATETIME.getMonth() + 1, DATETIME.getDate());
  }

  fill(value: number): string {
    return (value > 9 ? '' : '0') + value;
  }

  concatDate(year: number, month: number, date: number): string {
    return `${year}${month}${date}`;
  }

  concatTime(hour: number, minute: number, second: number, millisecond: number): string {
    return `${this.fill(hour)}:${this.fill(minute)}:${this.fill(second)}.${millisecond}`;
  }
}