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
* FAQ:如何获取窗口的宽度
*/

// [Start get_window_width]
import { window } from '@kit.ArkUI';

@Entry
@Component
struct WindowProperties {
  context = this.getUIContext();

  build() {
    Text("Scroll Area")
      .width("100%")
      .height("100%")
      .backgroundColor(0X330000FF)
      .fontSize(16)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        window.getLastWindow(this.context.getHostContext()).then((data) => {
          // get window attribute
          let properties = data?.getWindowProperties();
          // Get window width and height
          console.log("windowClass width: " + properties.windowRect.width);
          console.log("windowClass height: " + properties.windowRect.height);
        });
      })
  }
}
// [End get_window_width]