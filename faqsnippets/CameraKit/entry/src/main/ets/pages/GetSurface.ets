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
* FAQ:如何读取相机的预览图
*/

// [Start GetSurface]
import { image } from '@kit.ImageKit';
// [End GetSurface]

// [Start GetSurface2]
async function getImageReceiverSurfaceId(): Promise<string | undefined> {
  let receiver: image.ImageReceiver = image.createImageReceiver({ width: 640,height: 480 },4,8);
  console.info('before ImageReceiver check');
  let ImageReceiverSurfaceId: string | undefined = undefined;
  if (receiver !== undefined) {
    console.info('ImageReceiver is ok');
    let ImageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
    console.info(`ImageReceived id: ${ImageReceiverSurfaceId}`);
  } else {
    console.error('ImageReceiver is not ok');
  }
  return ImageReceiverSurfaceId;
}

// [End GetSurface2]

// [Start GetSurface3]
//xxx.ets
// 创建XComponentController
@Entry
@Component
struct XComponentPage {
  // 创建XComponentController
  mXComponentController: XComponentController = new XComponentController;

  build() {
    Flex() {
      // Create XComponent
      XComponent({
        id: '',
        type: 'surface',
        libraryname: '',
        controller: this.mXComponentController
      })
        .onLoad(() => {
          // Set the width and height of the Surface (1920 * 1080), and set the preview size based on the preview resolution size supported
          // by the current device obtained from previewProfilesArray earlier
          this.mXComponentController.setXComponentSurfaceRect({surfaceWidth:1920,surfaceHeight:1080});
          // Get Surface ID
          let surfaceId: string = this.mXComponentController.getXComponentSurfaceId();
        })
        .width('1920px')
        .height('1080px')
    }
  }
}
// [End GetSurface3]