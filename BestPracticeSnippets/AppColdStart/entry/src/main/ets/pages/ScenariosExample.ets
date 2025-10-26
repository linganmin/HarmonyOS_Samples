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

// [Start scenarios_example]
// Index.ets
import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { fileIo, fileIo as fs } from '@kit.CoreFileKit';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.READ_MEDIA',
  'ohos.permission.WRITE_MEDIA'
];
AppStorage.link('net_picture');
PersistentStorage.persistProp('net_picture', '');

@Entry
@Component
struct Index {
  @State image: PixelMap | undefined = undefined;
  @State imageBuffer: ArrayBuffer | undefined = undefined; // Picture ArrayBuffer

  /**
   * Download picture resources from the Internet through the http request method
   */
  async getPicture(): Promise<void> {
    http.createHttp()
      .request('https://www.example1.com/POST?e=f&g=h',
        (error: BusinessError, data: http.HttpResponse) => {
          if (error) {
            return;
          }
          // Determine whether the resources obtained by the network are of the ArrayBuffer type.
          if (data.result instanceof ArrayBuffer) {
            this.imageBuffer = data.result as ArrayBuffer;
          }
          this.transcodePixelMap(data);
        }
      )
  }

  /**
   * Use createPixelMap to replace pictures of ArrayBuffer type with PixelMap type
   * @param data：Resources obtained from the network
   */
  transcodePixelMap(data: http.HttpResponse): void {
    if (http.ResponseCode.OK === data.responseCode) {
      const imageData: ArrayBuffer = data.result as ArrayBuffer;
      // Create a picture source instance through ArrayBuffer
      const imageSource: image.ImageSource = image.createImageSource(imageData);
      const options: image.InitializationOptions = {
        'alphaType': 0, // Transparency
        'editable': false, // Is it editable?
        'pixelFormat': 3, // Pixel format
        'scaleMode': 1, // Abbreviation
        'size': { height: 100, width: 100 }
      }; // Create the size of the picture

      // Create PixelMap through attributes
      imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
        this.image = pixelMap;
        setTimeout(() => {
          if (this.imageBuffer !== undefined) {
            this.saveImage(this.imageBuffer);
          }
        }, 0)
      });
    }
  }

  async saveImage(buffer: ArrayBuffer | string): Promise<void> {
    try {
      const context:common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const filePath: string = context.cacheDir + '/test.jpg';
      AppStorage.set('net_picture', filePath);
      const file: fileIo.File = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, buffer);
      await fs.close(file.fd);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`onAddForm err, code: ${error.code}, mesage: ${error.message}`);
    }
  }


  async useCachePic(): Promise<void> {
    if (AppStorage.get('net_picture') !== '') {
      // Get the ArrayBuffer of the picture
      const imageSource: image.ImageSource = image.createImageSource(AppStorage.get('net_picture'));
      const options: image.InitializationOptions = {
        'alphaType': 0, // transparency
        'editable': false, // Is it editable?
        'pixelFormat': 3, // pixel format
        'scaleMode': 1, // Abbreviated value
        'size': { height: 100, width: 100 }
      };
      imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
        this.image = pixelMap;
      });
    }
  }

  async aboutToAppear(): Promise<void> {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    await atManager.requestPermissionsFromUser(context, PERMISSIONS);
    this.useCachePic(); // Get data from local storage
    this.getPicture(); // Obtain data from the network side
  }


  build() {
    Column() {
      Image(this.image)
        .objectFit(ImageFit.Contain)
        .width('50%')
        .height('50%')
    }
  }
}
// [End scenarios_example]