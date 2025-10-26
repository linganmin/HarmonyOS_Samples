/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'FileUtil';
const FORMAT = '%{public}s';

/*
 * Select a picture from the gallery.
 * @returns uri The uri for the selected file.
 */
export async function fileSelect(): Promise<Array<string>> {
  let imgUri: Array<string> = [];
  let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  PhotoSelectOptions.maxSelectNumber = 5;
  let photoPicker = new photoAccessHelper.PhotoViewPicker();
  try {
    let PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    if (PhotoSelectResult && PhotoSelectResult.photoUris && PhotoSelectResult.photoUris.length > 0) {
      imgUri = PhotoSelectResult.photoUris;
      return imgUri;
    } else {
      return [];
    }
  } catch (error) {
    hilog.error(DOMAIN, TAG, FORMAT, `PhotoViewPicker failed with err: ${error.code}, ${error.message}`);
    return [];
  }
}