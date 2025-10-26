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

import { emitter } from '@kit.BasicServicesKit';

export enum AVPlayerState {
  /*
   * Idle state of avPlayer.
   */
  IDLE = 'idle',

  /*
   * Initialized state of avPlayer.
   */
  INITIALIZED = 'initialized',

  /*
   * Prepared state of avPlayer.
   */
  PREPARED = 'prepared',

  /*
   * Playing state of avPlayer.
   */
  PLAYING = 'playing',

  /*
   * Pause state of avPlayer.
   */
  PAUSED = 'paused',

  /*
   * Completed state of avPlayer.
   */
  COMPLETED = 'completed',

  /*
   * Stopped state of avPlayer.
   */
  STOPPED = 'stopped',

  /*
   * Release state of avPlayer.
   */
  RELEASED = 'released',

  /*
   * Error state of avPlayer.
   */
  ERROR = 'error',

  /*
   * undefined state of avPlayer.
   */
  UNDEFINED = 'undefined'
}

export enum VideoDataType {
  RAW_FILE = 1,
  RAW_M3U8_FILE = 2,
  URL = 3
}

export class CaptionFontConstants {
  static readonly CAPTION_FONT_FAMILY: ResourceStr[] = ['Sans', 'Condensed'];
  static readonly CAPTION_FONT_COLOR: ResourceColor[] = [Color.White, Color.Black, Color.Red];
  static readonly CAPTION_FONT_SIZE: ResourceStr[] = ['14', '16', '18'];
  static readonly SECOND_TIME = 3600;
  static readonly MINUTE_TIME = 60;
}

export class CommonConstants {
  static readonly AVPLAYER_PREPARED: emitter.InnerEvent = {
    eventId: 3,
    priority: emitter.EventPriority.HIGH
  };
  static readonly SUBTITLE_UPDATE: emitter.InnerEvent = {
    eventId: 4,
    priority: emitter.EventPriority.IMMEDIATE
  };
  /*
   * Seek hour unit
   */
  static readonly HOUR_UNIT: number = 60;
  /*
   * Second to Millisecond
   */
  static readonly SECOND_TO_MS: number = 1000;
  /*
   *  video aspect
   */
  static readonly ASPECT: number = 16 / 9;
  /**
   * Width percent full
   */
  static readonly WIDTH_FULL_PERCENT: string = '100%';
  /**
   * Height percent full
   */
  static readonly HEIGHT_FULL_PERCENT: string = '100%';
}

export class ScreenShotConstants {
  static readonly FRAME_RATE: number = 25;
}

export class Constants {
  static DELAY_MS = 600;
  static WH_RADIO = 16 / 9;
  static LIST_CACHE_COUNT = 8;
  static LIST_FRICTION = 2.0;
  static LIST_ITEM_TOP_PADDING = 16;
  static TITLE_HEIGHT = 40;
  static LIST_ITEM_LEFT_PADDING = 16;
  static LIST_ITEM_RIGHT_PADDING = 16;
  static LIST_DIVIDER_WIDTH = 8;
  static SLIDER_PADDING = 5;
  static INFO_AREA_HEIGHT = 80;
  static FOOTER_HEIGHT = 64;
  static DOMAIN = 0x0000;
  static UI_CONTEXT = 'uiContext';
  static SURFACE_ID_KEY = 'surfaceID';
  static DETAIL_PAGE_NAME = 'DetailPage';
  static readonly PROGRESS_REFRESH_INTERVAL: number = 100;
  static readonly PROGRESS_SHOWN_DURATION: number = 5000;
}