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
* FAQ:如何获取屏幕顶部状态栏、底部导航栏和导航条的高度
*/

// [Start get_avoid_area_height]
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct GetAvoidAreaHeight {
  context = this.getUIContext();

  build() {
    Column() {
      Button('GetAvoidAreaHeight')
        .onClick(() => {
          let systemAvoidAreaType = window.AvoidAreaType.TYPE_SYSTEM; // system
          let navigationIndicatorType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // navigation
          if (this.context) {
            window.getLastWindow(this.context.getHostContext()).then((data) => {
              // Get the system default area, usually including the status bar and navigation bar
              let avoidArea1 = data.getWindowAvoidArea(systemAvoidAreaType);
              // Top status bar height
              let statusBarHeight = avoidArea1.topRect.height;
              // Bottom navigation bar height
              let bottomNavHeight = avoidArea1.bottomRect.height;
              // Get the navigation bar area
              let avoidArea2 = data.getWindowAvoidArea(navigationIndicatorType);
              // Get the height of the navigation bar area
              let indicatorHeight = avoidArea2.bottomRect.height;
              console.info(`statusBarHeight is ${statusBarHeight}`);
              console.info(`bottomNavHeight is ${bottomNavHeight}`);
              console.info(`indicatorHeight is ${indicatorHeight}`);
            }).catch((err: BusinessError) => {
              console.error(`Failed to obtain the window. Cause: ${JSON.stringify(err)}`);
            });
          }
        })
    }
  }
}

// [End get_avoid_area_height]