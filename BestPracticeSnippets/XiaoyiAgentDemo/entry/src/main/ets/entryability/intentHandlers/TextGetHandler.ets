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

// [Start name]
import { insightIntent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaService } from '../../utils/audioplayer/MediaService';

export default class TextGetHandler {
  async execute(): Promise<insightIntent.ExecuteResult> {
    try {
      // Execute the method of obtaining the name of the played audio.
      const audioName: string = MediaService.getInstance().getAudioFileName();

      // Return result.
      return {
        code: 0,
        result: {
          status:'success',
          audioName: audioName,
          message: 'get audio name success'
        }
      };
    } catch (error) {
      throw new Error(`get audio name failed: ${(error as BusinessError).message}`);
    }
  }
}
// [End name]