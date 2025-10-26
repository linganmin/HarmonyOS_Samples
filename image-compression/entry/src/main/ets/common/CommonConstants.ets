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
   * Maximum value of the picture quality range.
   */
  static readonly PICTURE_QUALITY_MAX: number = 100;

  /**
   * Least dichotomous unit.
   */
  static readonly  DICHOTOMY_ACCURACY: number = 10;

  /**
   * Image zoom-out times.
   */
  static readonly  REDUCE_SCALE: number = 0.4;

  /**
   * Separation distance.
   */
  static readonly  SPACE_TEN: number = 10;

  /**
   * Byte conversion.
   */
  static readonly  BYTE_CONVERSION: number = 1024;
}