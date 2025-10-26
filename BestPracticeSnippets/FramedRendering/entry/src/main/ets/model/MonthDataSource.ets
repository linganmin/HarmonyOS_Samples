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

import { CalculationDateUtil } from '../util/CalculationDateUtil';
import { BasicDataSource } from './BasicDataSource';

export class MonthDataSource extends BasicDataSource<Month> {
  private currentYear: number = new Date().getFullYear();
  private dataArray: Month[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Month {
    return this.dataArray[index];
  }

  public pushData(data: Month): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clearData(): void {
    for (let i = 0; i < this.dataArray.length; i++) {
      this.dataArray.pop();
      this.notifyDataAdd(this.dataArray.length - 1);
    }
  }

  public getDateData(uiContext: UIContext): void {
    for (let i = 1; i <= 12; i++) {
      let monthDays: number[] = CalculationDateUtil.getMonthDate(i, this.currentYear);
      let lunarDays: string[] = [];
      for (let j = 0; j < monthDays.length; j++) {
        if (monthDays[j] === 0) {
          lunarDays.push('');
        } else {
          lunarDays.push(CalculationDateUtil.dateToLunar(this.currentYear, i, monthDays[j], uiContext));
        }
      }
      const month: Month = {
        month: CalculationDateUtil.numberToCharacter(i) as string,
        num: i,
        days: monthDays,
        lunarDays: lunarDays,
        year: this.currentYear
      }
      this.pushData(month);
    }
  }
}

export interface Month {
  month: string;
  num: number;
  days: number[];
  lunarDays: string[];
  year: number;
}
