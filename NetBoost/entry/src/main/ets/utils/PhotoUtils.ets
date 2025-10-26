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

import { dataSharePredicates } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

const TAG: string = 'PhotoUtils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class PhotoUtils {
  private phAccessHelper: photoAccessHelper.PhotoAccessHelper =
    photoAccessHelper.getPhotoAccessHelper(uiContext?.getHostContext());

  /**
   * Obtain thumbnails through URI.
   * @param fileUri file uri.
   * @returns If it is a video, return a pixel map, if the URI itself is an image, return the URI directly.
   * */
  async acquireThumbnailByUrl(fileUri: string): Promise<PixelMap | string> {
    try {
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', fileUri);
      let videoFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await this.phAccessHelper.getAssets({
          fetchColumns: ['width', 'height', 'orientation', photoAccessHelper.PhotoKeys.PHOTO_TYPE,
            photoAccessHelper.PhotoKeys.SIZE],
          predicates: predicates
        });
      let photoAsset: photoAccessHelper.PhotoAsset = await videoFetchResult.getFirstObject();
      // if URI is a picture,return the URI directly.
      if (photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_TYPE) === photoAccessHelper.PhotoType.IMAGE) {
        return fileUri;
      }
      // if URI is a video,gets the video thumbnail.
      else if (photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_TYPE) === photoAccessHelper.PhotoType.VIDEO) {
        let thumbnailSize: Size = { width: 0, height: 0 };
        if (photoAsset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 90 ||
          photoAsset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 270) {
          thumbnailSize.width = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
          thumbnailSize.height = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
        } else {
          thumbnailSize.width = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
          thumbnailSize.height = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
        }
        hilog.info(0x0000, TAG, `[acquireThumbnailByUrl] acquireThumbnail from video`);
        const res = photoAsset.getThumbnail(thumbnailSize).catch((error: BusinessError) => {
          const err: BusinessError = error as BusinessError;
          hilog.error(0x0000, TAG, `acquireThumbnail failed, error: ${err.code},${err.name}`);
          return '';
        });
        return res;
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, `acquireThumbnail failed, error: ${err.code},${err.name}`);
    }
    return '';
  }
}