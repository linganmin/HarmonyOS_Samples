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
* FAQ:如何实现状态栏背景颜色沉浸？
*/

// [Start immersing_background_color_of_status_bar_two]
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CommonTopBar {
  @State message: string = 'Hello World';

  aboutToAppear() {
    // Get the current application window
    let windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
    try {
      // Set the background color of the status bar and navigation bar to the same color as the application window
      windowClass.setWindowSystemBarProperties({
        // The color attribute is ARGB, set the dust cover to 0% to make it transparent
        // Navigation bar color
        navigationBarColor: '#fd121de5',
        // Status bar color
        statusBarColor: '#ff0ad9c2',
        // Status bar text color
        statusBarContentColor: '#fff1e50a'
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CommonTopBar', `error code:${err.code},message:${err.message}`);
    }
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('PageHelloWorld')
        .fontSize(50)
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
    }
    .height('100%')
    .width('100%')
  }
}

// [End immersing_background_color_of_status_bar_two]