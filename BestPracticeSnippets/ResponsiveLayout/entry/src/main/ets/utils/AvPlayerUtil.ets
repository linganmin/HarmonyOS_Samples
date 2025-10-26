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

import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { CommonConstants } from '../constants/CommonConstants';

export class AvPlayerUtil {
  context: common.UIAbilityContext;
  private avPlayer?: media.AVPlayer;

  constructor(uiContext: UIContext) {
    this.context = uiContext.getHostContext() as common.UIAbilityContext;
  }

  static getInstance(uiContext: UIContext): AvPlayerUtil | undefined {
    if (!AppStorage.get<AvPlayerUtil>('avPlayerUtil')) {
      AppStorage.setOrCreate('avPlayerUtil', new AvPlayerUtil(uiContext));
    } else {
      Logger.info(`AppStorage does not have avPlayerUtil`);
    }
    return AppStorage.get<AvPlayerUtil>('avPlayerUtil');
  }

  playerStateControl(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_STOPPED_STATE) {
      this.avPlayer.prepare().catch((error: BusinessError) => {
        Logger.error(`avPlayer prepare failed. code=${error.code}, message = ${error.message}`);
      });
    } else if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.play().catch((error: BusinessError) => {
        Logger.error(`avPlayer play failed. code=${error.code}, message = ${error.message}`);
      });
    } else if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.avPlayer.pause().catch((error: BusinessError) => {
        Logger.error(`avPlayer pause failed. code=${error.code}, message = ${error.message}`);
      });
    }
  }

  fastForward(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE || this.avPlayer?.state ===
    CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.seek(this.avPlayer.currentTime + 5000);
    }
  }

  rewind(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE || this.avPlayer?.state ===
    CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.seek(this.avPlayer.currentTime - 5000);
    }
  }
}