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
* FAQ:如何获取设备屏幕横竖屏状态
*/

// [Start get_window_rotation]
import { display, window } from '@kit.ArkUI';

@Entry
@Component
struct WindowRotation {
  build() {
    Text("Scroll Area")
      .width("100%")
      .height("100%")
      .backgroundColor(0X330000FF)
      .fontSize(16)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        window.getLastWindow(this.getUIContext().getHostContext(), (err, win) => {
          let cutOutInfo = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE)
          console.log(JSON.stringify(cutOutInfo))
          if (window.Orientation.AUTO_ROTATION) {
            let rotation: number = display.getDefaultDisplaySync().orientation // Get current screen orientation enum value
            console.log('' + rotation);
            if (rotation == 0) {
              console.log("CutOutInfo Portrait data: " + JSON.stringify(cutOutInfo));
            } else if (rotation == 1) {
              console.log("CutOutInfo Landscape data: " + JSON.stringify(cutOutInfo));
            } else if (rotation == 2) {
              console.log("CutOutInfo Reverse portrait data: " + JSON.stringify(cutOutInfo));
            } else {
              console.log("CutOutInfo Reverse landscape data: " + JSON.stringify(cutOutInfo));
            }
          }
        })
      })
  }
}
// [End get_window_rotation]