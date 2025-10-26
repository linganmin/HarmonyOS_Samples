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
   * FontWeight.borderRadius 700
   */
  static readonly FONT_WEIGHT_LG: number = 700;

  /**
   * FontWeight.borderRadius 600
   */
  static readonly FONT_WEIGHT_MD: number = 600;

  /**
   * FontWeight.borderRadius 500
   */
  static readonly FONT_WEIGHT: number = 500;

  /**
   * FontWeight.borderRadius 50
   */
  static readonly FONT_WEIGHT_SM: number = 50;

  /**
   * Click on the list of tips/history to go to the animation duration of the example page.
   */
  static readonly TO_EXAMPLE_PAGE_DURATION: number = 20;

  /**
   * Device size
   */
  static readonly DEFAULT_DEVICE_SIZE: number = 600;

  /**
   * BorderRadius
   */
  static readonly BORDER_RADIUS: number = 24;

  /**
   * Detail height
   */
  static readonly DETAIL_HEIGHT: number = 72;

  /**
   * List space.
   */
  static readonly LIST_SPACE: number = 72;

  /**
   * Half opacity
   */
  static readonly HALF_OPACITY: number = 0.5;

  /**
   * Maximum number of input characters
   */
  static readonly PHONE_NUMBER_LENGTH = 11;

  /**
   * The animation duration is 300 ms
   */
  static readonly EFFECT_DURATION = 300;

  /**
   * The animation duration is 400 ms
   */
  static readonly EFFECT_DURATION_FOUR = 400;

  /**
   * Spacing of child elementsconst 10
   */
  static readonly SPACE_TEN = 10;

  /**
   * Spacing of child elementsconst 15
   */
  static readonly SPACE_FIFTEEN = 15;

  /**
   * Spacing of child elementsconst 30
   */
  static readonly SPACE_THIRTY = 30;

  /**
   * Spacing of child elements
   */
  static readonly SPACE_TWENTY = 20;

  /**
   * FontWeight.seventy
   */
  static readonly FONT_WEIGHT_SEVENTY = 70;

  /**
   * FontWeight.twenty
   */
  static readonly FONT_WEIGHT_NORMAL = 20;

  /**
   * Default status height
   */
  static readonly DEFAULT_STATUS_HEIGHT: number = 32;

  /**
   * Default text max line
   */
  static readonly DEFAULT_TEXT_LINE: number = 2;

  /**
   * Default row height * 2
   */
  static readonly DEFAULT_ROW_HEIGHT: number = 168;

  /**
   * Default row spacing of waterfall flow
   */
  static readonly DEFAULT_ROW_SPACING_WATERFALL: number = 8;

  /**
   * Default number 0
   */
  static readonly DEFAULT_ZERO: number = 0;

  /**
   * Default number 1
   */
  static readonly DEFAULT_ONE: number = 1;

  /**
   * Default number -1
   */
  static readonly DEFAULT_NEGATIVE_ONE: number = -1;

  /**
   * None of the opacity
   */
  static readonly NONE_OPACITY: number = 0;

  /**
   * Click to search for the duration of the animation
   */
  static readonly CLICK_SEARCH_ANIMATION_DURATION: number = 100;

  /**
   * Transition animation duration
   */
  static readonly TRANSITION_ANIMATION_DURATION: number = 200;

  /**
   * Search history content animation duration
   */
  static readonly SEARCH_HISTORY_ANIMATION_DURATION: number = 350;

  /**
   * Animation delay 150
   */
  static readonly ANIMATION_DELAY: number = 150;

  /**
   * Animation delay 100
   */
  static readonly ANIMATION_DELAY_ONE: number = 100;

  /**
   * Parameter velocity for generating the animation curve from 0 to 1
   */
  static readonly ANIMATION_CURVE_VELOCITY: number = 0;

  /**
   * Parameter mass for generating the animation curve from 0 to 1
   */
  static readonly ANIMATION_CURVE_MASS: number = 1;

  /**
   * Parameter stiffness for generating the animation curve from 0 to 1
   */
  static readonly ANIMATION_CURVE_STIFFNESS: number = 342;

  /**
   * Parameter damping for generating the animation curve from 0 to 1
   */
  static readonly ANIMATION_CURVE_DAMPING: number = 38;

  /**
   * Constructs a third-order Bezier curve X1
   */
  static readonly ANIMATION_CURVE_X1: number = 0.33;

  /**
   * Constructs a third-order Bezier curve Y1
   */
  static readonly ANIMATION_CURVE_Y1: number = 0;

  /**
   * Constructs a third-order Bezier curve X2
   */
  static readonly ANIMATION_CURVE_X2: number = 0.67;

  /**
   * Constructs a third-order Bezier curve Y2
   */
  static readonly ANIMATION_CURVE_Y2: number = 1;

  /**
   * Creates a translate transition effect.
   */
  static readonly TRANSITION_EFFECT_Y: number = 30;

  /**
   * Creates an opacity transition effect with alpha value
   */
  static readonly TRANSITION_OPACITY: number = 0;

  /**
   * Width of the top search box
   */
  static readonly TOP_SEARCH_WIDTH: number = 24;

  /**
   * Width of the search
   */
  static readonly SEARCH_WIDTH: number = 80;

  /**
   * 0.9 of the opacity
   */
  static readonly ZERO_NINE_OPACITY: number = 0.9;

  /**
   * Font family HeiTi
   */
  static readonly HARMONY_HEI_TI_FONT_FAMILY = 'HarmonyHeiTi';

  /**
   * Font family Medium
   */
  static readonly HARMONY_HEITI_MEDIUM_FONT_FAMILY = 'HarmonyHeiTi-Medium';

  /**
   * Font family Bold
   */
  static readonly HARMONY_HEITI_BOLD_FONT_FAMILY = 'HarmonyHeiTi-Bold';

  /**
   * Columns template 1fr 1fr
   */
  static readonly COLUMNS_TEMPLATE = '1fr 1fr';

  /**
   * Columns template 1fr
   */
  static readonly COLUMNS_TEMPLATE_ONE = '1fr';

  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Eighty percent.
   */
  static readonly EIGHTY_PERCENT: string = '80%';

  /**
   * Ten percent.
   */
  static readonly TEN_PERCENT: string = '10%';

  /**
   * Ninety Four percent.
   */
  static readonly NINETY_FOUR_PERCENT: string = '94%';

  /**
   * Animation Duration.
   */
  static readonly ANIMATE_DURATION: number = 200;

  /**
   * Minimum Animation Duration.
   */
  static readonly ANIMATE_DURATION_MIN: number = 100;

  /**
   * Card Minimum Animation Duration.
   */
  static readonly CARD_ANIMATE_DURATION_MIN: number = 5;

  /**
   * zIndex Large.
   */
  static readonly Z_INDEX_LARGE: number = 2;

  /**
   * zIndex Medium.
   */
  static readonly Z_INDEX_MEDIUM: number = 1;

  /**
   * zIndex Small.
   */
  static readonly Z_INDEX_SMALL: number = 0;

  /**
   * Vertical spacing between elements in a vertical layout.
   */
  static readonly CARD_LIST_SPACE: number = 2;

  /**
   * border radius 6
   */
  static readonly BORDER_RADIUS_NORMAL: number = 6;

  /**
   * border radius 12
   */
  static readonly BORDER_RADIUS_NORMAL_DOUBLE: number = 12;

  /**
   * border radius 30
   */
  static readonly BORDER_RADIUS_NORMAL_MD: number = 30;

  /**
   * Circle width height
   */
  static readonly CIRCLE_WIDTH_NORMAL: number = 6;

  /**
   * Circle width width
   */
  static readonly CIRCLE_HEIGHT_NORMAL: number = 6;

  /**
   * averageCalories 26
   */
  static readonly AVERAGE_CALORIES_ONE: number = 26;

  /**
   * averageCalories 60
   */
  static readonly AVERAGE_CALORIES_TWO: number = 60;

  /**
   * averageCalories 606
   */
  static readonly AVERAGE_CALORIES_THREE: number = 606;

  /**
   * averageCalories 56
   */
  static readonly AVERAGE_CALORIES_FOUR: number = 56;

  /**
   * averageCalories 365
   */
  static readonly AVERAGE_CALORIES_FIVE: number = 365;

  /**
   * strokeWidth
   */
  static readonly STROKE_WIDTH: number = 24;
}