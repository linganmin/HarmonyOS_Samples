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
* FAQ:如何保存网络图片到相册
*/

// [Start SaveWebPictureToAlbum]
import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';

@Entry
@Component
struct SaveImage {
  @State pixelMap: PixelMap | undefined = undefined;

  loadImageWithUrl(url: string) {
    let responseCode = http.ResponseCode;
    let OutData: http.HttpResponse;
    let imagePackerApi = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
    // 确保网络正常
    http.createHttp().request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: 60000,
      readTimeout: 60000
    },
      async (error: BusinessError, data: http.HttpResponse) => {
        if (error) {
          console.error(`http request failed with. Code: ${error.code}, message: ${error.message}`);
        } else {
          OutData = data;
          let code: http.ResponseCode | number = OutData.responseCode;
          if (responseCode.OK === code) {
            let imageData: ArrayBuffer = OutData.result as ArrayBuffer;
            let imageSource: image.ImageSource = image.createImageSource(imageData);

            class tmp {
              height: number = 100
              width: number = 100
            };

            let options: Record<string, number | boolean | tmp> = {
              'alphaType': 0, // Transparency
              'editable': false, // Is it editable
              'pixelFormat': 3, // Pixel Format
              'scaleMode': 1, // Abbreviation
              'size': { height: 100, width: 100 }
            }; // Create Image Size
            imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
              this.pixelMap = pixelMap;
              this.pixelMap.getImageInfo().then((info: image.ImageInfo) => {
                console.info('info.width = ' + info.size.width);
              }).catch((err: BusinessError) => {
                console.error('Failed ' + err);
              })
              imagePackerApi.packToData(pixelMap, packOpts).then(async (buffer: ArrayBuffer) => {
                try {
                  const context = this.getUIContext().getHostContext()!;
                  let helper = photoAccessHelper.getPhotoAccessHelper(context);
                  let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
                  let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
                  // Write to file
                  await fs.write(file.fd, buffer);
                  this.getUIContext().getPromptAction().showToast({ message: '已保存至相册！' });
                  // Close the file
                  await fs.close(file.fd);
                } catch (error) {
                  console.error('error is ' + JSON.stringify(error));
                }
              }).catch((error: BusinessError) => {
                console.error('Failed to pack the image. And the error is: ' + error);
              }).finally(()=>{
                pixelMap.release();
              })

            })
          }
        }
      }
    )
  }

  build() {
    Row() {
      Column({ space: 10 }) {
        Image('https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-rqcjj/test.png')
          .width('80%')

        SaveButton().onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            this.loadImageWithUrl('https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-rqcjj/test.png');
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '设置权限失败！' });
          }
        })
      }
      .width('100%')
    }
    .height('100%')
    .backgroundColor(0xF1F3F5)
  }
}
// [End SaveWebPictureToAlbum]