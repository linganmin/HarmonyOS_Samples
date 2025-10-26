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
* FAQ:如何将相册选择的图片生成PixelMap
*/

// [Start SelectedAlbumPictureGeneratePixelMap_Two]
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct WebComponent {
  build() {
    Column() {
      Button('Select Picture').onClick(() => {
        try {
          let uris: Array<string> = [];
          let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
          PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
          PhotoSelectOptions.maxSelectNumber = 1;
          let photoPicker = new photoAccessHelper.PhotoViewPicker();
          photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
            uris = PhotoSelectResult.photoUris;
            let file = fileIo.openSync(uris[0], fileIo.OpenMode.READ_ONLY);
            console.info('file fd: ' + file.fd);
            let buffer = new ArrayBuffer(4096);
            let readLen = fileIo.readSync(file.fd, buffer);
            console.info('readSync data to file succeed and buffer size is:' + readLen);
            const imageSource: image.ImageSource = image.createImageSource(file.fd);
            let decodingOptions: image.DecodingOptions = {
              editable: true,
              desiredPixelFormat: 3,
            }
            imageSource.createPixelMap(decodingOptions, (err: BusinessError, pixelMap: image.PixelMap) => {
              if (err !== undefined) {
                console.error(`Failed to create pixelMap.code is ${err.code},message is ${err.message}`);
              } else {
                console.info('Succeeded in creating pixelMap object.');
              }
            })
          }).catch((err: BusinessError) => {
            console.error(`Invoke photoPicker.select failed, code is ${err.code}, message is ${err.message}`);
          })
        } catch (error) {
          let err: BusinessError = error as BusinessError;
          console.error('photoPicker failed with err: ' + JSON.stringify(err));
        }
      })
    }
  }
}
// [End SelectedAlbumPictureGeneratePixelMap_Two]