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

import { DateModel } from './DateModel';

export function getMonthDate(specifiedMonth: number, specifiedYear: number): number[]{
  let currentFirstWeekDay: number = 0;
  let currentLastWeekDay: number = 0;
  let currentAllDay: number[] = [];
  let totalDays = new Date(specifiedYear, specifiedMonth, 0).getDate();
  currentFirstWeekDay = new Date(specifiedYear, specifiedMonth - 1, 1).getDay();
  currentLastWeekDay = new Date(specifiedYear, specifiedMonth - 1, totalDays).getDay();
  for (let item = 0; item < currentFirstWeekDay; item++) {
    currentAllDay[item] = 0;
  }
  for (let item = 1; item <= totalDays; item++) {
    currentAllDay.push(item);
  }
  for (let item = 0; item < 6 - currentLastWeekDay; item++) {
    currentAllDay.push(0);
  }
  return currentAllDay;
}

export function getRealTimeDate(): DateModel{
  const nowDate = new Date();
  let currentMonth = nowDate.getMonth() + 1;
  let currentDay = nowDate.getDate();
  let currentYear = nowDate.getFullYear();
  let currentWeekDay = new Date(currentYear, currentMonth - 1, currentDay).getDay();
  let nowDateModel = new DateModel(0, 0, 0, 0);
  nowDateModel.day = currentDay;
  nowDateModel.week = currentWeekDay;
  nowDateModel.month = currentMonth;
  nowDateModel.year = currentYear;
  return nowDateModel;
}