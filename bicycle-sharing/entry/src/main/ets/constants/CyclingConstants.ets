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

export class CyclingConstants {
  /**
   * CyclingStatus
   */
  public static readonly CYCLING_STATUS = 'CyclingStatus';
  /**
   * Keep time
   */
  public static readonly KEEP_TIME: number = 15;
  /**
   * Content color
   */
  public static readonly CONTENT_COLOR: string = '#FF000000';
  /**
   * Capsule color
   */
  public static readonly CAPSULE_COLOR: string = '#ff0758f8';
  /**
   * Title for waiting payment
   */
  public static readonly WAITING_PAYMENT_TITLE: string = '行程结束';
  /**
   * Content for waiting payment
   */
  public static readonly WAITING_PAYMENT_CONTENT: string = '骑行时长10:00';
  /**
   * Title for waiting payment layout
   */
  public static readonly WAITING_PAYMENT_LAYOUT_TITLE: string = '待支付';
  /**
   * Content for waiting payment layout
   */
  public static readonly WAITING_PAYMENT_LAYOUT_CONTENT: string = '1.5元';
  /**
   * Extension data for waiting payment
   */
  public static readonly WAITING_PAYMENT_EXTENSION_DATA: string = '去支付';
  /**
   * Pay method for waiting payment
   */
  public static readonly WAITING_PAYMENT_PAY: string = '免密支付';
  /**
   * Success message for payment
   */
  public static readonly WAITING_PAYMENT_PAY_SUCCESS: string = '扣费成功';
  /**
   * End message for payment
   */
  public static readonly WAITING_PAYMENT_PAY_END: string = '已支付';
  /**
   * Check message for payment completed
   */
  public static readonly PAYMENT_COMPLETED_CHECK: string = '去查看';
  /**
   * Title for payment completed capsule
   */
  public static readonly PAYMENT_COMPLETED_CAPSULE_TITLE: string = '已完成';
  /**
   * Title for default view layout
   */
  public static readonly DEFAULT_VIEW_LAYOUT_TITLE: string = '预估费用';
  /**
   * Status for riding
   */
  public static readonly DEFAULT_VIEW_RIDING: string = '骑行中';
  /**
   * Riding time in default view
   */
  public static readonly DEFAULT_VIEW_RIDING_TIME: string = '骑行时长01:21';
  /**
   * Default latitude
   */
  public static readonly LATITUDE: number = 30.494714656023934;
  /**
   * Default longitude
   */
  public static readonly LONGITUDE: number = 114.53358501611723;
  /**
   * Default zoom level
   */
  public static readonly ZOOM: number = 15;
  /**
   * Text for riding duration
   */
  public static readonly RIDDING_TEXT: string = '时长';
  /**
   * Second part of riding duration
   */
  public static readonly RIDDING_TEXT_SECOND: string = '01:10';
  /**
   * Text for estimated cost
   */
  public static readonly RIDDING_TEXT_THIRD: string = '预计费用';
  /**
   * Estimated cost
   */
  public static readonly RIDDING_TEXT_FOURTH: string = '1.5';
  /**
   * Space between rows in index
   */
  public static readonly INDEX_ROW_SPACE: string = '5';
  /**
   * Space between columns in payment
   */
  public static readonly PAY_COLUMN_SPACE: string = '4';
  /**
   * Full percent
   */
  public static readonly FULL_PERCENT: string = '100%';
  /**
   * Height of sheet
   */
  public static readonly SHEET_HEIGHT: string = '37%';
  /**
   * Type of scan
   */
  public static readonly SCAN_TYPE: number = 11;
  /**
   * Row space for confirm unlock page
   */
  public static readonly CONFIRMUNLOCK_ROW_SPACE: number = 1;
  /**
   * Stroke width for divider
   */
  public static readonly DIVIDER_STROKE_WIDTH: number = 1;
  /**
   * Row space for finding bike page
   */
  public static readonly FIND_BIKE_ROW_SPACE: number = 5;
  /**
   * Row space for payment page
   */
  public static readonly PAY_ROW_SPACE: number = 5;
  /**
   * Row space for riding page
   */
  public static readonly RIDDING_ROW_SPACE: number = 92;
  /**
   * Riding page
   */
  public static readonly RIDDING_PAGE: string = 'pages/Riding';
  /**
   * Pay page
   */
  public static readonly PAY_PAGE: string = 'pages/Pay';
  /**
   * Cycling page
   */
  public static readonly CYCLING_PAGE: string = 'pages/CyclingPage';
}


export enum CyclingStatus {
  LOOKING_FOR_BIKE = 1,
  WAITING_SCAN,
  WAITING_UNLOCK,
  RIDING,
  WAITING_PAYMENT,
  PAYMENT_COMPLETED,
  NOT_READY,
}