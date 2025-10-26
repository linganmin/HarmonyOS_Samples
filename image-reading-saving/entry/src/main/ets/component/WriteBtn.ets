/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import PermissionUtils from '../utils/AuthorizationTools'
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 0x0000;

@Component
export struct WriteBtn {
  @Consume('pageInfo') pageStack: NavPathStack;
  @State saveButtonOptions: SaveButtonOptions = {
    text: SaveDescription.SAVE_TO_GALLERY,
    buttonType: ButtonType.Capsule
  };
  @State pixelMap: PixelMap | undefined = undefined;
  imageSource?: image.ImageSource;
  private context: Context = this.getUIContext().getHostContext()!;

  aboutToAppear(): void {
    try {
      this.context.resourceManager.getMediaContent($r('app.media.saveImg').id).then((data) => {
        let arrayBuffer = data.buffer.slice(data.byteOffset, data.byteLength + data.byteOffset)
        this.imageSource = image.createImageSource(arrayBuffer);
        this.imageSource.createPixelMap((_err, pixelMap) => {
          this.pixelMap = pixelMap;
        })
      })
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'WriteBtn', `WriteBtn error: ${error.code}  msg:${error.message}`);
    }
  }

  aboutToDisappear(): void {
    this.imageSource!.release();
  }

  // Save images using security components
  async savePixelMapToAlbum() {
    try {
      // Get the save path of the album
      let helper = photoAccessHelper.getPhotoAccessHelper(this.context);
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpeg');
      let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

      let imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      imagePackerApi.packToFile(this.pixelMap, file.fd, packOpts, (err: BusinessError) => {
        if (err) {
          hilog.error(TAG, 'SavePage', `Failed to pack the image to file.code ${err.code},message is ${err.message}`);
        } else {
          hilog.info(TAG, 'SavePage', `succeeded in packing the image to file.`);
          imagePackerApi.release((err: BusinessError) => {
            if (err) {
              hilog.error(TAG, 'SavePage',
                `Failed to release the image source instance.code ${err.code},message is ${err.message}`);
            } else {
              hilog.info(TAG, 'SavePage', `succeeded in releasing the image source instance.`);
              fileIo.close(file.fd);
            }
          });
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.saved_to_album') });
          this.pageStack.clear();
        }
      });
    } catch (error) {
      hilog.error(0x0000, 'WriteBtn', `WriteBtn error: ${error.code}  msg:${error.message}`);
    }
  };

  /**
   * Use pop-up authorization to save images
   * @param phAccessHelper Get an instance of the album management module
   */
  async save(phAccessHelper: photoAccessHelper.PhotoAccessHelper) {
    const sandboxPath = await PermissionUtils.getSandboxPath(this.pixelMap!, this.context);
    // Get the save path of the album
    let srcFileUri = fileUri.getUriFromPath(sandboxPath);
    // Specify the image URI located in the application sandbox to be saved to the media library
    let srcFileUris: Array<string> = [
      srcFileUri
    ];
    // Specify the creation options for the photo to be saved: file suffix, photo type, title, and photo subtype
    let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
      {
        title: sandboxPath.split('/').pop()!.split('.')[0], // optional
        fileNameExtension: 'jpeg',
        photoType: photoAccessHelper.PhotoType.IMAGE,
        subtype: photoAccessHelper.PhotoSubtype.DEFAULT, // optional
      }
    ];
    try {
      // Obtain the target URI of the media library through pop-up authorization
      let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      // Write the photo content from the application sandbox to the target URI of the media library in the future
      let desFile: fileIo.File = await fileIo.open(desFileUris[0], fileIo.OpenMode.WRITE_ONLY);
      let srcFile: fileIo.File = await fileIo.open(srcFileUri, fileIo.OpenMode.READ_ONLY);
      await fileIo.copyFile(srcFile.fd, desFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(desFile);
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.saved_to_album') });
      this.pageStack.clear();
    } catch (err) {
      hilog.error(TAG, 'SavePage', `failed with errCode is: ${err.code}, ${err.message}`);
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.reauthorization') });
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'reauthorization', `reauthorization error: ${error.code}  msg:${error.message}`);
      }
    }
  };

  // Obtain permission to save images
  async getAuthorize() {
    let context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const permission = 'ohos.permission.WRITE_IMAGEVIDEO';

    const result = await PermissionUtils.getPermission(context, permission, this.getUIContext());
    if (result) {
      this.savePixelMapToAlbum();
    }
  };

  build() {
    Column({
      space: 12
    }) {
      Image(this.pixelMap)
        .height('60%')
        .width('100%')
        .objectFit(ImageFit.Contain)

      SaveButton(this.saveButtonOptions)
        .height(40)
        .width('100%')
        .fontColor('#0A59F7')
        .backgroundColor('#f3f3f3')
        .onClick(async (_event, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            this.savePixelMapToAlbum(); // Save images using security components
          }
        });
      Button($r('app.string.use_popup_authorization_to_save'), { buttonStyle: ButtonStyleMode.NORMAL })
        .height(40)
        .width('100%')
        .fontColor('#0A59F7')
        .onClick(() => {
          this.save(photoAccessHelper.getPhotoAccessHelper(this.context));
        });
      Button($r('app.string.apply_for_media_library_permission_to_save_images'),
        { buttonStyle: ButtonStyleMode.NORMAL })
        .height(40)
        .width('100%')
        .fontColor('#0A59F7')
        .onClick(() => {
          this.getAuthorize();
        });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
  }
}