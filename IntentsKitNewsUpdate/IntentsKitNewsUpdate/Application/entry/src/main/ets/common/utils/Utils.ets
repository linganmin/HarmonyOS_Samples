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

import { i18n } from '@kit.LocalizationKit';
import Logger from './Logger';

export function formatRelativeTime(timestamp: number): string {
  const now = Date.now();
  const diffInSeconds = Math.floor((now - timestamp) / 1000);
  const isEn = i18n.System.getSystemLanguage() === "en-Latn-US";

  // Define the unit of time and its corresponding number of seconds
  const units: Array<TimeUnit> = [
    {
      name: isEn ? 'year' : '年',
      plural: isEn ? 'years' : '年',
      seconds: 31536000
    },
    {
      name: isEn ? 'month' : '个月',
      plural: isEn ? 'months' : '个月',
      seconds: 2592000
    },
    {
      name: isEn ? 'day' : '天',
      plural: isEn ? 'days' : '天',
      seconds: 86400
    },
    {
      name: isEn ? 'hour' : '小时',
      plural: isEn ? 'hours' : '小时',
      seconds: 3600
    },
    {
      name: isEn ? 'minute' : '分钟',
      plural: isEn ? 'minutes' : '分钟',
      seconds: 60
    },
    {
      name: isEn ? 'second' : '秒',
      plural: isEn ? 'seconds' : '秒',
      seconds: 1,
      threshold: 10
    }
  ];

  // Special case: future time
  if (diffInSeconds < 0) {
    return isEn ? 'just now' : '刚刚';
  }

  // Find the most suitable time unit
  for (const unit of units) {
    const value = Math.floor(diffInSeconds / unit.seconds);

    if (value >= 1) {
      // If there is a threshold and the difference is less than the threshold
      if (unit.threshold !== undefined && diffInSeconds < unit.threshold) {
        return isEn ? 'just now' : '刚刚';
      }
      return isEn
        ? `${value} ${value > 1 ? unit.plural : unit.name} ago`
        : `${value}${unit.name}前`;
    }
  }

  // default return just now
  return isEn ? 'just now' : '刚刚';
}

interface TimeUnit {
  name: string;
  plural: string;
  seconds: number;
  threshold?: number;
}

/**
 * Pad a number with leading zero to make it two digits
 * @param num - Number to pad
 * @returns Two-digit string
 */
function padZero(num: number): string {
  return num.toString().padStart(2, '0');
}

/**
 * Format Date object to "YYYY-MM-DD HH:mm:ss" string
 * @param date - Date object to format
 * @returns Formatted datetime string
 * @throws {Error} When invalid Date object is provided
 */
export function formatDateTime(date: Date): string {
  if (!(date instanceof Date) || isNaN(date.getTime())) {
    Logger.showError('formatDateTime', 'Invalid Date object');
    date = new Date();
  }

  const year = date.getFullYear();
  const month = padZero(date.getMonth() + 1);
  const day = padZero(date.getDate());
  const hours = padZero(date.getHours());
  const minutes = padZero(date.getMinutes());
  const seconds = padZero(date.getSeconds());

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

/**
 * @param str
 * @returns
 */
export function containsChinese(str: string): boolean {
  if (str.length === 0 || !str) {
    return false;
  }
  const chineseRegex = new RegExp(/[\u4e00-\u9fa5]/);
  return chineseRegex.test(str);
}