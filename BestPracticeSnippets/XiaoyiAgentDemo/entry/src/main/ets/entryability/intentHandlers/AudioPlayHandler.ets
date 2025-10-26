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

// [Start play]
import { insightIntent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaService } from '../../utils/audioplayer/MediaService';

export default class AudioPlayHandler {

  async execute(param: Record<string, string>): Promise<insightIntent.ExecuteResult> {
    try {
      // Analyze the parameters passed in by the plugin on the parsing end.
      const rawAudioName = param.audioName;
      const audioName = rawAudioName.toString();

      // The method of playing audio can be customized by developers according to their actual business needs.
      MediaService.getInstance().initAudioPlayer(audioName);

      // Return the result to the end plugin.
      return {
        code: 0,
        result: {
          status: 'success',
          message: `play audio ${audioName} started`,
        }
      };
    } catch (error) {
      throw new Error(`Audio play failed: ${(error as BusinessError).message}`);
    }
  }
}
// [End play]