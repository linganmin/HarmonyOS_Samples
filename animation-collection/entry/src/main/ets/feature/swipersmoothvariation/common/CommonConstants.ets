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
 * Represents an interface for custom type data.
 *
 * @interface
 * @property {Resource} name
 * @property {Resource} image
 * @property {Resource} prompt
 */
export interface GridItemInfo {
  name: Resource
  image: Resource
  prompt?: Resource
};

export class CommonConstants{
  static readonly FULL_PERCENT: string = '100%';
  static readonly GRID_SINGLE_HEIGHT: number = 65;
  static readonly SWIPER_OFFSET: number = 23;
  static readonly GRID_DOUBLE_HEIGHT: number = 130;
  static readonly SCROLL_WIDTH: number = 340;
  static readonly SMALL_FONT_SIZE: number = 13;
  static readonly GRID_TEMPLATE: string = '1fr 1fr';
  static readonly GRID_SINGLE_TEMPLATE: string = '1fr';
  static readonly COLUMN_TEMPLATE: string = '1fr 1fr 1fr 1fr 1fr';
  static readonly DURATION_SWIPER: number = 0;
  static readonly DURATION_DOWN_PAGE: number = 400;

  static readonly DATA_PAGE_ONE: GridItemInfo[] = [
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi'), prompt: $r('app.string.first_prompt') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi'), prompt: $r('app.string.sec_prompt') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') },
    { name: $r('app.string.name_page_one'), image: $r('app.media.taxi') }
  ];
  // swiper的第二个页面数据
  static readonly DATA_PAGE_TWO: GridItemInfo[] = [
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') },
    { name: $r('app.string.name_page_two'), image: $r('app.media.car_icon2') }
  ];
  // swiper的第三个页面数据
  static readonly DATA_PAGE_THREE: GridItemInfo[] = [
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') },
    { name: $r('app.string.name_page_three'), image: $r('app.media.car_icon') }
  ];
  // swiper的第四个页面数据
  static readonly DATA_PAGE_FOUR: GridItemInfo[] = [
    { name: $r('app.string.name_page_four'), image: $r('app.media.taxi') }
  ];
}