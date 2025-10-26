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
* FAQ:如何修改状态栏字体颜色
*/

// [Start change_the_font_color_of_the_status_bar_two]
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
struct ChangeStatusBar {
  windowStage: window.WindowStage = AppStorage.get("windowStage") as window.WindowStage;
  // How to get the main window
  mainWin: window.Window = this.windowStage.getMainWindowSync();

  aboutToAppear(): void {
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: '#000000',
      statusBarContentColor: '#ffffff'
    };
    this.mainWin.setWindowSystemBarProperties(sysBarProps).then(() => {
      console.info('[StaticUtils] Succeeded in setting the system bar properties.');
    }).catch((err: BusinessError) => {
      console.error(`setting system bar properties failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  build() {
    Row() {
      Column({ space: 10 }) {
        Text('Demo of modifying the status bar')
          .fontSize(25)
          .margin(20)
          .fontColor(0x3399FF)
      }.width('100%')
    }.height('100%').backgroundColor(Color.White)
  }
}
// [End change_the_font_color_of_the_status_bar_two]