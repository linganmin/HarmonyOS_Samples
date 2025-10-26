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
 * Constants for breakpoint.
 */
export class BreakpointConstants {
  /**
   * Breakpoints that represent small device types.
   */
  public static readonly BREAKPOINT_XS: string = 'xs';
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
   * Breakpoints representing the type of oversized equipment.
   */
  public static readonly BREAKPOINT_XL: string = 'xl';
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
  public static readonly BREAKPOINT_NAME: string = 'GesturesShare_breakpoint';
}