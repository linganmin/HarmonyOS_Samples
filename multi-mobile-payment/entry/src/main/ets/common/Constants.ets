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

export class Constants {
  /**
   * Percentage representing the content width.
   */
  public static readonly CONTENT_WIDTH: string = '90%';

  /**
   * Percentage representing the full width.
   */
  public static readonly FULL_WIDTH: string = '100%';

  /**
   * Percentage representing half of the width.
   */
  public static readonly HALF_WIDTH: string = '50%';

  /**
   * Percentage representing the full height.
   */
  public static readonly FULL_HEIGHT: string = '100%';

  /**
   * Width of the scroll bar.
   */
  public static readonly SCROLL_BAR_WIDTH: number = 5;

  /**
   * Font weights for different styles.
   */
  public static readonly FONT_WEIGHT: number[] = [400, 500];

  /**
   * Various spacing values for content.
   */
  public static readonly CONTENT_SPACE: string[] = [
    '4vp', '8vp', '12vp', '14.78vp', '15vp', '16vp', '24vp', '26vp', '27vp', '28vp', '34.78vp', '36vp'
  ];

  /**
   * Breakpoints for responsive design.
   */
  public static readonly BREAKPOINTS: string[] = ['sm', 'md', 'lg'];

  /**
   * Column spans for grid layouts.
   */
  public static readonly GRID_COL_SPAN: number[] = [3, 6, 12];

  /**
   * Number of columns in grid rows.
   */
  public static readonly GRID_ROW_COLUMNS: number[] = [4, 6, 8];

  /**
   * Layout weight for elements.
   */
  public static readonly LAYOUT_WEIGHT: number = 1;

  /**
   * Opacity value.
   */
  public static readonly OPACITY: number = 0.6;

  /**
   * Names of various functions.
   */
  public static readonly FUNCTIONS_NAME: string[] = [
    '基金投资', '理财产品', '信用卡', '账单','速盈', '贵金属', '存款产品',  '缴费', '快贷', '更多'
  ];

    /**
   * Names of various functions.
   */
  public static readonly FUNCTIONS_CARD_NAME: string[] = [
    '扫一扫', '收付款', '出行', '卡包'
  ];

  /**
   * Items in a service card related to receiving money.
   */
  public static readonly RECEIVE_MONEY_SERVICE_CARD_ITEM: string[] = [
    '收款记录', '收钱语音提醒', '商家服务', '收钱免费兑换'
  ];

  /**
   * Default city name.
   */
  public static readonly CITY_NAME: string = '城市';

  /**
   * Tab bar name.
   */
  public static readonly TAB_BAR_TITLES: string[] = ['首页', '理财', '生活', '消息', '我的'];

  /**
   * Breakpoint split screen size.
   */
  public static readonly BREAKPOINTS_WINDOW_SIZE: number[] = [600, 840];

  /**
   * Corner radius.
   */
  public static readonly CORNER_RADIUS: number = 10;

  /**
   * QR code size.
   */
  public static readonly QRCODE_SIZE: number = 400;

  /**
   * Scan Abilities
   */
  public static readonly SCAN_ABILITIES: ResourceStr[] = [$r('app.string.scan'), $r('app.string.identify_objects'), 'AR'];

  /**
   * 400 Font Weight
   */
  public static readonly FONT_WEIGHT_400: number = 400;

  /**
   * 500 Font Weight
   */
  public static readonly FONT_WEIGHT_500: number = 500;

  /**
   * 700 Font Weight
   */
  public static readonly FONT_WEIGHT_700: number = 700;

  /**
   * 0.9 Opacity
   */
  public static readonly PERCENT_90_OPACITY: number = 0.9;

  /**
   * 60 backdropBlur
   */
  public static readonly BACK_DROP_BLUR_60: number = 60;

  /**
   * Bottom Functions
   */
  public static readonly SCAN_DIALOG_FUNCTIONS: string[] = ['收付款', '相册'];

  /**
   * Bottom Functions
   */
  public static readonly EIGHTY_PERCENT: string = '80%';

  /**
   * Init camera width dialog
   */
  public static readonly INIT_CAMERA_WIDTH_DIALOG: number = 746;

  /**
   * Init camera height dialog
   */
  public static readonly INIT_CAMERA_HEIGHT_DIALOG: number = 560;


  /**
   * 21 line height
   */
  public static readonly LINE_HEIGHT_21: number = 21;

  /**
   * sm breakpoint
   */
  public static readonly BREAKPOINT_SM: string = 'sm';

  /**
   * md breakpoint
   */
  public static readonly BREAKPOINT_MD: string = 'md';

  /**
   * lg breakpoint
   */
  public static readonly BREAKPOINT_LG: string = 'lg';
}