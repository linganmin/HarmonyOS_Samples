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

import { fileIo } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class FileUtil {
  /**
   * Get thumbnail from video file.
   *
   * @param path video file path.
   * @param thumbPath thumbnail path.
   */
  public async getVideoThumbnail(path: string, thumbPath: string): Promise<boolean> {
    if (!canIUse('SystemCapability.Multimedia.Media.AVImageGenerator')) {
      return false;
    }
    try {
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
      let timeUs = 0;
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      let param: media.PixelMapParams = {
        width: 300,
        height: 300
      };
      let pixmap: image.PixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      const imagePackerApi = image.createImagePacker();
      let file = fileIo.openSync(thumbPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      await imagePackerApi.packToFile(pixmap, file.fd, packOpts);
      return true;
    } catch (error) {
      hilog.error(0x0000, 'KnockFileShare', JSON.stringify(error));
    }
    return false;
  }

  /**
   * Get MIME type by file extension.
   *
   * @param filePath file path.
   * @returns mime type.
   */
  public static getMimeTypeFromPath(filePath: string): string {
    const extension = filePath.split('.').pop();
    if (!extension) {
      return 'image/jpeg';
    }
    const mimeType: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'svg': 'image/svg+xml',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'mp4': 'video/mp4',
      'mkv': 'video/x-matroska',
      'webm': 'video/webm',
      'zip': 'application/zip',
      'rar': 'application/x-rar-compressed',
      '7z': 'application/x-7z-compressed'
    };
    return mimeType[extension] || 'image/jpeg';
  }
}
