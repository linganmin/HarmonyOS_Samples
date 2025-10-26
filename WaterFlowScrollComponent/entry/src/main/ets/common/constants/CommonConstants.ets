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
   * Water flow layout columns template.
   */
  static readonly WATER_FLOW_COLUMNS_TEMPLATE: string = '1fr 1fr';
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
  static readonly CACHED_COUNT: number = 6;
  /**
   * quick return to top function event
   */
  static readonly EVENT_QUICK_TOP_FUNC: string = 'event_quick_top_func';
  /**
   * hide item menu event.
   */
  static readonly EVENT_HIDE_ITEM_MENU: string = 'event_hide_item_menu';
  /**
   * remove item event
   */
  static readonly EVENT_REMOVE_ITEM: string = 'event_remove_item';
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
   * Font width 80%.
   */
  static readonly EIGHTY_FONT_WIDTH: string = '80%';
  /**
   * Drawer divider width.
   */
  static readonly DIVIDER_DRAWER_WIDTH: string = '90%';
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
   * Flow height.
   */
  static readonly FLOW_HEIGHT: Length = 244;
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
  static readonly PADDING: number = 16;
  static readonly ROWS_GAP: number = 12;
  static readonly COLUMNS_GAP: number = 10;
  static readonly NOT_FOUND_INDEX: number = -1;
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
          text: $r('app.string.scenario_waterFlow'),
          to: 'StandardWaterFlowPage'
        }
      ]
    },
    {
      title: $r('app.string.scenario2'),
      child: [
        {
          text: $r('app.string.scenario_waterFlow2'),
          to: 'CombineWaterFlowPage'
        }
      ]
    },
    {
      title: $r('app.string.scenario3'),
      child: [
        {
          text: $r('app.string.scenario_waterFlow3'),
          to: 'TabBarPage'
        }
      ]
    },
    {
      title: $r('app.string.scenario4'),
      child: [
        {
          text: $r('app.string.scenario_waterFlow4'),
          to: 'StickyWaterFlowPage'
        }
      ]
    }
  ];
}

/**
 * Route type define.
 */
export interface Route {
  title: string | Resource,
  child: Array<ChildRoute>
}

/**
 * ChildRoute type define.
 */
export interface ChildRoute {
  text: string | Resource,
  to: string
}


