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
 * Constants for breakpoint.
 */
export class BreakpointConstants {
  /**
   * Breakpoints that represent small device types.
   */
  public static readonly BREAKPOINT_SM: string = 'sm';
  /**
   * Breakpoints that represent middle device types.
   */
  public static readonly BREAKPOINT_MD: string = 'md';
  /**
   * Breakpoints that represent large device types.
   */
  public static readonly BREAKPOINT_LG: string = 'lg';
  /**
   * Breakpoint range sm
   */
  public static readonly RANGE_SM: string = '(320vp<=width<600vp)';
  /**
   * Breakpoint range md
   */
  public static readonly RANGE_MD: string = '(600vp<=width<840vp)';
  /**
   * Breakpoint range lg
   */
  public static readonly RANGE_LG: string = '(840vp<=width)';
  /**
   * Breakpoint value sm/md/lg
   */
  public static readonly BREAKPOINT_VALUE: Array<string> = ['320vp', '600vp', '840vp'];
  /**
   * AppStorage key breakpoint
   */
  public static readonly BREAKPOINT_NAME: string = 'breakpoint';
  /**
   * Grid num two
   */
  public static readonly GRID_NUM_TWO = '1fr 1fr';
  /**
   * Grid num three
   */
  public static readonly GRID_NUM_THREE = '1fr 1fr 1fr';
  /**
   * Grid num four
   */
  public static readonly GRID_NUM_FOUR = '1fr 1fr 1fr 1fr';
  /**
   * SearchBar and WATER_FLOW margin left sm
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM: number = 16;
  /**
   * SearchBar and WATER_FLOW margin left md
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD: number = 24;
  /**
   * SearchBar and WATER_FLOW margin left LG
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG: number = 32;
  /**
   * SearchBar and WATER_FLOW margin right sm
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_SM: number = 16;
  /**
   * SearchBar and WATER_FLOW margin right md
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_MD: number = 24;
  /**
   * SearchBar and WATER_FLOW margin right lg
   */
  public static readonly SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG: number = 32;
  /**
   * Function margin right sm
   */
  public static readonly FUNCTION_MARGIN_RIGHT_SM: number = 10;
  /**
   * Function margin right md
   */
  public static readonly FUNCTION_MARGIN_RIGHT_MD: number = 24;
  /**
   * Function margin right lg
   */
  public static readonly FUNCTION_MARGIN_RIGHT_LG: number = 134;
  /**
   * Function margin left sm
   */
  public static readonly FUNCTION_MARGIN_LEFT_SM: number = 10;
  /**
   * Function margin left md
   */
  public static readonly FUNCTION_MARGIN_LEFT_MD: number = 24;
  /**
   * Function margin left lg
   */
  public static readonly FUNCTION_MARGIN_LEFT_LG: number = 134;
}