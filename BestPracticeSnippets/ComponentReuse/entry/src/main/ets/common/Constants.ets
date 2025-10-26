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

import { NavDestinationItem } from '../pages/Index';

/**
 * Common constants for all features
 */
export class Constants {

  /**
   * Default List Interval.
   */
  public static readonly LIST_SPACE: number = 12;

  /**
   * Maximum width.
   */
  public static readonly LAYOUT_MAX: string = '100%';

  /**
   * Common initialization.
   */
  public static readonly COMM_INIT: number = 0;

  /**
   * NavDestination item0.
   */
  public static readonly NAV_DESTINATION_ITEM_0: string = 'NavDestination_item_0';

  /**
   * NavDestination item1.
   */
  public static readonly NAV_DESTINATION_ITEM_1: string = 'NavDestination_item_1';

  /**
   * NavDestination item2.
   */
  public static readonly NAV_DESTINATION_ITEM_2: string = 'NavDestination_item_2';

  /**
   * NavDestination item3.
   */
  public static readonly NAV_DESTINATION_ITEM_3: string = 'NavDestination_item_3';

  /**
   * NavDestinationItem
   */
  public static readonly NavDestinationData: NavDestinationItem[] = [
    {
      id: Constants.NAV_DESTINATION_ITEM_0, detail: $r('app.string.nav_destination_item0')
    },
    {
      id: Constants.NAV_DESTINATION_ITEM_1, detail: $r('app.string.nav_destination_item1')
    },
    {
      id: Constants.NAV_DESTINATION_ITEM_2, detail: $r('app.string.nav_destination_item2')
    },
    {
      id: Constants.NAV_DESTINATION_ITEM_3, detail: $r('app.string.nav_destination_item3')
    },
  ];
}