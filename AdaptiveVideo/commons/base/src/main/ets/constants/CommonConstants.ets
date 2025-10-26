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
 *
 */

export class CommonConstants {
  /**
   * Initialized state of avPlayer
   */
  public static readonly AV_PLAYER_INITIALIZED_STATE: string = 'initialized';
  /**
   * Prepared state of avPlayer
   */
  public static readonly AV_PLAYER_PREPARED_STATE: string = 'prepared';
  /**
   * Playing state of avPlayer
   */
  public static readonly AV_PLAYER_PLAYING_STATE: string = 'playing';
  /**
   * Pause state of avPlayer
   */
  public static readonly AV_PLAYER_PAUSED_STATE: string = 'paused';
  /**
   * Completed state of avPlayer
   */
  public static readonly AV_PLAYER_COMPLETED_STATE: string = 'completed';
  /**
   * Error state of avPlayer
   */
  public static readonly AV_PLAYER_ERROR_STATE: string = 'error';
  /**
   * second to millisecond
   */
  public static readonly PROGRESS_THOUSAND: number = 1000;
  /**
   * Seconds in one hour
   */
  public static readonly SECOND_IN_HOUR: number = 3600;
  /**
   * Seconds in one minute
   */
  public static readonly SECOND_IN_MINUTE: number = 60;
  /**
   * Time display separator
   */
  public static readonly COLON: string = ':';
  /**
   * zero
   */
  public static readonly ZERO: number = 0;
  /**
   * one
   */
  public static readonly ONE: number = 1;
  /**
   * ten
   */
  public static readonly TEN: number = 10;
  /**
   * Time compensation 0
   */
  public static readonly TIME_PREFIX: string = '0';
  /**
   * empty avplayer time
   */
  public static readonly EMPTY_TIME: string = '00'
  /**
   * Bottom tab height
   */
  public static readonly BOTTOM_TAB_HEIGHT: string = 'bottom_tab_height';
  /**
   * Bottom navigationBar height
   */
  public static readonly NAVIGATION_INDICATOR_HEIGHT: string = 'bottomRectHeight';
  /**
   * statusBar height
   */
  public static readonly SYSTEM_HEIGHT: string = 'topRectHeight';
  /**
   * window size
   */
  public static readonly WINDOW_SIZE: string = 'windowSize';
  /**
   * avplayer play source array
   */
  public static readonly VIDEO_SOURCE: string[] = [
    '9_16_1.mp4',
    '9_16_2.mp4',
    '1_1.mp4',
    '3_4.mp4',
    '4_3.mp4',
    '16_9.mp4',
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/wearables/watch-ultimate-new/video/huawei-watch-ultimate-pv.mp4',
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/launch/241126/plp/phones/mate-series/mate70-pro-plus.mp4',
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/plp/new-phones/video/pura-series.mp4',
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/plp/new-phones/video/nova-series.mp4'
  ];
  /**
   * windowStage
   */
  public static readonly WINDOW_STAGE: string = 'windowStage'
  /**
   * middle phone width
   */
  public static readonly MIDDLE_WIDTH: number = 440
}


