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

export class CommonConstants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';
  /**
   * Font weight 500.
   */
  static readonly FONT_WEIGHT_500: number = 500;
  /**
   * Text opacity.
   */
  static readonly TEXT_OPACITY: number[] = [1, 0.4, 0.6, 0.05];
  /**
   * Window util.
   */
  static readonly WINDOW_UTIL: string = 'windowUtil';
  /**
   * Default window width.
   */
  static readonly DEFAULT_WINDOW_WIDTH: number = 331;
  /**
   * Lg sidebar width.
   */
  static readonly LG_SIDEBAR_WIDTH: number = 96;
  /**
   * Two.
   */
  static readonly TWO: number = 2;
  /**
   * Three.
   */
  static readonly THREE: number = 3;
  /**
   * Four.
   */
  static readonly FOUR: number = 4;
  /**
   * Five.
   */
  static readonly FIVE: number = 5;
  /**
   * Width unit.
   */
  static readonly WIDTH_UNIT: string = 'vp';
  /**
   *  Constant for screen dpi.
   */
  static readonly SCREEN_DPI_CONSTANT: number = 160;
  /**
   * Device types.
   */
  static readonly DEVICE_TYPES: string[] = ['2in1'];
  /**
   * Tab bar height for sm and md.
   */
  static readonly TAB_BAR_HEIGHT: number = 56;
  /**
   * Bottom rect height.
   */
  static readonly BOTTOM_RECT_HEIGHT: number = 24;
  /**
   * Swiper height.
   */
  static readonly SWIPER_HEIGHT: number = 367;
  /**
   * Swiper margin.
   */
  static readonly SWIPER_MARGIN: number = 172;
  /**
   * Swiper item space.
   */
  static readonly SWIPER_ITEM_SPACE: number = 12;
  /**
   * Graphic aspect ratio.
   */
  static readonly GRAPHIC_ASPECT_RATIO: number = 0.74;
  /**
   * Default delay.
   */
  static readonly DEFAULT_DURATION: number = 500;
  /**
   * Slip coefficient.
   */
  static readonly HEIGHT_COEFFICIENTS: number = 0.2;
  /**
   * Slip coefficient.
   */
  static readonly MARGIN_COEFFICIENTS: number = 0.1;
  /**
   * Word weight 700.
   */
  static readonly FONT_WEIGHT_700: number = 700;
  /**
   * Word weight 400.
   */
  static readonly FONT_WEIGHT_400: number = 400;
  /**
   * Word weight 600.
   */
  static readonly FONT_WEIGHT_600: number = 600;
  /**
   * Dish lg index.
   */
  static readonly DISH_LG_INDEX: number = 16;
  /**
   * Dish index.
   */
  static readonly DISH_INDEX: number = 4;
  /**
   * Gradient color angle.
   */
  static readonly ANGLE_IMAGE: number = 180;
  /**
   * Gradient color index.
   */
  static readonly LINEAR_GRADIENT_INDEX: number = 0.16;
  /**
   * Grid column span list.
   */
  static readonly OFFSET_ARRAY: number[] = [3, 10, 20, 30, 40, 50];
  /**
   * Attribute adaptation.
   */
  static readonly SELF_ADAPTING: string = 'auto';
  /**
   * NavDestination default route.
   */
  static readonly DEFAULT_ROUTE: string = 'default';
  /**
   * Shared element transition id.
   */
  static readonly GRAPHIC_GEOMETRY_ID: string = 'picture';
  /**
   * Image component id.
   */
  static readonly GRAPHIC_IMAGE_ID: string = 'image2';
  /**
   * Home page route.
   */
  static readonly PAGE_ROUTER_INDEX: string = 'button';
  /**
   * The page is routed to the food group buying page.
   */
  static readonly PAGE_ROUTER_FOOD_LIST: string = 'FoodList';
  /**
   * Page routed to travel experience page.
   */
  static readonly PAGE_ROUTER_GRAPHIC_TEXT: string = 'GraphicText';
  /**
   * The page is routed to the live page.
   */
  static readonly PAGE_ROUTER_LIVING: string = 'Living';
  /**
   * Default spacing.
   */
  static readonly DEFAULT_SPACE: string = '12vp';
  /**
   * Fifty percent.
   */
  static readonly FIFTY_PERCENT: Percentage = '50%';
  /**
   * Twenty-four percent.
   */
  static readonly TWENTY_FOUR_PERCENT: string = '24%';
  /**
   * Forty percent.
   */
  static readonly FORTY_PERCENT: Percentage = '40%';
  /**
   * Thirty-three percent..
   */
  static readonly THIRTY_THREE_PERCENT: string = '33.33%';
  /**
   * Fifty percent.
   */
  static readonly FIFTY_PERCENT_STRING: string = '50%';
  /**
   * Forty percent.
   */
  static readonly FORTY_PERCENT_STRING: string = '40%';
  /**
   * Thirty-seven point five percent.
   */
  static readonly THIRTY_SEVEN_PERCENT: string = '37.5%';
  /**
   * Sixty percent.
   */
  static readonly SIXTY_PERCENT: string = '60%';
  /**
   * Seventy percent.
   */
  static readonly SEVENTY_PERCENT: string = '70%';
  /**
   * Ninety percent.
   */
  static readonly NINETY_PERCENT: string = '90%';
  /**
   * Eighty-three thirty-three percent.
   */
  static readonly EIGHTY_THREE_PERCENT: string = '83.33%';
  /**
   * Gradient start color.
   */
  static readonly LINEAR_GRADIENT_FIRST: string = 'rgba(0,0,0,0)';
  /**
   * Gradient color.
   */
  static readonly LINEAR_GRADIENT_SECOND: string = 'rgba(0,0,0,0.68)';
  /**
   * Currency symbol.
   */
  static readonly CURRENCY_SYMBOL: string = '¥';
  /**
   * Currency unit.
   */
  static readonly CURRENCY_UNIT: string = '/人';
  /**
   * Swiper height.
   */
  static readonly TEXT_SWIPER_HEIGHT: string = '480vp';
  /**
   * Column space.
   */
  static readonly COLUMN_SPACE: string = '16vp';
  /**
   * Column space.
   */
  static readonly COLUMN_SPACE_LIVING: string = '12vp';
  /**
   * Column space.
   */
  static readonly COLUMN_SPACE_HOME: string = '8vp';
  /**
   * Font family HarmonyHeiTi.
   */
  static readonly FONT_FAMILY_BLACK: string = 'HarmonyHeiTi';
  /**
   * Animate duration.
   */
  static readonly ANIMATE_DURATION: number = 500;
  /**
   * Icon image position.
   */
  static readonly ICON_IMAGE_POSITION: number = 16;
  /**
   * Graphic descriptions.
   */
  static readonly GRAPHIC_DESCRIPTIONS: string = `来自西伯利亚的海鸥
每年冬天都会来到深圳湾公园
-
—封来自西伯利亚的蓝色情书公
海鸥回来了，守约的是海鸥，失约的是人世海鸥不再眷恋大海，可以飞更远
-
📍：深圳湾公园D2出口
📷:尼康Z6➕24-120mm
🎨:Photoshop
-
-
拍摄技巧：因为海鸥运动的非常快，建议优先使用快门优先模式，用快的快门速度可以清晰的拍到海鸥飞行时的姿态。
海鸥需要抓拍需要开启高速连拍模式，要有一定的耐心~
-
拍摄时间：最好选择下午去`;
}