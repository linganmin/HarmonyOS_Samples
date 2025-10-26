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
import { CommonConstants } from '../common/CommonConstants';
import Logger from './Logger';

declare interface BreakPointTypeOption<T> {
  sm?: T,
  md?: T,
  lg?: T,
  xl?: T,
  xxl?: T
}

export class BreakpointType<T> {
  public options: BreakPointTypeOption<T>;

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option;
  }

  getValue(currentPoint: string): T {
    let value = this.options.sm as T;
    switch (currentPoint) {
      case CommonConstants.BREAKPOINT_SM:
        value = this.options.sm as T;
        break;
      case CommonConstants.BREAKPOINT_MD:
        value = this.options.md as T;
        break;
      case CommonConstants.BREAKPOINT_LG:
        value = this.options.lg as T;
        break;
      default:
        break;
    }
    return value;
  }
}

export class BreakpointSystem {
  private readonly listenerKey = 'change';
  private readonly tag: string = 'BreakpointSystem';
  private currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  private smListener: mediaQuery.MediaQueryListener | undefined;
  private mdListener: mediaQuery.MediaQueryListener | undefined;
  private lgListener: mediaQuery.MediaQueryListener | undefined;

  private updateCurrentBreakpoint(breakpoint: string): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      Logger.info(this.tag, `updateCurrentBreakpoint: ${this.currentBreakpoint}`);
      AppStorage.setOrCreate(CommonConstants.BREAKPOINT_NAME, this.currentBreakpoint);
    }
  }

  private isBreakpointSM = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_SM);
    }
  }
  private isBreakpointMD = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_MD);
    }
  }
  private isBreakpointLG = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_LG);
    }
  }

  public register(uiContext: UIContext): void {
    this.smListener = uiContext.getMediaQuery().matchMediaSync(CommonConstants.RANGE_SM);
    this.smListener.on(this.listenerKey, this.isBreakpointSM);
    this.mdListener = uiContext.getMediaQuery().matchMediaSync(CommonConstants.RANGE_MD);
    this.mdListener.on(this.listenerKey, this.isBreakpointMD);
    this.lgListener = uiContext.getMediaQuery().matchMediaSync(CommonConstants.RANGE_LG);
    this.lgListener.on(this.listenerKey, this.isBreakpointLG);
  }

  public unregister(): void {
    this.smListener?.off(this.listenerKey, this.isBreakpointSM);
    this.mdListener?.off(this.listenerKey, this.isBreakpointMD);
    this.lgListener?.off(this.listenerKey, this.isBreakpointLG);
  }
}