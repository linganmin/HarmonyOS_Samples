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
* FAQ:在深色模式切换下如何适配状态栏颜色？
*/

// [Start dark_mode_switch_status_bar_color]
import { window } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';


@Entry
@Component
struct SysDarkMode {
  @State message: string = 'page layout';
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentColorMode: number =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;

  aboutToAppear(): void {
    this.onColorModeChange();
  }

  onColorModeChange(): void {
    // Get the current application window
    let windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;


    if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      // Currently in light color mode
      //Set the font to black
      windowClass.setWindowSystemBarProperties({
        // Status bar text color
        statusBarContentColor: '#000000'
      });
    } else if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      // Currently in dark mode
      //Set the font to white
      windowClass.setWindowSystemBarProperties({
        // Status bar text color
        statusBarContentColor: '#FFFFFF'
      });
    } else {
      console.warn("Unsupported color mode")
    }
  }

  build() {
    Column() {
      Row()
        .width('100%')
        .height(100)
        .backgroundColor($r('app.color.status_bar'))
      // page layout
      Text(this.message)
        .fontSize(50)
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          },
          middle: {
            anchor: '__container__',
            align: HorizontalAlign.Center
          }
        })
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }
}

// [End dark_mode_switch_status_bar_color]