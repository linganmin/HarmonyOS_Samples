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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GetValueOnBreakpoint';
const FORMAT = '%{public}s';

export class Breakpoints {
  xs: number = 0;
  sm: number = 0;
  md: number = 0;
  lg: number = 0;
}

// Global breakpoint interface
export default function getValueOnBreakpoint(breakpointsLabels: string[], breakpoints: Breakpoints): string {
  if (breakpointsLabels.length < 4) {
    return '';
  }
  let windowObj: window.Window | undefined = AppStorage.get('windowObj');
  if (windowObj == undefined) {
    return '';
  }
  let newBreakpoint: string = '';
  try {
    let uiContext = AppStorage.get('uiContext') as UIContext;
    let windowWidthVp = uiContext.px2vp(windowObj.getWindowProperties().windowRect.width);
    if (windowWidthVp < breakpoints.sm) {
      newBreakpoint = breakpointsLabels[0];
    } else if (windowWidthVp < breakpoints.md) {
      newBreakpoint = breakpointsLabels[1];
    } else if (windowWidthVp < breakpoints.lg) {
      newBreakpoint = breakpointsLabels[2];
    } else {
      newBreakpoint = breakpointsLabels[3];
    }
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,
      `Failed to obtain the window properties. Cause code: ${err.code}, message: ${err.message}`);
  }
  return newBreakpoint;
}