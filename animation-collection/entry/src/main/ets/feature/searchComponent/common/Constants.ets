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
   * Click to search for the duration of the animation.
   */
  static readonly CLICK_SEARCH_ANIMATION_DURATION: number = 100;

  /**
   * Transition animation duration.
   */
  static readonly TRANSITION_ANIMATION_DURATION: number = 200;

  /**
   * Search history content animation duration.
   */
  static readonly SEARCH_HISTORY_ANIMATION_DURATION: number = 350;

  /**
   * Animation delay.
   */
  static readonly ANIMATION_DELAY: number = 150;

  /**
   * Click on the list of tips/history to go to the animation duration of the example page.
   */
  static readonly TO_EXAMPLE_PAGE_DURATION: number = 20;

  /**
   * Parameter velocity for generating the animation curve from 0 to 1.
   */
  static readonly ANIMATION_CURVE_VELOCITY: number = 0;

  /**
   * Parameter mass for generating the animation curve from 0 to 1.
   */
  static readonly ANIMATION_CURVE_MASS: number = 1;

  /**
   * Parameter stiffness for generating the animation curve from 0 to 1.
   */
  static readonly ANIMATION_CURVE_STIFFNESS: number = 342;

  /**
   * Parameter damping for generating the animation curve from 0 to 1.
   */
  static readonly ANIMATION_CURVE_DAMPING: number = 38;

  /**
   * Constructs a third-order Bezier curve X1.
   */
  static readonly ANIMATION_CURVE_X1: number = 0.33;

  /**
   * Constructs a third-order Bezier curve Y1.
   */
  static readonly ANIMATION_CURVE_Y1: number = 0;

  /**
   * Constructs a third-order Bezier curve X2.
   */
  static readonly ANIMATION_CURVE_X2: number = 0.67;

  /**
   * Constructs a third-order Bezier curve Y2.
   */
  static readonly ANIMATION_CURVE_Y2: number = 1;

  /**
   * Creates a translate transition effect.
   */
  static readonly TRANSITION_EFFECT_Y: number = 30;

  /**
   * Creates an opacity transition effect with alpha value.
   */
  static readonly TRANSITION_OPACITY: number = 0;

  /**
   * Width of the top search box.
   */
  static readonly TOP_SEARCH_WIDTH: number = 24;

  /**
   * Width of the search.
   */
  static readonly SEARCH_WIDTH: number = 64;
}