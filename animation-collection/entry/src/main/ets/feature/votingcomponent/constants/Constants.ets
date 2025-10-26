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

export default class Constants {
  /**
   * Left color.
   */
  static readonly LEFT_COLOR: Color = Color.Red;

  /**
   * Right color.
   */
  static readonly RIGHT_COLOR: Color = Color.Blue;

  /**
   * Begin points.
   */
  static readonly BEGIN_POINTS: number[][] = [[20, 0], [90, 0], [80, 80], [10, 80]];

  /**
   * End points.
   */
  static readonly END_POINTS: number[][] = [[50, 0], [60, 0], [50, 80], [40, 80]];

  /**
   * Begin fill opacity.
   */
  static readonly BEGIN_FILL_OPACITY: number = 1;

  /**
   * End fill opacity.
   */
  static readonly END_FILL_OPACITY: number = 0.2;

  /**
   * Percentage.
   */
  static readonly PERCENTAGE: number = 100;

  /**
   * Mid text font weight.
   */
  static readonly MID_TEXT_FONT_WEIGHT: number = 900;

  /**
   * Animate duration.
   */
  static readonly ANIMATE_DURATION: number = 500;

  /**
   * Half percent.
   */
  static readonly HALF_PERCENT: string = '50%';

  /**
   * Left count.
   */
  static readonly LEFT_COUNT: number = 4;

  /**
   * Right count.
   */
  static readonly RIGHT_COUNT: number = 13;
}