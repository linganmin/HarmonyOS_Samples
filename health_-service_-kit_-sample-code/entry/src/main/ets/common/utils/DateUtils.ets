/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

export class DateUtils {
  private static readonly YEAR_FORMAT = 10000;

  private static readonly MONTH_FORMAT = 100;

  private static readonly MIN_YYYYMMDD_DATE = 10000000;

  private static readonly MAX_YYYYMMDD_DATE = 100000000;

  public static getYyyyMmDd(timeStamp: number | string): number {
    const date = new Date(timeStamp);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return year * DateUtils.YEAR_FORMAT + month * DateUtils.MONTH_FORMAT + day;
  }

  public static parseYyyyMmDdToDate(date: number): string {
    if (date < DateUtils.MIN_YYYYMMDD_DATE || date > DateUtils.MAX_YYYYMMDD_DATE) {
      return '';
    }
    const timeStampStr = date + '';
    const year = timeStampStr.slice(0, 4);
    const month = timeStampStr.slice(4, 6);
    const day = timeStampStr.slice(6, 8);
    return `${month}/${day}/${year}`;
  }

  public static getLocalDate(timeStamp: number): string {
    return new Date(timeStamp).toLocaleDateString('en-US', {
      month: '2-digit',
      day: '2-digit',
      year: 'numeric'
    });
  }
}