/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何设置窗口旋转
*/

// [Start screen_rotation]
import { display, window } from '@kit.ArkUI';

@Component
struct ScreenRotation {
  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  // Method to get the main window
  mainWin: window.Window = this.windowStage.getMainWindowSync();
  context = this.getUIContext();

  onPageShow() {
    // Method to get the top window
    window.getLastWindow(this.context.getHostContext());
    this.mainWin.setPreferredOrientation(window.Orientation.LANDSCAPE);
    // Use display interface to get current rotation direction, can be placed in listener for continuous updates
    display.getDefaultDisplaySync().rotation;
  }

  build() {
    Row() {
      Column({ space: 10 }) {
        Text('Screen rotation demo')
          .fontSize(25)
          .margin(20)
          .fontColor(0x3399FF)
      }.width('100%')
    }.height('100%').backgroundColor(Color.White)
  }
}
// [End screen_rotation]