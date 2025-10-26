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

import { i18n } from '@kit.LocalizationKit';

/**
 * the formatted date is in standard format.
 * @param { Date } date date that need to be formatted.
 * @returns { string } date formatted.
 */
export function formatSystemTime(date: Date): string {
  let formatOptions: Intl.DateTimeFormatOptions = {
    dateStyle: 'full'
  };
  let locale: string = i18n.System.getSystemLanguage();
  let dateFormat: Intl.DateTimeFormat = new Intl.DateTimeFormat(locale, formatOptions);
  return dateFormat.format(date);
}

/**
 * convert date format to string format(YYYYMMDD).
 * @param { Date } date date that need to be formatted.
 * @returns { string } date formatted.
 */
export function convertDate2Str(date: Date): string {
  const year = date.getFullYear();
  const month = ("0" + (date.getMonth() + 1)).slice(-2);
  const day = ("0" + date.getDate()).slice(-2);
  return `${year}${month}${day}`;
}

/**
 * convert string format(YYYYMMDD) format to date.
 * @param { string } dateStr dateStr that need to be formatted.
 * @returns { Date } dateStr formatted.
 */
export function convertStr2Date(dateStr: string): Date {
  const year = parseInt(dateStr.substring(0, 4));
  const month = parseInt(dateStr.substring(4, 6)) - 1;
  const day = parseInt(dateStr.substring(6, 8));
  return new Date(year, month, day);
}

/**
 * convert string format(HH:MM) format to date.
 * @param { string } dateStr dateStr that need to be formatted.
 * @returns { Date } dateStr formatted.
 */
export function convertTime2Date(value: string): Date {
  const hourMin = value.split(':');
  const hour = parseInt(hourMin[0]);
  const minute = parseInt(hourMin[1]);
  let date = new Date();
  date.setHours(hour, minute);
  return date;
}