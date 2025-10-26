/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { textRecognition } from '@kit.CoreVisionKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { Logger } from './Logger';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class OCRManager {
  static async recognizeByCamera(ctx: Context, loadingController: CustomDialogController): Promise<string> {
    // The configuration information of cameraPicker
    let pickProfile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED
    };
    try {
      let result: cameraPicker.PickerResult =
        await cameraPicker.pick(ctx, [cameraPicker.PickerMediaType.PHOTO], pickProfile);
      if (!result || !result.resultUri) {
        Logger.error('cameraPicker', 'camera picker result is empty');
        return '';
      }
      loadingController.open();
      return OCRManager.recognizeText(result.resultUri);
    } catch (error) {
      loadingController.close();
      Logger.error('OCRManager', `recognizeByCamera failed, code is ${error.code}, message is ${error.message}`);
      return '';
    }
  }

  static async recognizeByAlbum(loadingController: CustomDialogController): Promise<string> {
    try {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      let photoResult: photoAccessHelper.PhotoSelectResult =
        await photoPicker.select({
          MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
          maxSelectNumber: 1,
          isPhotoTakingSupported: false
        });
      if (!photoResult || photoResult.photoUris.length === 0) {
        Logger.error('photoViewPicker', 'photo view picker result is empty');
        return '';
      }
      loadingController.open();
      return OCRManager.recognizeText(photoResult.photoUris[0]);
    } catch (error) {
      loadingController.close();
      Logger.error('OCRManager', `recognizeByAlbum failed, code is ${error.code}, message is ${error.message}`);
      return '';
    }
  }

  static async recognizeText(uri: string): Promise<string> {
    // Visual information to be recognized.
    // Currently, only the visual information of the PixelMap type in color data format RGBA_8888 is supported.
    let pixelMap = await OCRManager.getPixelMap(uri)
    if (!pixelMap) {
      return ''
    }
    try {
      let visionInfo: textRecognition.VisionInfo = { pixelMap: pixelMap };
      let result: textRecognition.TextRecognitionResult = await textRecognition.recognizeText(visionInfo);
      visionInfo.pixelMap.release();
      return result.value;
    } catch (error) {
      let err = error as BusinessError
      Logger.error('OCRManager', `getPixelMap failed, code is ${err.code}, message is ${err.message}`);
      return ''
    }
  }

  static async getPixelMap(uri: string): Promise<image.PixelMap | null> {
    // Convert image resources to PixelMap
    try {
      let fileSource = await fs.open(uri, fs.OpenMode.READ_ONLY);
      let imgSource: image.ImageSource = image.createImageSource(fileSource.fd);
      let pixelMap: image.PixelMap = await imgSource.createPixelMap();
      fs.close(fileSource)
      imgSource.release();
      return pixelMap;
    } catch (error) {
      let err = error as BusinessError
      Logger.error('OCRManager', `getPixelMap failed, code is ${err.code}, message is ${err.message}`);
      return null;
    }
  }
}