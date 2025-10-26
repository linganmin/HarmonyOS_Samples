/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from '../../constants/CommonConstants';

export class DayInfo {
  date: string;
  targetTaskNum: number;
  finTaskNum: number;

  constructor(date: string, targetTaskNum: number, finTaskNum: number) {
    this.date = date;
    this.targetTaskNum = targetTaskNum;
    this.finTaskNum = finTaskNum;
  }

  toString(): string {
    return `DayInfo[` +
      `date: ${this.date}, ` +
      `targetTaskNum: ${this.targetTaskNum}, ` +
      `finTaskNum: ${this.finTaskNum}` +
      `]`;
  }

  calculatePercentage(): number {
    if (this.targetTaskNum === 0) {
      return 0;
    }
    return Math.ceil(this.finTaskNum / this.targetTaskNum * Const.DEFAULT_100);
  }

  getProgressImg(): Resource {
    if (this.finTaskNum === 0 || this.targetTaskNum === 0) {
      return $r('app.media.ic_home_undone');
    }
    if (this.finTaskNum < this.targetTaskNum) {
      return $r('app.media.ic_home_half_done');
    }
    return $r('app.media.ic_home_all_done');
  }
}