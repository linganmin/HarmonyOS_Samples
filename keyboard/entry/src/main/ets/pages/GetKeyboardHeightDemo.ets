/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

// [Start GetKeyboard_height_demo]
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct GetKeyboardHeightDemo {
  @State keyboardHeight: number = 0; // Soft keyboard height

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        currentWindow.on('keyboardHeightChange', (data: number) => {
          this.keyboardHeight = this.getUIContext().px2vp(data);
        })
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'GetKeyboardHeightDemo',
        `getLastWindow failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Column() {
      // [StartExclude GetKeyboard_height_demo]
      Text("Hello Word")
        .fontSize($r('app.float.font_size_24'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      // [EndExclude GetKeyboard_height_demo]
      TextInput()

      if (this.keyboardHeight > 0) {
        Row() { // Emoji
          // [StartExclude GetKeyboard_height_demo]
          Image($r('app.media.folder'))
            .width($r('app.float.image_height_24'))
            .height($r('app.float.image_height_24'))
          // [EndExclude GetKeyboard_height_demo]
        }

        // [StartExclude GetKeyboard_height_demo]
        Text("keyboard")
          .fontSize($r('app.float.font_size_24'))
          .fontWeight(FontWeight.Medium)
        // [EndExclude GetKeyboard_height_demo]
      }
    }
  }
}

// [End GetKeyboard_height_demo]