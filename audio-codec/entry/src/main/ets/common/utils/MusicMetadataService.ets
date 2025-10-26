/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface MusicMetadata {
  pixelMap?: image.PixelMap;
  metadata?: media.AVMetadata;
}

const DOMAIN = 0x0001;

export class MusicMetadataService {
  async fetchMetadata(uri: string): Promise<MusicMetadata> {
    let avMetadataExtractor: media.AVMetadataExtractor | null = null;
    let pixelMap: PixelMap | undefined = undefined;
    let metadata: media.AVMetadata | undefined = undefined;
    if (canIUse('SystemCapability.Multimedia.Media.AVMetadataExtractor')) {
      try {
        avMetadataExtractor = await media.createAVMetadataExtractor();
        avMetadataExtractor.fdSrc = fs.openSync(uri);
        metadata = await avMetadataExtractor.fetchMetadata();
        hilog.info(DOMAIN, 'this avPlayer', '%{public}s', `Get metadata successfully, mimeType: ${metadata.mimeType}`);
        await avMetadataExtractor
          .fetchAlbumCover()
          .then((cover: PixelMap) => {
            pixelMap = cover;
          })
          .catch((err: Error) => {
            hilog.error(DOMAIN, 'this avPlayer', '%{public}s', `Get Album Cover Failed`, err);
          });
      } catch (err) {
        hilog.error(DOMAIN, 'this avPlayer', '%{public}s', `createAVMetadataExtractor Failed`);
      } finally {
        try {
          avMetadataExtractor?.release();
          fs.closeSync(avMetadataExtractor?.fdSrc?.fd);
        } catch (err) {
          hilog.error(DOMAIN, 'this avPlayer close', '%{public}s', `close file Failed`);
        }
      }
      return { pixelMap: pixelMap, metadata: metadata };
    } else {
      throw new Error('System does not support AVMetadataExtractor');
    }
  }
}

export const METADATA_SERVICE = new MusicMetadataService();