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

export default class CommonConstants {
  /**
   * Hundred percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Default column space.
   */
  static readonly COLUMN_DEFAULT_SPACE: string = '12vp';

  /**
   * Pause position x.
   */
  static readonly PAUSE_POSITION_X: string = '80%';

  /**
   * Record position y.
   */
  static readonly RECORD_POSITION_Y: string = '82%';
  /**
   * Play status.
   */
  static readonly PLAY_INIT: string = 'init';

  /**
   * Play status.
   */
  static readonly PLAY_STARTED: string = 'started';

  /**
   * Play status.
   */
  static readonly PLAY_CONTINUED: string = 'continued';

  /**
   * Play status.
   */
  static readonly PLAY_PAUSED: string = 'paused';

  /**
   * Play status.
   */
  static readonly PLAY_STOPPED: string = 'stopped';

  /**
   * Device phone.
   */
  static readonly DEVICE_PHONE: string = 'phone';

  /**
   * The minimum duration of audio recording is limited.
   */
  static readonly MIN_RECORD_SECOND: number = 5;

  /**
   * Total audio recording duration.
   */
  static readonly TOTAL_SECOND: number = 30;

  /**
   * Timer delay.
   */
  static readonly INTERVAL_TIME: number = 1000;

  /**
   * Font weight.
   */
  static readonly FONT_WIGHT_500: number = 500;

  /**
   * Opacity.
   */
  static readonly COMMON_OPACITY: number = 0.6;

  /**
   * Opacity.
   */
  static readonly AUDIO_OPACITY: number = 0.4;
}