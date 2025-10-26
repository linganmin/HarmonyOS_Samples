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
import { image } from '@kit.ImageKit';

const TAG: string = 'AvSessionController';

export class AvSessionController {
  private static instance: AvSessionController | null;
  private context?: common.UIAbilityContext;
  private avSession?: avSession.AVSession;
  private avSessionMetadata?: avSession.AVMetadata;

  constructor() {
    this.initAvSession();
  }

  public static getInstance(): AvSessionController {
    if (!AvSessionController.instance) {
      AvSessionController.instance = new AvSessionController();
    }
    return AvSessionController.instance;
  }

  // [Start init_session]
  public initAvSession(): void {
    this.context = AppStorage.get('context');
    // [StartExclude init_session]
    if (!this.context) {
      Logger.info(TAG, `session create failed : context is undefined`);
      return;
    }
    // [EndExclude init_session]
    try {
      avSession.createAVSession(this.context, "SHORT_AUDIO_SESSION", 'video').then(async (avSession) => {
        this.avSession = avSession;
        Logger.info(TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
        // Apply for background long-term tasks
        BackgroundTaskManager.startContinuousTask(this.context);
        this.setLaunchAbility();
        this.avSession.activate().catch((err: BusinessError) => {
          Logger.error(TAG, `avSession activate failed: err.code:${err.code}, err.message:${err.message}`);
        });
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `avSession activate failed: err.code:${err.code}, err.message:${err.message}`);
      });
    } catch (err) {
      Logger.error(TAG, `createAVSession failed, err.code:${err.code}, err.message:${err.message}`);
    }
  }

  // [End init_session]
  public getAvSession(): avSession.AVSession | undefined {
    return this.avSession;
  }

  public getAvSessionMetadata(): avSession.AVMetadata | undefined {
    return this.avSessionMetadata;
  }

  // [Start meta_data]
  public async setAVMetadata(curSource: VideoData, duration: number): Promise<void> {
    // [StartExclude meta_data]
    if (curSource === undefined || this.context === undefined) {
      Logger.error(TAG, 'SetAVMetadata Error, curSource or context is undefined');
      return;
    }
    // [EndExclude meta_data]
    const imagePixMap: image.PixelMap | undefined = await ImageUtil.getPixmapFromMedia(curSource.head);
    if (imagePixMap === undefined) {
      Logger.error(TAG, 'SetAVMetadata Error, imagePixMap is undefined');
      return;
    }
    try {
      let metadata: avSession.AVMetadata = {
        assetId: `${curSource.index}`, // Media ID
        title: this.context.resourceManager.getStringSync(curSource.name.id), // title
        mediaImage: imagePixMap, // Pixel data or picture path address of a picture.
        duration: duration // Media duration, in ms
      };
      if (this.avSession) {
        this.avSession.setAVMetadata(metadata).then(() => { // Call the set session metadata interface
          this.avSessionMetadata = metadata;
          Logger.info(TAG, "SetAVMetadata successfully");
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
        });
      }
    } catch (err) {
      Logger.error(TAG, `setAVMetadata failed, code: ${err.code}, message: ${err.message}`);
    }
  }

  // [End meta_data]

  // [Start launch]
  private setLaunchAbility(): void {
    // [StartExclude launch]
    if (!this.context) {
      return;
    }
    // [EndExclude launch]
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName, // Name of the application Bundle where the Ability to be started is located.
          abilityName: this.context.abilityInfo.name // Ability name to be started
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITIES, // Action type, START_ABILITY indicates the Ability to open multiple pages.
      requestCode: 0, // A user-defined private value.
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG] // Action execution attribute, UPDATE_PRESENT_FLAG means replacing the extra data in the existing WantAgent with the extra data of the new WantAgent.
    };
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      if (this.avSession) {
        this.avSession.setLaunchAbility(agent).catch((err: BusinessError) => {
          Logger.error(TAG, `avSession setLaunchAbility failed: code: ${err.code}, message: ${err.message}`);
        });
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `getWantAgent failed: code: ${err.code}, message: ${err.message}`);
    });
  }

  // [End launch]

  // [Start update_is_play]
  public setAvSessionPlayState(playbackState: avSession.AVPlaybackState): void {
    if (this.avSession) {
      this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, "SetAVPlaybackState successfully");
        }
      });
    }
  }

  // [End update_is_play]

  // [Start init_session]
  async unregisterSessionListener(): Promise<void> {
    // [StartExclude init_session]
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
    } catch (err) {
      Logger.error(TAG, `unregisterSessionListener failed: code: ${err.code}, message: ${err.message}`);
    }
    // [EndExclude init_session]
    // Destroy background long-term tasks
    BackgroundTaskManager.stopContinuousTask(this.context);
  }

  // [End init_session]
}