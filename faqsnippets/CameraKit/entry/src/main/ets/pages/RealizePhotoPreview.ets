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
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, WriteOptions } from '@kit.CoreFileKit';
import { camera } from '@kit.CameraKit';

/*
* FAQ:如何实现拍照预览onPreviewFrame回调
*/
let previewProfilesArray = [];
let surfaceId = '';
const context = AppStorage.get("context") as Context;

class RealizePhotoPreview {
  cameraManager = camera.getCameraManager(context)
  private previewOutput: camera.PreviewOutput | null = null;
  private previewOutput2: camera.PreviewOutput | null = null;
  count: number = 0;

  async cameraFun() {
    // [Start RealizePhotoPreview]
    this.previewOutput = this.cameraManager!.createPreviewOutput(previewProfilesArray[5], surfaceId);
    let size: image.Size = {
      width: 640,
      height: 480
    }
    let receiver: image.ImageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
    receiver.on('imageArrival', () => {
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          console.error('readNextImage failed');
          return;
        }
        nextImage.getComponent(image.ComponentType.JPEG, (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            console.error('getComponent failed');
          }
          if (imgComponent && imgComponent.byteBuffer as ArrayBuffer && this.count<3) {
            this.count = this.count + 1
            let path: string = context.filesDir + "/image.yuv";
            let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            let opt: WriteOptions = {
              // 2048 extra bytes of data
              length: imgComponent.byteBuffer.byteLength - 2048
            }
            fileIo.write(file.fd, imgComponent.byteBuffer, opt).then((writeLen) => {
              console.info("write data to file succeed and size is:" + writeLen);
              fileIo.closeSync(file);
            }).catch((err: BusinessError) => {
              console.info("write data to file failed with error message: " + err.message + ", error code: " + err.code);
            });
          }
          nextImage.release();
        })
      })
    })
    let ImageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
    this.previewOutput2 = this.cameraManager!.createPreviewOutput(previewProfilesArray[5], ImageReceiverSurfaceId);
    // [End RealizePhotoPreview]
  }
}