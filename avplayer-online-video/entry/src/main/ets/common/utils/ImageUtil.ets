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
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';

const TAG = '[ImageUtil]';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class ImageUtil {
  public static async getPixmapFromMedia(resource: Resource) {
    let createPixelMap: image.PixelMap = {} as image.PixelMap;
    try {
      let unit8Array = await uiContext?.getHostContext()?.resourceManager?.getMediaContent(resource.id);
      let imageSource = image.createImageSource(unit8Array?.buffer.slice(0, unit8Array?.buffer.byteLength));
      createPixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      });
      await imageSource.release();
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `ImageUtil.getPixmapFromMedia failed, code is ${err.code}, message is ${err.message}`);
    }
    return createPixelMap;

  }

  public static async getVideoFirstFrame(avFileDescriptor: media.AVFileDescriptor): Promise<image.PixelMap> {

    let pixelMap = {} as image.PixelMap;
    try {
      let avMetaDataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      avMetaDataExtractor.fdSrc = avFileDescriptor;
      let metadata = await avMetaDataExtractor.fetchMetadata();

      let width = parseInt(metadata.videoWidth as string);
      let height = parseInt(metadata.videoHeight as string);

      avMetaDataExtractor.release();

      let avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = avFileDescriptor;

      pixelMap = await avImageGenerator.fetchFrameByTime(0,
        media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC, { width: width, height: height });

      avImageGenerator.release();

    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `ImageUtil.getVideoFirstFrame failed, code is ${err.code}, message is ${err.message}`);
    }
    return pixelMap;
  }

  public static async getThumbnailFromVideo(src: string, timeUs: number) {
    let pixelMap: image.PixelMap | undefined = undefined;
    let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
    let param: media.PixelMapParams = {
      width: 540,
      height: 304
    };

    try {
      let context = uiContext?.getHostContext() as common.UIAbilityContext;
      let generator: media.AVImageGenerator = await media.createAVImageGenerator();
      generator.fdSrc = await context.resourceManager.getRawFd(src);
      pixelMap = await generator.fetchFrameByTime(timeUs, queryOption, param);
      generator.release();
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, 'getThumbnailFromVideo fail:' + `code is ${err.code}, message is ${err.message}`);
    }
    return pixelMap;
  }
}