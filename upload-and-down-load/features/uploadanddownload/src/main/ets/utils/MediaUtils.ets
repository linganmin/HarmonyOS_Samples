/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'MediaUtils';

export class MediaUtils {
  async copyFileToCache(cacheDir: string, uri: string): Promise<string> {
    let id = uri.split('/').pop();
    let imagePath = `${cacheDir}/${id}.jpg`;
    try {
      let file = await fileIo.open(uri);
      try {
        fileIo.copyFileSync(file.fd, imagePath);
      } catch (err) {
        logger.error(TAG, `copyFileToCache copyFileSync code=${err.code}, message=${err.message}`);
      }
      await fileIo.close(file.fd);
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `copyFileToCache failed, error code=${err.code}, message=${err.message}`);
    }
    return imagePath;
  }
}