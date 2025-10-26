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

export class HomeConstants {
  /**
   * Footer tab topics.
   */
  public static readonly FOOTER_TOPIC_LIST: string[] = ['首页', '分类', '发现', '购物袋', '我的'];

  /**
   * Footer tab english topics.
   */
  public static readonly FOOTER_TOPIC_LIST_EN: string[] = ['home', 'categorize', 'found', 'shopping', 'mine'];
  /**
   * Footer topic icons.
   */
  public static readonly FOOTER_TOPIC_ICONS: Resource[] =
    [$r('app.media.ic_public_home_filled'), $r('app.media.ic_public_class'),
      $r('app.media.ic_public_discover'), $r('app.media.ic_public_shopping'), $r('app.media.ic_public_mine')];
  /**
   * Footer topic icons.
   */
  public static readonly FOOTER_TOPIC_ICONS_SELECTED: Resource[] =
    [$r('app.media.ic_public_home_filled'), $r('app.media.ic_public_class'),
      $r('app.media.ic_public_discover'), $r('app.media.ic_public_shopping'), $r('app.media.ic_public_mine')];
  /**
   * Function default icons.
   */
  public static readonly FUNCTION_DEFAULT_ICONS: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  /**
   * Function area two lines height
   */
  public static readonly FUNCTION_TWO_LINES_HEIGHT: number = 176;
  /**
   * Function area three lines height
   */
  public static readonly FUNCTION_THREE_LINES_HEIGHT: number = 254;
  /**
   * Function rows page one.
   */
  public static readonly FUNCTION_ROWS_PAGE_ONE: string = '1fr 1fr';
  /**
   * Function rows page two.
   */
  public static readonly FUNCTION_ROWS_PAGE_TWO: string = '1fr 1fr 1fr';
  /**
   * Function column page two.
   */
  public static readonly FUNCTION_COLUMN: string = '1fr 1fr 1fr 1fr 1fr';
  /**
   * index page.
   */
  public static readonly INDEX_PAGE: string = '首页';
  /**
   * english index page.
   */
  public static readonly INDEX_PAGE_EN: string = 'home';
}