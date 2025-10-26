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

import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { media } from '@kit.MediaKit';
import { BackgroundTaskManager } from '../common/utils/BackgroundTaskManager';
import { VideoPlayerController } from './VideoPlayerController';
import Logger from '../common/utils/Logger';

const TAG = '[VideoSessionController]';

export class VideoSessionController {
  public videoSession: avSession.AVSession;

  private constructor(videoSession: avSession.AVSession) {
    this.videoSession = videoSession;
  }

  /**
   * Creates and activates a new AVSession for video playback.
   * @param context The UIAbility context for session creation.
   * @returns Promise<AVSessionController> Initialized session controller instance.
   */
  static async create(context: common.UIAbilityContext) {
    let videoSession: avSession.AVSession;
    try {
      videoSession = await avSession.createAVSession(context, 'VIDEO_SESSION', 'video');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `get videoSession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }
    // Set up a background task.
    BackgroundTaskManager.startContinuousTask(backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, context);
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    let agent = wantAgent.getWantAgent(wantAgentInfo).catch((err: BusinessError) => {
      Logger.error(TAG, `getWantAgent failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    });
    videoSession.setLaunchAbility(agent).catch((err: BusinessError) => {
      Logger.error(TAG, `setLaunchAbility failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    });
    videoSession.activate().catch((err: BusinessError) => {
      Logger.error(TAG, `videoSession activate failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    });
    return new VideoSessionController(videoSession);
  }

  /**
   * Sets metadata for the current video session.
   * @param curSource Video data containing index, name and head image.
   * @param duration Total duration of the video in milliseconds.
   */
  public async setAVMetadata(assetId: string, duration: number) {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    let context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
    let metadata: avSession.AVMetadata;
    try {
      metadata = {
        assetId: assetId,
        title: context.resourceManager.getStringSync($r('app.string.home_page_title').id),
        duration: duration,
      };
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `get metadata failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }
    try {
      await this.videoSession.setAVMetadata(metadata);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `videoSession setAVMetadata failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Initializes AV session playback state from player controller.
   * @param avPlayerController The player controller providing playback state.
   */
  public initAvSessionPlayState(avPlayerController: VideoPlayerController) {
    this.videoSession.setAVPlaybackState({
      state: avPlayerController.state === 'playing' ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: avPlayerController.currentTime,
        updateTime: new Date().getTime(),
      },
      speed: 1.0,
      bufferedTime: 14000,
      duration: avPlayerController.durationTime
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `setAVPlaybackState failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    });
  }

  /**
   * Updates AV session playback state.
   * @param state Current player state ('playing' or other).
   */
  public async setAvSessionState(state: string) {
    try {
      await this.videoSession.setAVPlaybackState({
        state: state === 'playing' ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
          avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setAVPlaybackState setAVMetadata failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Updates playback position in AV session.
   * @param position Current playback position in milliseconds.
   */
  public async setAvSessionPosition(position: number) {
    try {
      await this.videoSession.setAVPlaybackState({
        position: {
          elapsedTime: position,
          updateTime: new Date().getTime()
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setAVPlaybackState failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Sets up AV session event listeners for playback control.
   * Handles play/pause/stop commands, seeking, fast forward/rewind, and device changes.
   * @param avPlayerController The player controller to manage playback.
   */
  public async setAvSessionListener(avPlayerController: VideoPlayerController) {
    try {
      this.videoSession.on('play', () => avPlayerController.setAVPlayerPlaying());
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add play callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.on('pause', () => avPlayerController.setAVPlayerPause());
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add pause callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.on('stop', () => avPlayerController.setAVPlayerPause());
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add stop callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.on('seek', (time: number) => {
        avPlayerController.avPlayerSeek(time, media.SeekMode.SEEK_CLOSEST).catch((err: BusinessError) => {
          Logger.error(TAG, `avPlayerSeek failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        });
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add seek callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.on('fastForward', (time?: number) => {
        if (time) {
          avPlayerController.avPlayerSeek(avPlayerController.currentTime + 15000, media.SeekMode.SEEK_NEXT_SYNC)
            .catch((err: BusinessError) => {
              Logger.error(TAG, `avPlayerSeek failed, errCode = ${err.code}, errMessage = ${err.message}.`);
            });
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add fastForward callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.on('rewind', (time?: number) => {
        if (time) {
          avPlayerController.avPlayerSeek(avPlayerController.currentTime - 15000, media.SeekMode.SEEK_PREV_SYNC)
            .catch((err: BusinessError) => {
              Logger.error(TAG, `avPlayer seek failed, errCode = ${err.code}, errMessage = ${err.message}.`);
            });
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `add rewind callback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Releases AV session resources and removes all listeners.
   * @param context The UIAbility context for cleanup tasks.
   */
  public async releaseAvSessionListener(context: common.UIAbilityContext) {
    try {
      this.videoSession.off('play');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `off failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.off('pause');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `pause failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.off('stop');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `stop failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.off('seek');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `seek failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.off('fastForward');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `fastForward failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    try {
      this.videoSession.off('rewind');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `rewind failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    await BackgroundTaskManager.stopContinuousTask(context);
    try {
      await this.videoSession.destroy();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `videoSession destroy failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }
}