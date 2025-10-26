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

import { media } from '@kit.MediaKit';
import { dataSharePredicates } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { VideoSizeData } from '../../model/VideoSizeData';

const TAG: string = 'PHOTO_UTILS';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class PhotoUtils {
  private phAccessHelper: photoAccessHelper.PhotoAccessHelper =
    photoAccessHelper.getPhotoAccessHelper(uiContext?.getHostContext());

  // [Start select_Video]
  /**
   * Pull up the gallery picker and select a video.
   * @returns The url of the selected video.
   */
  async selectVideo(): Promise<string> {
    try {
      let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      return photoViewPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        maxSelectNumber: 1
      }).then((photoSelectResult: photoAccessHelper.PhotoSelectResult): string => {
        if (photoSelectResult.photoUris.length <= 0) {
          return '';
        }
        return photoSelectResult.photoUris[0];
      })
    } catch (error) {
      hilog.error(0x0000, TAG, `selectVideo catch error, code: ${error.code}, message: ${error.message}`);
      return '';
    }
  }

  // [End select_Video]
  /**
   * Get default thumbnail through video url.
   * @param videoUrl: The url of video to get thumbnail.
   * @returns The thumbnail of video.
   */
  async acquireThumbnailByUrl(videoUrl: string): Promise<PixelMap | undefined> {
    try {
      // [Start data_Share_Predicates]
      // Obtain video resources.
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', videoUrl);
      let videoFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await this.phAccessHelper.getAssets({
          fetchColumns: ['width', 'height', 'orientation'],
          predicates: predicates
        });
      let photoAsset: photoAccessHelper.PhotoAsset = await videoFetchResult.getFirstObject();
      // [End data_Share_Predicates]
      // [Start thumbnail_Size]
      // Configure thumbnail parameters.
      let thumbnailSize: Size = { width: 0, height: 0 };
      if (photoAsset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 90 ||
        photoAsset.get(photoAccessHelper.PhotoKeys.ORIENTATION) === 270) {
        thumbnailSize.width = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
        thumbnailSize.height = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
      } else {
        thumbnailSize.width = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
        thumbnailSize.height = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
      }
      return photoAsset.getThumbnail(thumbnailSize);
      // [End thumbnail_Size]
    } catch (error) {
      hilog.error(0x0000, TAG, `acquireThumbnail failed, error: ${JSON.stringify(error)}`);
      return undefined;
    }
  }

  // [Start get_Video_Data]
  /**
   * Get video infos through video file descriptor.
   * @param avFileDescriptor AVFileDescriptor of video.
   * @returns the size infos of video.
   */
  async getVideoData(avFileDescriptor: media.AVFileDescriptor): Promise<VideoSizeData> {
    let videoSize: VideoSizeData = new VideoSizeData();
    try {
      let avMetaDataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      avMetaDataExtractor.fdSrc = avFileDescriptor;
      let metadata = await avMetaDataExtractor.fetchMetadata();
      videoSize.photoSize.width = parseInt(metadata.videoWidth as string);
      videoSize.photoSize.height = parseInt(metadata.videoHeight as string);
      if (metadata.duration) {
        videoSize.totalTime = parseInt(metadata.duration);
      }
      avMetaDataExtractor.release();
    } catch (error) {
      hilog.error(0x0000, TAG, `getVideoData catch error, code: ${error.code}, message: ${error.message}`);
    }
    return videoSize;
  }

  // [End get_Video_Data]
}