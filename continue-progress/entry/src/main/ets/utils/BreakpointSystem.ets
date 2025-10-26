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

import { BreakpointConstants } from '../constants/BreakpointConstants';

declare interface BreakPointTypeOption<T> {
  sm?: T,
  md?: T,
  lg?: T,
  xl?: T
}

export class BreakpointType<T> {
  public options: BreakPointTypeOption<T>;

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option;
  }

  getValue(currentPoint: string): T {
    let point: T;
    switch (currentPoint) {
      case BreakpointConstants.BREAKPOINT_SM:
        point = this.options.sm as T;
        break;
      case BreakpointConstants.BREAKPOINT_MD:
        point = this.options.md as T;
        break;
      case BreakpointConstants.BREAKPOINT_LG:
        point = this.options.lg as T;
        break;
      case BreakpointConstants.BREAKPOINT_XL:
        if (this.options.xl) {
          point = this.options.xl as T;
        } else {
          point = this.options.lg as T;
        }
        break;
      default:
        point = this.options.sm as T;
        break;
    }
    return point;
  }
}