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

import { Permissions } from '@kit.AbilityKit';

/*
 * Public constants.
 */
export class CommonConstants {
  /*
   * The request permission.
   */
  static readonly REQUEST_PERMISSIONS: Array<Permissions> = [
    'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION'
  ];
  /*
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';
  /*
   * Title ID.
   */
  static readonly TITLE_ID: string = 'titleId';
  /*
   * Text ID.
   */
  static readonly TEXT_ID: string = 'textId';
  /*
   * List comm space.
   */
  static readonly LIST_COMM_SPACE: number = 8;
  /*
   * Maximum number of images that can be added.
   */
  static readonly MAX_ADD_PIC: number = 9;
  /*
   * Local info list width.
   */
  static readonly LOCAL_INFO_LIST_WIDTH: string = '95%';
  /*
   * Publish the width of the title.
   */
  static readonly PUBLISH_TITLE_WIDTH: string = '80%';
  /*
   * Maximum number of rows for publishing titles.
   */
  static readonly PUBLISH_TITLE_MAX_LINES: number = 2;
  /*
   * Default layout weight.
   */
  static readonly DEFAULT_LAYOUT_WEIGHT: number = 1;
  /*
   * Last location intercepted from the SM location information.
   */
  static readonly END_SM_LOCAL_INFO: number = 20;
  /*
   * Last location intercepted from the MD location information.
   */
  static readonly END_MD_LOCAL_INFO: number = 40;
  /*
   * Subscript of the number of characters to be truncated at the start of the position information.
   */
  static readonly START_MD_LOCAL_INFO: number = 0;
  /*
   * Omitted character.
   */
  static readonly OMITTED_CHARACTER: string = '...';
  /*
   * Current location information list.
   */
  static readonly CURRENT_LOCAL_INFO: ResourceStr[] = [
    $r('app.string.default_location', 1),
    $r('app.string.default_location', 2),
    $r('app.string.default_location', 3),
    $r('app.string.default_location', 4),
    $r('app.string.default_location', 5),
    $r('app.string.default_location', 6),
    $r('app.string.default_location', 7),
    $r('app.string.default_location', 8),
    $r('app.string.default_location', 9),
    $r('app.string.default_location', 10)
  ];
}