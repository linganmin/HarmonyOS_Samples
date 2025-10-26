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

import { window, display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
export class Breakpoint {
  // [Start source_add2]
  // Update horizontal breakpoints according to window width
  updateWidthBreakpoint(): void {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    let promise = window.getLastWindow(uiContext?.getHostContext());
    promise.then((mainWindow: window.Window) => {
      let windowRect: window.Rect = mainWindow.getWindowProperties().windowRect;
      let windowWidthVp: number = windowRect.width / display.getDefaultDisplaySync().densityPixels;
      let widthBp: string = '';
      if (windowWidthVp < 320) {
        widthBp = 'xs';
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = 'sm';
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = 'md';
      } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
        widthBp = 'lg';
      } else {
        widthBp = 'xl';
      }
      AppStorage.setOrCreate('widthBreakpoint', widthBp);
    }).catch((err: BusinessError) => {
      console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
    });
  }
  // Update the vertical breakpoint according to the window width-height ratio
  updateHeightBreakpoint(): void {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    let promise = window.getLastWindow(uiContext?.getHostContext());
    promise.then((mainWindow: window.Window) => {
      let windowRect: window.Rect = mainWindow.getWindowProperties().windowRect;
      let windowWidthVp: number = windowRect.width / display.getDefaultDisplaySync().densityPixels;
      let windowHeightVp: number = windowRect.height / display.getDefaultDisplaySync().densityPixels;
      let heightBp: string = '';
      let aspectRatio: number = windowHeightVp / windowWidthVp;
      if (aspectRatio < 0.8) {
        heightBp = 'sm';
      } else if (aspectRatio >= 0.8 && aspectRatio < 1.2) {
        heightBp = 'md';
      } else {
        heightBp = 'lg';
      }
      AppStorage.setOrCreate('heightBreakpoint', heightBp);
    }).catch((err: BusinessError) => {
      console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
    });
  }
  // [End source_add2]
}