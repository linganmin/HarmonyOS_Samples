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
* FAQ:如何选择文件保存路径
 */

// [Start SelectFileSavePath]
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct WebComponent {
  build() {
    Row() {
      Column() {
        Image($r('app.media.startIcon'))
          .height(200)
          .width(200)
        SaveButton().onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            try {
              const context = this.getUIContext().getHostContext()!;
              let helper = photoAccessHelper.getPhotoAccessHelper(context);
              // Create image files through the Create Asset interface within 10 seconds after the nClick trigger, and revoke the Create Asset permission after 10 seconds.
              let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
              // Using URI to open files allows for continuous writing of content without time constraints during the writing process
              let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
              try {
                context.resourceManager.getMediaContent($r('app.media.startIcon').id, 0)
                  .then(async value => {
                    let media = value.buffer;
                    // Write to the media library file
                    await fileIo.write(file.fd, media);
                    await fileIo.close(file.fd);
                    this.getUIContext().showAlertDialog({ message: 'Saved to album!' });
                  });
              } catch (err) {
                console.error('error is ' + JSON.stringify(err))
              }
            } catch (error) {
              console.error('error is ' + JSON.stringify(error));
            }
          } else {
            this.getUIContext().showAlertDialog({ message: 'Failed to set permissions' })
          }
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End SelectFileSavePath]