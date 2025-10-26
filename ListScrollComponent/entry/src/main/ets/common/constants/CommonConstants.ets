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
   * Index title height.
   */
  static readonly INDEX_TITLE_HEIGHT: number = 112;
  /**
   * List content height.
   */
  static readonly LIST_CONTENT_HEIGHT: string = '110%';
  /**
   * Routes.
   */
  static readonly ROUTES: Route[] = [
    {
      title: $r('app.string.scenario1'),
      child: [
        { text: 'SameItemListPage', title: $r('app.string.page_same_item'), to: 'SameItemListPage' },
      ]
    },
    {
      title: $r('app.string.scenario2'),
      child: [
        { text: 'CombineItemListPage', title: $r('app.string.page_combine_item'), to: 'CombineItemListPage' },
      ]
    },
    {
      title: $r('app.string.scenario3'),
      child: [
        { text: 'DifferentItemListPage', title: $r('app.string.page_different_item'), to: 'DifferentItemListPage' },
      ]
    },
    {
      title: $r('app.string.scenario4'),
      child: [
        { text: 'GroupLayoutListPage', title: $r('app.string.page_group_layout'), to: 'GroupLayoutListPage' },
      ]
    },
    {
      title: $r('app.string.scenario5'),
      child: [
        { text: 'TabsCeilingListPage', title: $r('app.string.page_tabs_ceiling'), to: 'TabsCeilingListPage' },
      ]
    },
  ];
}

/**
 * Route type define.
 */
export interface Route {
  title: string | Resource;
  child: Array<ChildRoute>;
}

/**
 * ChildRoute type define.
 */
export interface ChildRoute {
  text: string | Resource;
  title?: string | Resource | null;
  description?: string;
  to: string;
}
