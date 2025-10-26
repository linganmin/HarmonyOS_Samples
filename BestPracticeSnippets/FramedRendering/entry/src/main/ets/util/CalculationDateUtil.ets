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

import { LunarDate, solar2lunar } from 'lunar_lite';
import hilog from '@ohos.hilog';

const TAG: string = 'CalculationDateUtil';
const SATURDAY: number = 6;

export class CalculationDateUtil {
  private static dateMap: Map<number, ResourceStr> = new Map(
    [
      [1, $r('app.string.january')], [2, $r('app.string.february')], [3, $r('app.string.march')],
      [4, $r('app.string.april')], [5, $r('app.string.may')], [6, $r('app.string.june')], [7, $r('app.string.july')],
      [8, $r('app.string.august')], [9, $r('app.string.september')], [10, $r('app.string.october')],
      [11, $r('app.string.november')], [12, $r('app.string.december')],
    ]
  );

  public static getMonthDate(specifiedMonth: number, specifiedYear: number): number[] {
    let currentFirstWeekDay: number = 0;
    let currentLastWeekDay: number = 0;
    const currentAllDay: number[] = [];
    const totalDays: number = new Date(specifiedYear, specifiedMonth, 0).getDate();
    currentFirstWeekDay = new Date(specifiedYear, specifiedMonth - 1, 1).getDay();
    currentLastWeekDay = new Date(specifiedYear, specifiedMonth - 1, totalDays).getDay();

    for (let item = 0; item < currentFirstWeekDay; item++) {
      currentAllDay[item] = 0;
    }

    for (let item = 1; item <= totalDays; item++) {
      currentAllDay.push(item);
    }

    for (let item = 0; item < SATURDAY - currentLastWeekDay; item++) {
      currentAllDay.push(0);
    }
    return currentAllDay;
  }

  public static dateToLunar(year: number, month: number, day: number, uiContext:UIContext): string {
    let lunarDate: LunarDate = solar2lunar(`${year}-${month}-${day}`);
    const dayStr: Resource[] =
      [
        $r('app.string.monday'), $r('app.string.tuesday'), $r('app.string.wednesday'), $r('app.string.thursday'),
        $r('app.string.Friday'), $r('app.string.saturday'), $r('app.string.seven'), $r('app.string.eight'),
        $r('app.string.nine'), $r('app.string.ten')
      ];
    let lunarDay: string = '';
    const numberDay: number = lunarDate.lunarDay;
    if (numberDay <= 10 && numberDay > 0) {
      lunarDay = CalculationDateUtil.getString($r('app.string.grade').id, uiContext) + CalculationDateUtil.getString(dayStr[numberDay - 1].id, uiContext);
    } else {
      const first: Resource =
        numberDay.toString().charAt(0) === '1' ? $r('app.string.ten') : (numberDay.toString().charAt(0) === '2' ?
          $r('app.string.chinese_twenty'): $r('app.string.wednesday'));
      const second: Resource =
        numberDay.toString().charAt(1) === '0' ? $r('app.string.ten') :
        dayStr[Number.parseInt(numberDay.toString().charAt(1)) - 1];
      lunarDay = CalculationDateUtil.getString(first.id, uiContext) + CalculationDateUtil.getString(second.id, uiContext);
    }
    return lunarDay;
  }

  public static numberToCharacter(num: number): ResourceStr | undefined {
    return CalculationDateUtil.dateMap.get(num);
  }

  public static getString(resourceId: number, uiContext:UIContext): string {
    try {
      return uiContext.getHostContext()!.resourceManager.getStringSync(resourceId);
    } catch (error) {
      hilog.error(0x0000, TAG, `getString failed, errorCode: ${error.code}`);
      return '';
    }
  }
}