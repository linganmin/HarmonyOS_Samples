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
import { common, wantAgent } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { BackgroundTaskManager } from '../common/utils/BackgroundTaskManager';
import { VideoData } from '../model/VideoData';
import { VideoPlayerController } from './VideoPlayerController';
import { getPixmapFromMedia } from '../common/utils/ImageUtil';

export class VideoSessionController {
  @Track deviceName: string = '';
  @Track connectionState: avSession.ConnectionState = avSession.ConnectionState.STATE_DISCONNECTED;
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
    // [Start ArticleCitationsActiveAVSession]
    let videoSession = await avSession.createAVSession(context, 'VIDEO_SESSION', 'video');
    // Set up a background task.
    BackgroundTaskManager.startContinuousTask(context);
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
    let agent = wantAgent.getWantAgent(wantAgentInfo);
    videoSession.setLaunchAbility(agent);
    videoSession.activate();
    return new VideoSessionController(videoSession);
    // [End ArticleCitationsActiveAVSession]
  }

  /**
   * Sets metadata for the current video session.
   * @param curSource Video data containing index, name and head image.
   * @param duration Total duration of the video in milliseconds.
   */
  public async setAVMetadata(curSource: VideoData, duration: number) {
    let headPixel = await getPixmapFromMedia(curSource.head);
    // [Start ArticleCitationsSetAVMetadata]
    let metadata: avSession.AVMetadata = {
      assetId: `${curSource.index}`,
      title: curSource.name,
      mediaImage: headPixel,
      duration: duration,
      filter: avSession.ProtocolType.TYPE_DLNA | avSession.ProtocolType.TYPE_CAST_PLUS_STREAM
    };
    await this.videoSession.setAVMetadata(metadata);
    // [End ArticleCitationsSetAVMetadata]
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
    });
  }

  /**
   * Updates AV session playback state.
   * @param state Current player state ('playing' or other).
   */
  public async setAvSessionState(state: string) {
    // [Start ArticleCitationsSetAvSessionState]
    await this.videoSession.setAVPlaybackState({
      state: state === 'playing' ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
    });
    // [End ArticleCitationsSetAvSessionState]
  }

  /**
   * Updates playback speed in AV session.
   * @param speed The current playback speed (1.0 = normal speed).
   */
  public async setAvSessionSpeed(speed: number) {
    await this.videoSession.setAVPlaybackState({
      speed: speed
    });
  }

  /**
   * Updates playback position in AV session.
   * @param position Current playback position in milliseconds.
   */
  public async setAvSessionPosition(position: number) {
    await this.videoSession.setAVPlaybackState({
      position: {
        elapsedTime: position,
        updateTime: new Date().getTime()
      }
    });
  }

  public async stopCasting() {
    await this.videoSession.stopCasting();
  }

  /**
   * Sets up AV session event listeners for playback control.
   * Handles play/pause/stop commands, seeking, fast forward/rewind, and device changes.
   * @param avPlayerController The player controller to manage playback.
   */
  public async setAvSessionListener(avPlayerController: VideoPlayerController) {
    // [Start ArticleCitationsSetSetAvSessionListener]
    this.videoSession.on('play', () => avPlayerController.setAVPlayerPlaying());
    this.videoSession.on('pause', () => avPlayerController.setAVPlayerPause());
    // [End ArticleCitationsSetSetAvSessionListener]
    this.videoSession.on('stop', () => avPlayerController.setAVPlayerPause());
    this.videoSession.on('seek', (time: number) => {
      avPlayerController.avPlayerSeek(time, media.SeekMode.SEEK_CLOSEST);
    });
    this.videoSession.on('fastForward', (time?: number) => {
      if (time) {
        avPlayerController.avPlayerSeek(avPlayerController.currentTime + 15000, media.SeekMode.SEEK_NEXT_SYNC);
      }
    });
    this.videoSession.on('rewind', (time?: number) => {
      if (time) {
        avPlayerController.avPlayerSeek(avPlayerController.currentTime - 15000, media.SeekMode.SEEK_PREV_SYNC);
      }
    });
    this.videoSession.on('outputDeviceChange',
      (state: avSession.ConnectionState, device: avSession.OutputDeviceInfo) => {
        this.connectionState = state;
        this.deviceName = device.devices[0].deviceName;
      })
  }

  /**
   * Releases AV session resources and removes all listeners.
   * @param context The UIAbility context for cleanup tasks.
   */
  public async releaseAvSessionListener(context: common.UIAbilityContext) {
    this.videoSession.off('play');
    this.videoSession.off('pause');
    this.videoSession.off('playNext');
    this.videoSession.off('playPrevious');
    this.videoSession.off('setLoopMode');
    this.videoSession.off('seek');
    this.videoSession.off('rewind');
    this.videoSession.off('outputDeviceChange');
    await BackgroundTaskManager.stopContinuousTask(context);
    await this.videoSession.stopCasting();
    await this.videoSession.destroy();
  }
}