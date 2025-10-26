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

import { FunctionType } from '@ohos/commons/Index';
import { AttractionModel } from '../viewmodel/AttractionModel';

export class HomeConstants {
  /**
   * Function judge number.
   */
  static readonly FUNCTION_SIZE_JUDGE: number = 6;

  /**
   * List item space.
   */
  static readonly LIST_ITEM_SPACE: number = 5;

  /**
   * Away from you.
   */
  static readonly AWAY_FROM: string = '距你';

  /**
   * Metre.
   */
  static readonly METRE: string = '米';

  /**
   * Function row width.
   */
  static readonly FUNCTION_ROW_WIDTH: string = '90%';

  /**
   * Divider stroke width.
   */
  static readonly DIVIDER_STROKE_WIDTH: number = 1;

  /**
   * Result list differ height.
   */
  static readonly LIST_DIFFER_HEIGHT: number = 94;

  /**
   * Swiper item space.
   */
  static readonly SWIPER_ITEM_SPACE: number = 12;

  /**
   * Search bar width.
   */
  static readonly SEARCHBAR_WIDTH: string = '100% - 48';

  /**
   * Text width.
   */
  static readonly TEXT_WIDTH: string = '70%';

  /**
   * Functions array.
   */
  static readonly FUNCTIONS: Array<FunctionType> = [
    {
      id: 1,
      icon: $r('app.media.icon_drive'),
      desc: $r('app.string.drive')
    },
    {
      id: 2,
      icon: $r('app.media.icon_Metro'),
      desc: $r('app.string.metro')
    },
    {
      id: 3,
      icon: $r('app.media.icon_taxi'),
      desc: $r('app.string.taxi')
    },
    {
      id: 4,
      icon: $r('app.media.icon_bus'),
      desc: $r('app.string.bus')
    },
    {
      id: 5,
      icon: $r('app.media.icon_hotel'),
      desc: $r('app.string.hotel')
    },
    {
      id: 6,
      icon: $r('app.media.icon_Attractions'),
      desc: $r('app.string.attractions')
    },
    {
      id: 7,
      icon: $r('app.media.icon_buy'),
      desc: $r('app.string.buy')
    },
    {
      id: 8,
      icon: $r('app.media.icon_download'),
      desc: $r('app.string.download')
    },
    {
      id: 9,
      icon: $r('app.media.icon_drive2'),
      desc: $r('app.string.drive2')
    },
    {
      id: 10,
      icon: $r('app.media.icon_more'),
      desc: $r('app.string.more')
    }
  ];

  /**
   * Discount attractions info.
   */
  static readonly DISCOUNT_ATTRACTIONS: Array<AttractionModel> = [
    {
      id: 1,
      icon: $r('app.media.attraction1'),
      name: $r('app.string.attraction1')
    },
    {
      id: 2,
      icon: $r('app.media.attraction2'),
      name: $r('app.string.attraction2')
    },
    {
      id: 3,
      icon: $r('app.media.attraction3'),
      name: $r('app.string.attraction3')
    },
    {
      id: 4,
      icon: $r('app.media.attraction4'),
      name: $r('app.string.attraction4')
    }
  ];
}