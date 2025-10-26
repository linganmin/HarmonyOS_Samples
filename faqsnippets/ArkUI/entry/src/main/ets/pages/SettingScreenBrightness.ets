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
* FAQ:如何设置屏幕亮度
*/

// [Start set_screen_brightness]
import { window } from '@kit.ArkUI'

@Component
struct SettingScreenBrightness {
  context = this.getUIContext();

  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  // Method to get the main window
  mainWin: window.Window = this.windowStage.getMainWindowSync();

  aboutToAppear(): void {
    // Change screen brightness by modifying brightness
    let brightness = 1;
    this.windowStage = AppStorage.get('windowStage') as window.WindowStage;
    // Method to get the main window
    this.mainWin = this.windowStage.getMainWindowSync();
    // Method to get the top window
    window.getLastWindow(this.context.getHostContext());
    try {
      this.mainWin.setWindowBrightness(brightness, (err) => {
        if (err.code) {
          console.error('Failed to set the brightness. Cause: ' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in setting the brightness.');
      });
    } catch (exception) {
      console.error('Failed to set the brightness. Cause: ' + JSON.stringify(exception));
    }
  }

  build() {
    Row() {
      Column({ space: 10 }) {
        Text('Screen brightness setting demo')
          .fontSize(25)
          .margin(20)
          .fontColor(0x3399FF)
      }.width('100%')
    }.height('100%').backgroundColor(Color.White)
  }
}
// [End set_screen_brightness]