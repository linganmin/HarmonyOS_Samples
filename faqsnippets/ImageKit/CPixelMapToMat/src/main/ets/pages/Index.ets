/*
 *
 *  * Copyright (c) 2024 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */
/**
 * FAQ: 如何将C++侧接收的PixelMap转换成cv::mat格式
 */
// [Start ConvertPixelMapToCvMatFormat]
import cPixelMapToMat from 'libcpixelmaptomat.so';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

@Entry
@Component
struct Index {
  @State pixelMap: image.PixelMap | undefined = undefined

  async arrayBufferToMat() {
    if (this.pixelMap == undefined || this.pixelMap){
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let resourceManager = context.resourceManager
      let imageArray = await resourceManager.getMediaContent($r('app.media.sample10'));
      let pixelBuffer = new Uint8Array(imageArray).buffer as Object as ArrayBuffer
      console.info("pixelBuffer length: " + pixelBuffer.byteLength);
      let imageResource = image.createImageSource(pixelBuffer);
      let opts: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      }
      this.pixelMap = await imageResource.createPixelMap(opts);
    }

    const readBuffer: ArrayBuffer = new ArrayBuffer(this.pixelMap.getPixelBytesNumber()); // Obtain the array buffer of the pixelmap
    console.info("readBuffer length: " + readBuffer.byteLength);
    this.pixelMap.readPixelsToBuffer(readBuffer).then(() => {
      console.info("No Error!")
    }).catch((err: BusinessError) => {
      console.error("Error! " + err.message)
    })
    const dir = getContext(this).filesDir;
    console.info('save path: ' + dir);
    cPixelMapToMat.arrayBufferToMat(this.pixelMap, readBuffer, dir);
  }

  async accessToMat(){
    if (this.pixelMap == undefined || this.pixelMap) {
      let resourceManager = getContext(this).resourceManager
      let imageArray = await resourceManager.getMediaContent($r('app.media.sample14'));
      let pixelBuffer = new Uint8Array(imageArray).buffer as Object as ArrayBuffer
      console.info("pixelBuffer length: " + pixelBuffer.byteLength);
      let imageResource = image.createImageSource(pixelBuffer);
      let opts: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      }
      this.pixelMap = await imageResource.createPixelMap(opts);
    }

    const dir = getContext(this).filesDir;
    console.info('save path: ' + dir);
    cPixelMapToMat.accessToMat(this.pixelMap, dir);
  }

  build() {
    Row() {
      Column() {
        Image(this.pixelMap)
          .width(200)
          .height(200)
        Button('ArrayBufferToMat')
          .onClick(() => {
            this.arrayBufferToMat();
          })

        Button('AccessToMat')
          .onClick(() => {
            this.accessToMat();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End ConvertPixelMapToCvMatFormat]