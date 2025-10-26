/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
export class CommonConstants {
  /**
   * Width the percentage of the 100.
   */
  static readonly FULL_WIDTH: string = '100%';

  /**
   * Height the percentage of the 100.
   */
  static readonly FULL_HEIGHT: string = '100%';

  /**
   * cached_count
   */
  static readonly CACHED_COUNT: number = 12;

  /**
   * Index content width.
   */
  static readonly INDEX_CONTENT_WIDTH: string = '91.1%';

  /**
   * Index divider height.
   */
  static readonly DIVIDER_HEIGHT: number = 0.5;

  /**
   * Index divider width.
   */
  static readonly DIVIDER_WIDTH: string = '93%';

  /**
   * Card title height.
   */
  static readonly CARD_TITLE_HEIGHT: number = 20;

  /**
   * Card text height.
   */
  static readonly CARD_TEXT_HEIGHT: number = 48;

  /**
   * Index title height.
   */
  static readonly INDEX_TITLE_HEIGHT: number = 112;

  /**
   * Border radius index list.
   */
  static readonly BORDER_RADIUS_INDEX_LIST: number = 18;

  /**
   * List content height.
   */
  static readonly LIST_CONTENT_HEIGHT: string = '110%';

  /**
   * Translate top.
   */
  static readonly TRANSLATE_TOP: number = -40;

  /**
   * Search text.
   */
  static readonly SEARCH_TEXT: string = 'search';

  /**
   * Refresh count.
   */
  static readonly REFRESH_COUNT: number = 100;

  /**
   * Load more count.
   */
  static readonly LOAD_MORE_COUNT: number = 20;

  /**
   * Video count.
   */
  static readonly VIDEO_COUNT: number = 5;

  /**
   * Image count.
   */
  static readonly IMAGE_COUNT: number = 4;

  /**
   * Video step count.
   */
  static readonly VIDEO_STEP_COUNT: number = 3;

  /**
   * The offset of refresh.
   */
  static readonly REFRESH_OFFSET: number = 56;

  /**
   * The height of sticky area.
   */
  static readonly STICKY_HEIGHT: number = 100;

  /**
   * The timeout of refresh.
   */
  static readonly REFRESH_TIMEOUT: number = 2000;

  /**
   * The timeout of load more.
   */
  static readonly LOAD_MORE_TIMEOUT: number = 1000;

  /**
   * The time of delete animation.
   */
  static readonly DELETE_ANIMATION_TIME: number = 500;

  /**
   * The min height of flow item.
   */
  static readonly FLOW_ITEM_MIN_HEIGHT: number = 80;

  /**
   * The max height of flow item.
   */
  static readonly FLOW_ITEM_MAX_HEIGHT: number = 180;

  /**
   * The max height of flow item.
   */
  static readonly STICK_MAX_OFFSET: number = 220;

  /**
   * The main size of section1.
   */
  static readonly SECTION1_ITEM_SIZE: number = 170;

  /**
   * The main size of section2.
   */
  static readonly SECTION2_ITEM_SIZE: number = 100;

  /**
   * The main size of section3.
   */
  static readonly SECTION3_ITEM_SIZE: number = 200;

  /**
   * The main size of section4.
   */
  static readonly SECTION4_ITEM_SIZE: number = 250;

  /**
   * Arr.
   */
  static readonly ARR: number[] = [1, 2, 3, 4, 5, 6];

  /**
   * colors.
   */
  static readonly COLORS: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7F];

  /**
   * Routes.
   */
  static readonly ROUTES: Route[] = [
    {
      title: $r('app.string.scenario1'),
      child: [
        {
          text: $r('app.string.scenario_sections'),
          to: 'SectionsHomePage'
        }
      ]
    },
    {
      title: $r('app.string.scenario2'),
      child: [
        {
          text: $r('app.string.scenario_sticky'),
          to: 'StickyHomePage'
        }
      ]
    }
  ];
}

/**
 * Route type define.
 */
export interface Route {
  title: string |Resource,
  child: Array<ChildRoute>
}

/**
 * ChildRoute type define.
 */
export interface ChildRoute {
  text: string|Resource,
  to: string
}