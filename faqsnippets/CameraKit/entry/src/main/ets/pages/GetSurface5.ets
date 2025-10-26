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

// [Start GetSurface5]
import { BusinessError } from '@kit.BasicServicesKit';
import image from '@ohos.multimedia.image';

function onImageArrival(receiver: image.ImageReceiver): void {
  receiver.on('imageArrival', () => {
    receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
      if (err || nextImage === undefined) {
        return;
      }
      // The current ImageReceiver does not support obtaining YUV data. You can use the JPEG data channel to receive YUV data, but using this method carries risks
      nextImage.getComponent(image.ComponentType.JPEG, (err: BusinessError, imgComponent: image.Component) => {
        if (err || imgComponent === undefined) {
          return;
        }
        if (imgComponent.byteBuffer as ArrayBuffer) {
          // Handle according to business demands
        } else {
          return;
        }
      })
    })
  })
}
// [End GetSurface5]