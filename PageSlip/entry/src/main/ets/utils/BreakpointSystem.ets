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

import mediaQuery from '@ohos.mediaquery';
import { BreakpointConstants } from '../constants/BreakpointConstants';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getMediaQuery()!;
declare interface BreakPointTypeOption<T> {
  sm?: T,
  md?: T,
  lg?: T,
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
      default:
        point = this.options.sm as T;
        break;
    }
    return point;
  }
}

export class BreakpointSystem {
  private readonly listenerKey = 'change';
  private currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private smListener: mediaQuery.MediaQueryListener = context.matchMediaSync(BreakpointConstants.RANGE_SM);
  private mdListener: mediaQuery.MediaQueryListener = context.matchMediaSync(BreakpointConstants.RANGE_MD);
  private lgListener: mediaQuery.MediaQueryListener = context.matchMediaSync(BreakpointConstants.RANGE_LG);

  private updateCurrentBreakpoint(breakpoint: string): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      AppStorage.setOrCreate(BreakpointConstants.BREAKPOINT_NAME, this.currentBreakpoint);
    }
  }

  private isBreakpointSM = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_SM);
    }
  };

  private isBreakpointMD = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_MD);
    }
  };

  private isBreakpointLG = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_LG);
    }
  };

  public register(): void {
    this.smListener.on(this.listenerKey, this.isBreakpointSM);
    this.mdListener.on(this.listenerKey, this.isBreakpointMD);
    this.lgListener.on(this.listenerKey, this.isBreakpointLG);
  }

  public unregister(): void {
    this.smListener.off(this.listenerKey, this.isBreakpointSM);
    this.mdListener.off(this.listenerKey, this.isBreakpointMD);
    this.lgListener.off(this.listenerKey, this.isBreakpointLG);
  }
}