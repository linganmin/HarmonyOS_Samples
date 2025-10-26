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

import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { VideoData } from '../model/VideoData';
import Logger from '../utils/Logger';
import { ImageUtil } from '../utils/ImageUtil';
import { BackgroundTaskManager } from '../utils/BackgroundTaskManager';

const TAG = 'AvSessionController';

export class AvSessionController {
  private static instance: AvSessionController | null;
  private context: common.UIAbilityContext | undefined = undefined;
  private avSession: avSession.AVSession | undefined = undefined;
  private avSessionMetadata: avSession.AVMetadata | undefined = undefined;

  constructor() {
    this.initAvSession();
  }

  public static getInstance(): AvSessionController {
    if (!AvSessionController.instance) {
      AvSessionController.instance = new AvSessionController();
    }
    return AvSessionController.instance;
  }

  public initAvSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      Logger.info(TAG, `session create failed : conext is undefined`);
      return;
    }
    avSession.createAVSession(this.context, "SHORT_AUDIO_SESSION", 'video')
      .then(async (avSession) => {
        this.avSession = avSession;
        Logger.info(TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
        BackgroundTaskManager.startContinuousTask(this.context);
        this.setLaunchAbility();
        this.avSession.activate()
          .catch((err: BusinessError) => {
            Logger.error(TAG, `avSession activate failed Cause:  ${JSON.stringify(err)}`);
          })
    })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `createAVSession failed Cause:  ${JSON.stringify(err)}`);
      })
  }

  public getAvSession() {
    return this.avSession;
  }

  public getAvSessionMetadata() {
    return this.avSessionMetadata;
  }

  public async setAVMetadata(curSource: VideoData, duration: number, UIContext: UIContext) {
    if (curSource === undefined) {
      Logger.error(TAG, 'SetAVMetadata Error, curSource is null');
      return;
    }

    const imagePixMap = await ImageUtil.getPixmapFromMedia(curSource.head, UIContext);
    try {
      let metadata: avSession.AVMetadata = {
        assetId: `${curSource.index}`,
        title: this.context?.resourceManager.getStringSync(curSource.name),
        mediaImage: imagePixMap,
        duration: duration
      };
      if (this.avSession) {
        this.avSession.setAVMetadata(metadata).then(() => {
          this.avSessionMetadata = metadata;
          Logger.info(TAG, 'SetAVMetadata successfully');
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
        });
      }
    } catch (error) {
      Logger.error(`getStringSync failed Cause:  ${JSON.stringify(error)}`);
    }
  }

  private setLaunchAbility() {
    if (!this.context) {
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo)
      .then((agent) => {
        if (this.avSession) {
          this.avSession.setLaunchAbility(agent).catch((err: BusinessError) => {
            Logger.error(TAG, `setLaunchAbility failed Cause:  ${JSON.stringify(err)}`);
          })
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `getWantAgent failed Cause:  ${JSON.stringify(err)}`);
      })
  }

  public setAvSessionPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.avSession) {
      this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
    }
  }

  async unregisterSessionListener() {
    if (!this.avSession) {
      return;
    }
    try {
      this.avSession.off('play');
      this.avSession.off('pause');
      this.avSession.off('playNext');
      this.avSession.off('playPrevious');
      this.avSession.off('setLoopMode');
      this.avSession.off('seek');
      this.avSession.off('toggleFavorite');
      BackgroundTaskManager.stopContinuousTask(this.context);
    } catch (error) {
      Logger.error(`avSession off failed Cause:  ${JSON.stringify(error)}`);
    }
  }
}