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

/**
 * Common constants for all features.
 */
export default class CommonConstants {

  /**
   * Maximum width.
   */
  static readonly PERCENTAGE_MAX: string = '100%';

  /**
   * Ninety percent.
   */
  static readonly NINETY_PERCENT_WIDTH: string = '90%';

  /**
   * Width of the search box.
   */
  static readonly SEARCH_BOX_WIDTH: string = '91.1%';

  /**
   * Turn off the outside right margin of the keyboard picture.
   */
  static readonly DOWN_IMAGE_RIGHT: string = '6.8%';

  /**
   * Search logic.
   */
  static readonly TEXT_SEARCH: string = '搜索';

  /**
   * Space logic.
   */
  static readonly TEXT_SPACE: string = '空格';

  /**
   * Switch to Securities Keyboard.
   */
  static readonly TEXT_DIGIT: string = '123';

  /**
   * Clear logic.
   */
  static readonly TEXT_CLEAR: string = '清空';

  /**
   * Switch to English keyboard.
   */
  static readonly TEXT_ENGLISH: string = 'ABC';

  /**
   * Add text box content.
   */
  static readonly ADD_CHARACTERS: string = 'add';

  /**
   * Delete text box content.
   */
  static readonly DELETE_CHARACTERS: string = 'delete';

  /**
   * Clear the text box.
   */
  static readonly CLEAR_CHARACTERS: string = 'clear';

  /**
   * Add logic.
   */
  static readonly STRING_CHARACTERS: string = 'string';

  /**
   * Type of the user-defined input method. The options are as follows:
   * 0: securities keyboard;
   * 1: English keyboard.
   */
  static readonly KEYBOARD_TYPE_DIGIT: number = 0;

  /**
   * Type of the user-defined input method. The options are as follows:
   * 0: securities keyboard;
   * 1: English keyboard.
   */
  static readonly KEYBOARD_TYPE_ENGLISH: number = 1;

  /**
   * Initializes the position of the cursor in the search box.
   */
  static readonly CURSOR_POSITION_INIT: number = 0;

  /**
   * Common initial value.
   */
  static readonly COMMON_INITIAL_VALUE: number = 0;

  /**
   * Maximum number of characters that can be entered in the text box.
   */
  static readonly MAXIMUM_NUMBER_INPUTS: number = 14;

  /**
   * Aspect ratio of the image component.
   */
  static readonly IMAGE_ASPECT_RATIO: number = 1;

  /**
   * The proportion weight is 1.
   */
  static readonly LAYOUT_WEIGHT_ONE: number = 1;

  /**
   * The proportion weight is 2.
   */
  static readonly LAYOUT_WEIGHT_TWO: number = 2;
}