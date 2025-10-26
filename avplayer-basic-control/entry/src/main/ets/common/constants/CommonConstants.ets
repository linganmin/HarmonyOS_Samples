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
  /**
   * Idle state of avPlayer.
   */
  IDLE = 'idle',

  /**
   * Initialized state of avPlayer.
   */
  INITIALIZED = 'initialized',

  /**
   * Prepared state of avPlayer.
   */
  PREPARED = 'prepared',

  /**
   * Playing state of avPlayer.
   */
  PLAYING = 'playing',

  /**
   * Pause state of avPlayer.
   */
  PAUSED = 'paused',

  /**
   * Completed state of avPlayer.
   */
  COMPLETED = 'completed',

  /**
   * Stopped state of avPlayer.
   */
  STOPPED = 'stopped',

  /**
   * Release state of avPlayer.
   */
  RELEASED = 'released',

  /**
   * Error state of avPlayer.
   */
  ERROR = 'error',
  UNDEFINED = 'undefined'
}

export enum VideoDataType {
  RAW_FILE = 1,
  RAW_M3U8_FILE = 2,
  URL = 3,
  RAW_MP4_FILE = 4
}

export class CommonConstants {
  static readonly AVPLAYER_IDLE: emitter.InnerEvent = {
    eventId: 1,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_INITIALIZED: emitter.InnerEvent = {
    eventId: 2,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_PREPARED: emitter.InnerEvent = {
    eventId: 3,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_PLAYING: emitter.InnerEvent = {
    eventId: 4,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_COMPLETED: emitter.InnerEvent = {
    eventId: 5,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_PAUSED: emitter.InnerEvent = {
    eventId: 6,
    priority: emitter.EventPriority.HIGH
  };
  static readonly AVPLAYER_STOPPED: emitter.InnerEvent = {
    eventId: 7,
    priority: emitter.EventPriority.HIGH
  };
  static readonly innerEventFalse: emitter.InnerEvent = {
    eventId: 11,
    priority: emitter.EventPriority.HIGH
  };
  static readonly innerEventTrue: emitter.InnerEvent = {
    eventId: 12,
    priority: emitter.EventPriority.HIGH
  };
  static readonly innerEventWH: emitter.InnerEvent = {
    eventId: 13,
    priority: emitter.EventPriority.HIGH
  };
  static readonly SLIDER_PROGRESS_MIN: number = 0
  static readonly SLIDER_PROGRESS_STEP: number = 0.1
  /**
   * Full size.
   */
  static readonly FULL_SIZE: string = '100%';
  /**
   * Seek hour unit
   */
  static readonly HOUR_UNIT: number = 60;
  /**
   * Second to Millisecond
   */
  static readonly SECOND_TO_MS: number = 1000;
  /**
   * Time const number
   */
  static readonly TIME_CONST_TEN: number = 10;
  /**
   * Hilog Domain.
   */
  static readonly LOG_DOMAIN = 0x0000;
}