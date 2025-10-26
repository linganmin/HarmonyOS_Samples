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

// [Start drag_sample]
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';

const COLUMN_WIDTH: number = 108;
const COLUMN_TOP: number = 50;
const COLUMN_LEFT: number = 100;

@Entry
@Component
struct Index {
  // get the window manager from AppStorage
  windowStage: window.WindowStage = AppStorage.get('window') as window.WindowStage;

  build() {
    Column() {
      Blank('60')
        .color(Color.Blue)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            try {
              let wnd: window.Window = this.windowStage.getMainWindowSync();
              if (canIUse('SystemCapability.Window.SessionManager')) {
                wnd.startMoving().then(() => {
                  console.info('wnd Succeeded in starting moving window');
                }).catch((err: BusinessError) => {
                  console.error(`Failed to start moving. Cause code: ${err.code}, message: ${err.message}`);
                });
              }
            } catch (exception) {
              console.error(`Failed to start moving. Cause code: ${exception.code}, message: ${exception.message}`);
            }
          }
        })
    }.width(COLUMN_WIDTH).position({ top: COLUMN_TOP, left: COLUMN_LEFT }).alignItems(HorizontalAlign.Center);
  }
}
// [End drag_sample]