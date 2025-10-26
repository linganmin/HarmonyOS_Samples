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

const context = AppStorage.get("context") as UIContext;

/**
 * Common constants for all features.
 */
export default class Constants {
  /**
   * Default color of the Circle component.
   */
  static readonly COLOR_NORMAL: string = '#E5000000';

  /**
   * Default Background Color.
   */
  static readonly COLOR_TRANSPARENT: string = '#FFF';

  /**
   * Display percentage of the Circle component.
   */
  static readonly PERCENTAGE_STR: string = '%';

  /**
   * Maximum Percentage.
   */
  static readonly LAYOUT_MAX_PERCENT: string = '100%';

  /**
   * Communication Color.
   */
  static readonly OHOS_ID_COLOR_PALETTE4: string = '#64BB5C';

  /**
   * Progress Step.
   */
  static readonly PROGRESS_STEP: number = 0.5;

  /**
   * Size of the Circle component.
   */
  static readonly DIAMETER: number = 200;

  /**
   * Converts a number in vp units to a number in px units.
   */
  static readonly RADIUS_IN_PX: number = context.vp2px(Constants.DIAMETER / 2.0);

  /**
   * Big Diameter.
   */
  static readonly BIG_DIAMETER: number = 220;

  /**
   * Full Progress.
   */
  static readonly FULL_PROGRESS: number = 100;

  /**
   * Zero Progress.
   */
  static readonly ZERO_PROGRESS: number = 0;

  /**
   * Healthy Progress.
   */
  static readonly HEALTHY_PROGRESS: number = 80;

  /**
   * Warn Progress.
   */
  static readonly WARN_PROGRESS: number = 20;

  /**
   * Unit One.
   */
  static readonly UNIT_ONE: number = 1;

  /**
   * Percent Rate.
   */
  static readonly PERCENT_RATE: number = 100.0;

  /**
   * Progress Change Interval.
   */
  static readonly PROGRESS_CHANGE_INTERVAL: number = 100;

  /**
   * Initialize 0.
   */
  static readonly ZERO: number = 0;
}