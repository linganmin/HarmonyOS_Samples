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

export class StackConstant {
  /**
   * Initial height of the backup search box.
   */
  static readonly SEARCH_HEIGHT_RAW: number = 100;

  /**
   * Backup height of quick capture icon area 2.
   */
  static readonly HEIGHT_LIST_2_RAW: number = 100;

  /**
   * Default maximum spacing of icon list 3.
   */
  static readonly MAX_MARGIN_SPACE: number = 25;

  /**
   * Default minimum spacing of icon list 3.
   */
  static readonly MIN_MARGIN_SPACE: number = 12;

  /**
   * Calculates the transparency of icon list 1.
   */
  static readonly ICON_LIST_1_RAW: number = 100;

  /**
   * Calculates the transparency of icon list 2.
   */
  static readonly ICON_LIST_2_RAW: number = 120;

  /**
   * Calculates the transparency of icon list 3.
   */
  static readonly ICON_LIST_3_RAW: number = 140;

  /**
   * Occupied height.
   */
  static readonly USED_SPACE: number = 110;

  /**
   * fonts setting transparency.
   */
  static readonly OPACITY: number = 0.6;

  /**
   * Product list column margin.
   */
  static readonly MARGIN_TOP: number = 200;

  /**
   * Spacing between icons.
   */
  static readonly ICON_VIEW_SPACE: number = 10;

  /**
   * Number of columns in list 1.
   */
  static readonly ICON_LIST_COLUMNS_1: number = 4;

  /**
   * Number of columns in list 2.
   */
  static readonly ICON_LIST_COLUMNS_2: number = 5;

  /**
   * Spacing between column subcomponents.
   */
  static readonly COLUMN_SPACE: number = 5;

  /**
   * Price control offset.
   */
  static readonly OFFSET: number = -4;

  /**
   * WaterFlow component vertical spacing.
   */
  static readonly COLUMNS_GAP: number = 12;

  /**
   * Horizontal spacing between WaterFlow components.
   */
  static readonly ROWS_GAP: number = 12;

  /**
   * 100 percent.
   */
  static readonly FULL_PERCENT: string = '100%';
}