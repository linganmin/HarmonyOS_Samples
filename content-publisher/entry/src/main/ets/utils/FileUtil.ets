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

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG_LOG = 'FileUtil';

/**
 * Select a images from the album
 *
 * @returns {string[]} return selected image uris
 */
export function selectImagesFromAlbum(maxNumber: number = 5): Promise<string[]> {
  const photoPicker = new photoAccessHelper.PhotoViewPicker();
  const photoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
    maxSelectNumber: maxNumber
  };
  return photoPicker.select(photoSelectOptions).then(photoSelectResult => {
    return photoSelectResult.photoUris;
  }).catch((e: BusinessError) => {
    Logger.error(TAG_LOG, `Failed to select images from album: ${e.code}, ${e.message}`);
    return [];
  });
}