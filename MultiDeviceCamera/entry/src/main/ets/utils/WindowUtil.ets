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

import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class WindowUtil {
  windowStage?: window.WindowStage;
  mainWindow?: window.Window;

  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      this.mainWindow = windowClass;
      if (err.code) {
        hilog.error(0x0000, 'testTag', `Failed to obtain the main window. Code:${err.code}, message:${err.message}`,
          JSON.stringify(err) ?? '');
        return;
      }
    });
  }

  setMainWindowOrientation(orientation: window.Orientation): void {
    // Setting orientation.
    this.mainWindow!.setPreferredOrientation(orientation)
      .then(() => {
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in setting the orientation.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to set the orientation. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  offWindowSizeChange(): void {
    this.mainWindow!.off('windowSizeChange');
  }

  getFoldCreaseRegion(context: UIContext): void {
    try {
      if (display.isFoldable()) {
        let foldRegion: display.FoldCreaseRegion = display.getCurrentFoldCreaseRegion();
        let rect: display.Rect = foldRegion.creaseRects[0];
        // Height of the avoidance area in the upper half screen and height of the avoidance area.
        let creaseRegion: number[] = [context.px2vp(rect.top), context.px2vp(rect.height), context.px2vp(rect.width)];
        AppStorage.setOrCreate('creaseRegion', creaseRegion);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Isfoldable failed. Code: ${err.code}, message: ${err.message}`);
    }
  }

  getWindowSize(): window.Size {
    let result: window.Size = {
      width: 0,
      height: 0
    };
    try {
      let rect: window.Rect = this.mainWindow!.getWindowProperties().windowRect;
      result.width = rect.width;
      result.height = rect.height;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Get window properties failed. Code: ${err.code}, message: ${err.message}`);
    }
    return result;
  }
}