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
* FAQ:如何将app.media.app_icon，转换为PixelMap
*/

// [Start ConvertAppIconToPixelMap]
import { image } from '@kit.ImageKit';

@Entry
@Component
struct Index {
  @State text: string = '';

  convert() {
    try {
      // Byte array of media files
      this.getUIContext().getHostContext()!.resourceManager.getMediaContent($r('app.media.startIcon').id, (error, value: ArrayBuffer) => {
        let pixelMapInitOptions: image.InitializationOptions = {
          editable: true,
          pixelFormat: 3,
          size: { height: 4, width: 6 }
        };
        let uint8Array: Uint8Array = new Uint8Array(value);
        let buffer: ArrayBuffer = uint8Array.buffer.slice(0);

        // Create PixelMap
        image.createPixelMap(buffer, pixelMapInitOptions).then((pixelMap) => {
          // ...
          this.text = JSON.stringify(pixelMap);
        })
      });
    } catch (error) {
      console.error(`callback getMediaContent failed, error code: ${error.code}, message: ${error.message}.`)
    }
  }

  build() {
    Column() {
      Button('Click to convert')
        .onClick(() => {
          this.convert();
        })
        .margin({ bottom: 16 })
      TextArea({ text: this.text })
    }
    .padding(16)
  }
}
// [End ConvertAppIconToPixelMap]