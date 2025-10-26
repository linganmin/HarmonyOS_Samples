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

// [Start rotate_sample]
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const SUB_WINDOW_LEFT_OFFSET: number = 50;
const SUB_WINDOW_TOP_OFFSET: number = 500;
const TAG: string = 'subWindowAdaptWhenRotate';
const DOMAIN: number = 0x0000;

@Entry
@Component
struct Index {
  public mainWindow: window.Window | undefined = undefined;
  public subWindow: window.Window | undefined = undefined;

  aboutToAppear(): void {
    // create subWindow
    this.createSubWindow();

    this.mainWindow = AppStorage.get('mainWindow');
    if (!this.mainWindow) {
      return;
    }
    this.mainWindow.on('windowSizeChange', () => {
      this.adjustSubwindowSizeAndPosition();
    })
  }

  private adjustSubwindowSizeAndPosition(): void {
    if (!this.subWindow) {
      hilog.error(DOMAIN, TAG, 'subWindow is null');
      return;
    }
    let subwindowRect: window.Rect | null = null;
    try {
      subwindowRect = this.subWindow.getWindowProperties().windowRect;
    } catch (error) {
      hilog.warn(0x000, 'testTag', `getWindowProperties failed, code: ${error.code}, message: ${error.message}`);
    }
    let newWidth: number = subwindowRect!.height;
    let newHeight: number = subwindowRect!.width;
    let newX: number = subwindowRect!.top;
    let newY: number = subwindowRect!.left;
    this.subWindow.resize(newWidth, newHeight)
      .then(() => {
        hilog.info(DOMAIN, TAG, 'Succeeded in changing the window size')
      }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to change the window size. Cause code: ${err.code}, message: ${err.message}`);
    });

    this.subWindow.moveWindowTo(newX, newY)
      .then(() => {
        hilog.info(DOMAIN, TAG, 'Succeeded in moving the window');
      }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to move the window. Cause code: ${err.code}, message: ${err.message}`);
    });

  }

  // [StartExclude rotate_sample]
  private createSubWindow(): void {
    window.createWindow({
      name: 'subWindow',
      windowType: window.WindowType.TYPE_DIALOG,
      ctx: this.getUIContext().getHostContext(),
    }).then((subWindow: window.Window) => {
      this.subWindow = subWindow;

      if (!this.mainWindow) {
        return;
      }
      let mainWindowRect: window.Rect | null = null;
      try {
        mainWindowRect = this.mainWindow.getWindowProperties().windowRect;
      } catch (error) {
        hilog.warn(0x000, 'testTag', `getWindowProperties failed, code: ${error.code}, message: ${error.message}`);
      }

      let mainWindowWidth: number = mainWindowRect!.width;
      let mainWindowHeight: number = mainWindowRect!.height;
      this.subWindow.resize(mainWindowWidth - SUB_WINDOW_LEFT_OFFSET, mainWindowHeight - SUB_WINDOW_TOP_OFFSET)
        .catch((err: BusinessError) => {
          hilog.error(0x000, 'testTag', `resize failed, code=${err.code}, message=${err.message}`);
        })
      this.subWindow.moveWindowTo(SUB_WINDOW_LEFT_OFFSET / 2, SUB_WINDOW_TOP_OFFSET / 2)
        .catch((err: BusinessError) => {
          hilog.error(0x000, 'testTag', `moveWindowTo failed, code=${err.code}, message=${err.message}`);
        })
      this.subWindow.setUIContent('pages/Subwindow').then(() => {
        try {
          this.subWindow?.setWindowBackgroundColor('#ff0000');
        } catch (error) {
          hilog.warn(0x000, 'testTag',
            `setWindowBackgroundColor failed, code: ${error.code}, message: ${error.message}`);
        }
        this.subWindow?.showWindow().then(() => {
          hilog.info(DOMAIN, TAG, 'Show subwindow success');
        }).catch((error: BusinessError) => {
          hilog.error(DOMAIN, TAG, `Failed to show subwindow, error: ${error}`);
        });
      }).catch((error: BusinessError) => {
        hilog.error(DOMAIN, TAG, `Failed to setUIContent, error: ${error}`);
      });
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, `Failed to create subwindow, error: ${error}`);
    });
  }

  build() {
    Column() {
    }
    .height('100%')
    .width('100%')
  }

  // [EndExclude rotate_sample]
}

// [End rotate_sample]