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

// [Start session_controller1]
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

const TAG: string = 'AvSessionController';

export class AvSessionController {
  private avSession?: avSession.AVSession;
  private context?: common.UIAbilityContext;

  public initAvSession(): void {
    this.context = AppStorage.get('context');
    if (!this.context) {
      Logger.info(TAG, `session create failed : context is undefined`);
      return;
    }
    // Create an AVSession with the session type set to' video'.
    avSession.createAVSession(this.context, "SHORT_AUDIO_SESSION", 'video').then(async (avSession) => {
      this.avSession = avSession;
      Logger.info(TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
      //Sets the UIAbility for being pulled up by the broadcast control center.
      this.setLaunchAbility();
      // Activate media session
      this.avSession.activate().catch((err: BusinessError) => {
        Logger.error(TAG, `avSession activate failed: err.code:${err.code}, err.message:${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `avSession activate failed: err.code:${err.code}, err.message:${err.message}`);
    });
  }
  // [StartExclude session_controller1]
  setLaunchAbility() {}
  // [EndExclude session_controller1]
}
// [End session_controller1]