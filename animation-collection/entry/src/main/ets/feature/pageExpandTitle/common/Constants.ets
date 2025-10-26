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
export default class Constants {
  /**
   * Content drop-down distance, which is the threshold for triggering the title to continue to drop down.
   */
  public static readonly CONTENT_DOWN_Y_THRESHOLD: number = 180;

  /**
   * Max. icon drop-down distance.
   */
  public static readonly MENU_DOWN_Y_MAX_VALUE: number = 20;

  /**
   * Maximum distance of the title drop-down list box.
   */
  public static readonly TITLE_DOWN_Y_MAX_VALUE: number = 30;

  /**
   * Maximum value of the title zoom.
   */
  public static readonly TITLE_SCALE_MAX_VALUE: number = 1.1;

  /**
   * Default value for title zoom.
   */
  public static readonly TITLE_SCALE_DEFAULT_VALUE: number = 1;

  /**
   * Set the aspect ratio of the note picture.
   */
  public static readonly ANIMATE_DURATION_DRAG: number = 500;

  /**
   * Set the aspect ratio of the note picture.
   */
  public static readonly ANIMATE_DURATION_BACK: number = 300;

  /**
   * Set the spacing between the search box and each note layout.
   */
  public static readonly SEARCH_MEMO_SPACE: number = 12;

  /**
   * Initial coordinate position.
   */
  public static readonly INIT_COORDINATE: number = 0;

  /**
   * Sets the distance of the panning effect when pulling down.
   */
  public static readonly TRANSLATE_Y: number = -50;

  /**
   * Setting the Maximum Number of Rows Displayed on the Text Component.
   */
  public static readonly MAX_TEXT_LINES: number = 1;

  /**
   * Set the layout spacing for each note.
   */
  public static readonly MEMO_COL_SPACE: number = 5;

  /**
   * Set the aspect ratio of the note picture.
   */
  public static readonly MEMO_IMAGE_ASPECT_RATIO: number = 1;

  /**
   * Maximum Percentage.
   */
  public static readonly LAYOUT_MAX_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  public static readonly LAYOUT_NINETY_PERCENT: string = '90%';

  /**
   * Prior to zone change.
   */
  public static readonly AREA_HEIGHT_BEFORE: string = '88%';

  /**
   * After the change of area.
   */
  public static readonly AREA_HEIGHT_AFTER: string = '75%';

  /**
   * Seventy percent.
   */
  public static readonly LAYOUT_SEVENTY_PERCENT: string = '70%';

  /**
   * Eight percent.
   */
  public static readonly LAYOUT_EIGHT_PERCENT: string = '8%';
}