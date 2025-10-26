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
* FAQ:如何获取底部手势横条的高度
*/

// [Start get_bottom_nav_bar_height]

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct GetBottomNavBarHeight {
  context = this.getUIContext();

  build() {
    Column() {
      Button('Get the height of the bottom gesture bar')
        .onClick(() => {
          let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
          window.getLastWindow(this.context.getHostContext()).then((data) => {
            let avoidArea = data.getWindowAvoidArea(type);
            // Get the height of the navigation bar area
            let bottomRectHeight = avoidArea.bottomRect.height;
            console.info(`window bottomRectHeight is: ${bottomRectHeight}`);
          }).catch((err: BusinessError) => {
            console.error(`Failed to obtain the window. Cause: ${JSON.stringify(err)}`);
          });
        })
    }
  }
}
// [End get_bottom_nav_bar_height]