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

export enum NetConnectionState {
  UNKNOWN_STATE = 0,
  SUCCEED_STATE,
  LOADING_STATE,
  FAIL_STATE
}

export class CommonConstants {
  /**
   * Full percent.
   */
  public static readonly FULL_PERCENT: string = '100%';
  /**
   * 20 percent.
   */
  public static readonly TWENTY_PERCENT: string = '20%';
  /**
   * Interface Path
   */
  public static readonly MOCK_INTERFACE_PATH_NAME = 'smoothSlide';
  /**
   * the api fileName of function area
   */
  public static readonly MOCK_INTERFACE_FUNCTION_FILE_NAME: string = 'entry.json';
  /**
   * the api fileName of waterFlow area
   */
  public static readonly MOCK_INTERFACE_WATER_FLOW_FILE_NAME: string = 'waterFlow.json';
  /**
   * Waterflow cached count.
   */
  public static readonly WATER_FLOW_CACHED_COUNT: number = 10;
  /**
   * Function page number
   */
  public static readonly FUNCTION_PAGE_NUMBER: number = 1;
  /**
   * Function page size
   */
  public static readonly FUNCTION_PAGE_SIZE: number = 25;
  /**
   * waterFlow page size
   */
  public static readonly WATER_FLOW_PAGE_SIZE: number = 20;
  /**
   * waterFlow page start index
   */
  public static readonly WATER_FLOW_PAGE_START_INDEX: number = 1;
  /**
   * Function page one
   */
  public static readonly FUNCTION_FIRST_INDEX: number = 0;
  /**
   * Function page one.
   */
  public static readonly FUNCTION_SECOND_INDEX: number = 1;
  /**
   * Function page one.
   */
  public static readonly FUNCTION_FIRST_COUNT: number = 10;
  /**
   * Grid data count under md breakpoint.
   */
  public static readonly FUNCTION_FIRST_COUNT_MD: number = 12;
  /**
   * Grid data count under lg breakpoint.
   */
  public static readonly FUNCTION_FIRST_COUNT_LG: number = 16;
  /**
   * Function page one
   */
  public static readonly FUNCTION_SECOND_COUNT: number = 15;
  /**
   * water flow default page count
   */
  public static readonly WATER_FLOW_DEFAULT_PAGE_COUNT: number = 6;
  /**
   * waterFlow image card reuseId
   */
  public static readonly WATER_FLOW_IMAGE_REUSE_ID: string = 'image';
  /**
   * waterFlow image card type
   */
  public static readonly WATER_FLOW_IMAGE_TYPE: string = 'image';
  /**
   * waterFlow video card reuseId
   */
  public static readonly WATER_FLOW_VIDEO_REUSE_ID: string = 'video';
  /**
   * waterFlow image card type
   */
  public static readonly WATER_FLOW_VIDEO_TYPE: string = 'video';
  /**
   *
   * waterFlow living card reuseId
   */
  public static readonly WATER_FLOW_LIVING_REUSE_ID: string = 'living';
  /**
   * waterFlow living card type
   */
  public static readonly WATER_FLOW_LIVING_TYPE: string = 'living';
  /**
   * waterFlow living card struct id
   */
  public static readonly WATER_FLOW_LIVING_STRUCT_ID: string = 'livingCard';
  /**
   * waterFlow card max count
   */
  public static readonly WATER_FLOW_MAX_COUNT: number = 20;
  /**
   * string default value: ''
   */
  public static readonly STRING_DEFAULT_VALUE: string = '';
  /**
   * number default value: 0
   */
  public static readonly NUMBER_DEFAULT_VALUE: number = 0;
  /**
   * toast show time
   */
  public static readonly TOAST_SHOW_TIME: number = 3000;
  /**
   * toast show time
   */
  public static readonly TOAST_SHOW_MARGIN_BOTTOM: number = 108;
  /**
   * the height of pull to refresh
   */
  public static readonly PULL_TO_REFRESH_HEIGHT: number = 64;
  /**
   * toast show time
   */
  public static readonly ANIMATION_DURATION_TIME: number = 300;
  /**
   * vip sign
   */
  public static readonly VIP_SIGN: string = '1';
  /**
   * space
   */
  public static readonly SPACE_FOUR: number = 4;
  /**
   * space
   */
  public static readonly SPACE_EIGHT: number = 8;
  /**
   * font weight
   */
  public static readonly TEXT_FONT_WEIGHT_500: number = 500;
  /**
   * font weight
   */
  public static readonly TEXT_FONT_WEIGHT_400: number = 400;
  /**
   * text max lines
   */
  public static readonly TEXT_MAX_LINES: number = 2;
  /**
   * zIndex
   */
  public static readonly LARGE_INDEX: number = 1;
  /**
   * the first index of arr
   */
  public static readonly ARR_FIRST_INDEX: number = 0;
  /**
   * the count 1 of arr that should be deal
   */
  public static readonly DEAL_COUNT_ONE: number = 1;
  /**
   * phone critical value
   */
  public static readonly CRITICAL_VALUE: number = 500;
  /**
   * water flow two columns
   */
  public static readonly WATER_FLOW_TWO_COLUMNS: number = 2;
  /**
   * water flow three columns
   */
  public static readonly WATER_FLOW_THREE_COLUMNS: number = 3;
  /**
   * water flow column gap
   */
  public static readonly WATER_FLOW_COLUMN_GAP: number = 8;
  /**
   * description margin left
   */
  public static readonly DESCRIPTION_MARGIN_LEFT: number = 12;
  /**
   * description two lines height
   */
  public static readonly DESCRIPTION_TWO_LINES_HEIGHT: number = 65;
  /**
   * description three lines height
   */
  public static readonly DESCRIPTION_THREE_LINES_HEIGHT: number = 80;
  /**
   * language
   */
  public static readonly LANGUAGE: string = 'language';
  /**
   * chinese language
   */
  public static readonly CHINESE_LANGUAGE: string = 'zh';
  /**
   * Duration.
   */
  static readonly TOAST_DURATION: number = 2000;
}