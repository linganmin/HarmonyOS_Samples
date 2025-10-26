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
export class Constants {
  /**
   * Allocate remaining space automatically.
   */
  static readonly LAYOUT_WEIGHT: number = 1;

  /**
   * Default List Interval.
   */
  static readonly LIST_SPACE: number = 8;

  /**
   * X-axis position of the jump button: 50% of the width of the parent component.
   */
  static readonly JUMP_POSITION_X: string = '50%';

  /**
   * Y-axis position of the jump button: 90% of the height of the parent component.
   */
  static readonly JUMP_POSITION_Y: string = '90%';

  /**
   * 50% of the width of the jump button.
   */
  static readonly JUMP_MARK_ANCHOR_X: string = '50%';

  /**
   * Maximum width.
   */
  static readonly LAYOUT_MAX: string = '100%';

  /**
   * Common initialization.
   */
  public static readonly COMM_INIT: number = 0;
}