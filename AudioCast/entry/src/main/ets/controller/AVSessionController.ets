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

import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SongItem } from '../model/SongData';
import { MediaTools } from '../common/utils/MediaTools';
import { AudioPlayerController } from './AudioPlayerController';
import { Controller } from '../model/SongData';

const TAG = 'AVSessionController';

export class AVSessionController {
  private context: common.UIAbilityContext | undefined = undefined;
  public AVSession: avSession.AVSession | undefined = undefined;
  private songList: SongItem[] = [];
  private musicIndex: number = 0;

  constructor() {
    let list: SongItem[] | undefined = AppStorage.get('songList');
    if (list) {
      this.songList = list;
    }
    this.initAVSession().catch(() => {
      hilog.error(0x0000, TAG, 'initAVSession failed');
    });
  }

  public static getInstance(): AVSessionController {
    let avSessionController: AVSessionController | undefined = AppStorage.get('AVSessionController');
    if (!avSessionController) {
      avSessionController = new AVSessionController();
      AppStorage.setOrCreate<AVSessionController>('AVSessionController', avSessionController);
    }
    return avSessionController;
  }

  public async initAVSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      hilog.info(0x0000, TAG, `session create failed : conext is undefined`);
      return;
    }
    try {
      // [Start CreateAvSession]
      this.AVSession = await avSession.createAVSession(this.context, "PLAY_AUDIO", 'audio');
      // [End CreateAvSession]
      this.setLaunchAbility();
      // [Start ActivateAvSession]
      await this.AVSession.activate();
      // [End ActivateAvSession]
      // [Start SetExtras]
      await this.AVSession.setExtras({
        'requireAbilityList': ['url-cast']
      });
      // [End SetExtras]
      hilog.info(0x0000, TAG, `session create successed : sessionId : ${this.AVSession.sessionId}`);
    } catch (err) {
      hilog.error(0x0000, TAG, `createAVSession failed Cause: code ${err.code}`);
    }
  }

  private setLaunchAbility() {
    if (!this.context) {
      return;
    }
    // [Start setLaunchAbility]
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      if (this.AVSession) {
        this.AVSession.setLaunchAbility(agent);
      }
    }).catch(() => {
      hilog.error(0x0000, TAG, `getWantAgent failed.`);
    });
    // [End setLaunchAbility]
  }

  private getDuration() {
    let duration: number | undefined = AppStorage.get('durationTime');
    if (!duration) {
      hilog.error(0x0000, TAG, 'get duration failed');
      return;
    }
    return duration;
  }

  public async setAVMetadata(isAvPlayerPlay: boolean) {
    this.musicIndex = AppStorage.get('selectIndex') || 0;
    if (this.musicIndex === undefined) {
      this.musicIndex = 0;
    }
    try {
      if (this.context) {
        let mediaImage = await MediaTools.getPixelMapFromResource(this.context,
          this.songList[this.musicIndex].label as resourceManager.Resource);
        hilog.info(0x0000, TAG, 'getPixelMapFromResource success' + JSON.stringify(mediaImage));
        // [Start SetAvMetadata]
        let metadata: avSession.AVMetadata;
        // [StartExclude SetAvMetadata]
        if (isAvPlayerPlay) {
          // [EndExclude SetAvMetadata]
          metadata = {
            assetId: 'AUDIO-' + JSON.stringify(this.musicIndex),
            title: this.songList[this.musicIndex].title,
            artist: this.songList[this.musicIndex].singer,
            filter: avSession.ProtocolType.TYPE_DLNA | avSession.ProtocolType.TYPE_CAST_PLUS_STREAM,
            mediaImage: mediaImage,
            duration: this.getDuration(),
          };
          // [StartExclude SetAvMetadata]
        } else {
          metadata = {
            assetId: 'AUDIO-' + JSON.stringify(this.musicIndex),
            title: this.songList[this.musicIndex].title,
            artist: this.songList[this.musicIndex].singer,
            filter: avSession.ProtocolType.TYPE_CAST_PLUS_AUDIO,
            mediaImage: mediaImage,
            duration: this.getDuration(),
          };
        }
        // [EndExclude SetAvMetadata]
        if (this.AVSession) {
          await this.AVSession.setAVMetadata(metadata);
        }
        // [End SetAvMetadata]
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `SetAVMetadata try: code: ${(error as BusinessError).code}`);
    }
  }

  public async stopCasting() {
    try {
      await this.AVSession?.stopCasting();
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession stopCasting failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Sets up AV session event listeners for playback control.
   * Handles play/pause/stop commands, seeking, fast forward/rewind, and device changes.
   * @param avPlayerController The player controller to manage playback.
   */
  public async setAvSessionListener(controller: Controller) {
    await this.unregisterSessionListener();
    try {
      // [Start ListenAvSessionPlay]
      this.AVSession?.on('play', () => controller?.setPlaying());
      this.AVSession?.on('pause', () => controller?.setPause());
      // [End ListenAvSessionPlay]
      this.AVSession?.on('stop', () => controller?.setStop());
      this.AVSession?.on('seek', (time: number) => {
        controller?.seek(time);
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession on event failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  public async setLoopModeState(AVSessionLoopMode: number) {
    if (this.AVSession) {
      try {
        this.AVSession.setAVPlaybackState({ loopMode: AVSessionLoopMode }, (err: BusinessError) => {
          if (err) {
            hilog.error(0x0000, TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
          } else {
            hilog.info(0x0000, TAG, 'SetAVPlaybackState successfully');
          }
        });
      } catch (error) {
        hilog.error(0x0000, TAG, `avSession setAVPlaybackState failed, the error is: ${JSON.stringify(error)}`);
      }
    }
  }

  public initAvSessionPlayState(avPlayerController: AudioPlayerController | undefined) {
    try {
      this.AVSession?.setAVPlaybackState({
        state: avPlayerController?.state === 'playing' ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: avPlayerController?.currentTime,
          updateTime: new Date().getTime(),
        },
        speed: 1.0,
        bufferedTime: 14000,
        duration: avPlayerController?.durationTime
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession setAVPlaybackState failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Updates AV session playback state.
   * @param state Current player state ('playing' or other).
   */
  public async setAvSessionState(isPlay: boolean) {
    try {
      // [Start SetAvSessionPlay]
      await this.AVSession?.setAVPlaybackState({
        state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      });
      // [End SetAvSessionPlay]
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession setAVPlaybackState failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Updates playback position in AV session.
   * @param position Current playback position in milliseconds.
   */
  public async setAvSessionPosition(position: number) {
    try {
      // [Start SetAvSessionPosition]
      await this.AVSession?.setAVPlaybackState({
        position: {
          elapsedTime: position,
          updateTime: new Date().getTime()
        }
      });
      // [End SetAvSessionPosition]
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession setAVPlaybackState failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  async unregisterSessionListener() {
    if (!this.AVSession) {
      return;
    }
    try {
      this.AVSession.off('play');
      this.AVSession.off('pause');
      this.AVSession.off('playNext');
      this.AVSession.off('playPrevious');
      this.AVSession.off('seek');
      this.AVSession.off('setLoopMode');
      this.AVSession.off('outputDeviceChange');
    } catch (err) {
      hilog.error(0x0000, TAG, 'AVSession off failed');
    }
  }
}