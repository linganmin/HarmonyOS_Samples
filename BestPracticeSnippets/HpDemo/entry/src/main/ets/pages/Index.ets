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
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State availableHeightVal1: string = '';
  @State availableHeightVal2: string = '';

  aboutToAppear(): void {
    try {
      this.availableHeightVal1 = display.getDisplayByIdSync(0).availableHeight.toString();
      this.availableHeightVal2 = display.getDisplayByIdSync(999).availableHeight.toString();
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x000, 'testTag', `get availableHeight failed. code=${error.code}, message=${error.message}`);
    }
  }

  build() {
    Column() {
      Text(this.availableHeightVal1)
      Text(this.availableHeightVal2)
      Button('remove')
        .onClick(async () => {
          try {
            // [Start moveWindow]
            let mainWindow =
              (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
            let moveConfiguration: window.MoveConfiguration = {
              displayId: 0
            };
            await mainWindow.moveWindowToGlobal(0, 0, moveConfiguration);
            // [End moveWindow]
            // [Start resizeWindow]
            let rectWidth = Number(display.getDisplayByIdSync(0).availableWidth);
            let foldCreaseRegion = display.getCurrentFoldCreaseRegion().creaseRects[0].height;
            let rectHeight = Number(display.getDisplayByIdSync(0).availableHeight) +
            Number(display.getDisplayByIdSync(999).availableHeight) + Number(foldCreaseRegion);
            mainWindow.resizeAsync(rectWidth, rectHeight)
              .then(() => {
                hilog.info(0x000, 'testTag', `resizeAsync succeed.`);
              })
              .catch((error: BusinessError) => {
                hilog.error(0x000, 'testTag', `resizeAsync falied. code=${error.code}, message=${error.message}`);
              })
            // [End resizeWindow]
          } catch (exception) {
            hilog.error(0x0000, 'test',
              `Failed to move the window. Cause code: ${exception.code}, message: ${exception.message}`);
          }
        })
    }
    .height('100%')
    .width('100%')
  }
}