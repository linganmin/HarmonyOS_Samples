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

import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class ImageUtil {
  // [Start GetThumbnailFromVideo]
  public static async getThumbnailFromVideo(src: string, timeUs: number) {
    let pixelMap: image.PixelMap | undefined = undefined;
    let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
    let param: media.PixelMapParams = {
      width: 540,
      height: 304
    };
    try {
      let generator: media.AVImageGenerator = await media.createAVImageGenerator();
      let fileDescriptor = await uiContext?.getHostContext()?.resourceManager?.getRawFd(src);
      generator.fdSrc = fileDescriptor;
      pixelMap = await generator.fetchFrameByTime(timeUs, queryOption, param);
    } catch (exception) {
      hilog.error(0x0000, 'ImageUtil',
        `getThumbnailFromVideo failed, code is ${exception.code}, message is ${exception.message}`)
    }
    return pixelMap;
  }

  // [End GetThumbnailFromVideo]
}