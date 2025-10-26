/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[EncodeUtil]';
const context = AppStorage.get('uiContext') as UIContext;
let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context.getHostContext() as Context);

/**
 * Pack the image.
 *
 * @param pixelMap.
 */
export async function encode(component: Object, pixelMap: PixelMap) {
  hilog.info(0x0000, TAG, '%{public}s', `component is ${component}`);
  const newPixelMap = pixelMap;
  // Packing image.
  const imagePackerApi = image.createImagePacker();
  const packOptions: image.PackingOption = {
    format: 'image/jpeg',
    quality: 100
  }
  try {
    const imageData = await imagePackerApi.packToData(newPixelMap, packOptions);
    hilog.info(0x0000, TAG, '%{public}s', `imageData's length is ${imageData.byteLength}`);
    // Create image asset.
    let photoType: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
    let extension: string = 'jpg';
    phAccessHelper.createAsset(photoType, extension, (err, uri) => {
      if (err) {
        hilog.error(0x0000, TAG, 'createAsset ', JSON.stringify(err) ?? '');
      }
      if (uri !== undefined) {
        let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
        fileIo.writeSync(file.fd, imageData);
        fileIo.close(file.fd).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, 'Failed to close: ', JSON.stringify(err) ?? '');
        });
        context.getPromptAction().showToast({ message: $r('app.string.image_save') });
      }
    });
  } catch (err) {
    hilog.error(0x0000, TAG, 'Failed to packToData: ', JSON.stringify(err) ?? '');
  }
}