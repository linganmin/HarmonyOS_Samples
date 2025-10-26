/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import Logger from './LoggerUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

const TAG: string = 'imageEdit_Encode';

/**
 * Pack the image.
 *
 * @param pixelMap.
 */
export async function encode(pixelMap: PixelMap, uiContext: UIContext) {
  const context = uiContext.getHostContext() as common.UIAbilityContext;

  let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

  const newPixelMap = pixelMap;
  // Packing image.
  const imagePackerApi = image.createImagePacker();
  const packOptions: image.PackingOption = {
    format: CommonConstants.ENCODE_FORMAT,
    quality: CommonConstants.ENCODE_QUALITY
  }
  try {
    const imageData = await imagePackerApi.packToData(newPixelMap, packOptions);
    Logger.info(TAG, `imageData's length is ${imageData.byteLength}`);
    // Create image asset.
    let photoType: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
    let extension: string = 'jpg';
    phAccessHelper.createAsset(photoType, extension, (err, uri) => {
      if (err) {
        console.error('Failed to get encode info:', err);
        return;
      }
      if (uri != undefined) {
        let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
        fileIo.writeSync(file.fd, imageData);
        fileIo.close(file.fd);
      }
    });
  } catch (err) {
    let error = err as BusinessError;
    hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
  }
}