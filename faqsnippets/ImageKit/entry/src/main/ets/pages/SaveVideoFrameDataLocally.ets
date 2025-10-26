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
import { fileIo as fs } from '@kit.CoreFileKit';

const context = AppStorage.get("context") as UIContext;

/*
* FAQ:如何把ImageReceiver收到的视频帧数据保存到本地
 */

class VideoFrame {
  imgUrl: image.PixelMap | null = null;

  saveVideoFrameDataLocally() {

    // [Start SaveVideoFrameDataLocally]
    let size: image.Size = {
      width: 640,
      height: 480
    }
    let receiver: image.ImageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
    receiver.on('imageArrival', () => {
      console.info("imageArrival callback");
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          console.error("receiveImage -error:" + err + " nextImage:" + nextImage);
          return;
        }
        nextImage.getComponent(image.ComponentType.JPEG, (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            console.error("receiveImage--getComponent -error:" + err + " imgComponent:" + imgComponent);
            return;
          }

          if (imgComponent.byteBuffer as ArrayBuffer) {
            let sourceOptions: image.SourceOptions = {
              sourceDensity: 120,
              sourcePixelFormat: 8,
              sourceSize: {
                height: 1080,
                width: 1920
              },
            }
            let imageResource = image.createImageSource(imgComponent.byteBuffer, sourceOptions);
            let imagePackerApi = image.createImagePacker();
            let packOpts: image.PackingOption = { format: "image/jpeg", quality: 90 };
            const filePath: string = context.getHostContext()!.cacheDir + "/image.jpg";
            let file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
            imagePackerApi.packToFile(imageResource, file.fd, packOpts).then(() => {
              console.error('pack success: ' + filePath);
            }).catch((error: BusinessError) => {
              console.error('Failed to pack the image. And the error is: ' + error);
            })
            imageResource.createPixelMap({}).then((res) => {
              this.imgUrl = res;
            });
          } else {
            return;
          }
          nextImage.release();
        });
      });
    });
    // [End SaveVideoFrameDataLocally]

  }

}