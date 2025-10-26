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
// [Start avsession_controller]
import { avSession } from '@kit.AVSessionKit';
// [StartExclude avsession_controller]
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { SongItem } from '../songdatacontroller/SongData';
import { Logger } from './Logger';
import { MediaTools } from './MediaTools';
import { AudioRendererController } from './AudioRendererController';
import { MusicPlayMode } from '../songdatacontroller/PlayerData';
import { PreferencesUtil } from './PreferencesUtil';

const TAG = 'AVSessionController';
// [EndExclude avsession_controller]
export class AVSessionController {
  private context: common.UIAbilityContext | undefined = undefined;
  private AVSession: avSession.AVSession | undefined = undefined;
  private songList: SongItem[] = [];
  private musicIndex: number | undefined = undefined;
  private audioRendererController: AudioRendererController | undefined = undefined;
  // [StartExclude avsession_controller]
  constructor() {
    let list: SongItem[] | undefined = AppStorage.get('songList');
    if (list) {
      this.songList = list;
    }
    this.initAVSession();
  }

  public static getInstance(): AVSessionController {
    let avSessionController: AVSessionController | undefined = AppStorage.get('AVSessionController');
    if (!avSessionController) {
      avSessionController = new AVSessionController();
      AppStorage.setOrCreate<AVSessionController>('AVSessionController', avSessionController);
    }
    return avSessionController;
  }

  // [EndExclude avsession_controller]
  private async initAVSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      Logger.info(TAG, `session create failed : conext is undefined`);
      return;
    }
    this.audioRendererController = AppStorage.get('audioRendererController');
    if (!this.audioRendererController) {
      Logger.info(TAG, `session create failed : audioRendererController is undefined`);
      return;
    }
    this.AVSession = await avSession.createAVSession(this.context, "PLAY_AUDIO", 'audio');
    await this.AVSession.activate();
    // [StartExclude avsession_controller]
    Logger.info(TAG, `session create successed : sessionId : ${this.AVSession.sessionId}`);
    await this.setAVMetadata();
    this.setLaunchAbility();
    this.setListenerForMesFromController();
    if (this.musicIndex !== undefined) {
      this.getAndUpdateFavoriteState(this.musicIndex.toString());
    }
    // [EndExclude avsession_controller]
  }
  // [StartExclude avsession_controller]
  // [Start set_launch_ability]
  private setLaunchAbility() {
    if (!this.context) {
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
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
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      if (this.AVSession) {
        this.AVSession.setLaunchAbility(agent);
      }
    });
  }
  // [End set_launch_ability]
  private getDuration() {
    let duration: number | undefined = AppStorage.get('totalMsTime');
    if (!duration) {
      Logger.error(TAG, 'get duration failed');
      return;
    }
    return duration;
  }

  private getFirst(): boolean | undefined {
    if (!this.audioRendererController) {
      return;
    }
    return this.audioRendererController.getFirst();
  }

  // [Start set_avmetadata]
  public async setAVMetadata() {
    this.musicIndex = AppStorage.get('selectIndex');
    Logger.info(TAG, 'current musicIndex is:' + this.musicIndex);
    if (this.musicIndex === undefined) {
      this.musicIndex = 0;
    }
    try {
      if (this.context) {
        let mediaImage = await MediaTools.getPixelMapFromResource(this.context,
          this.songList[this.musicIndex].label as resourceManager.Resource);
        Logger.info(TAG, 'getPixelMapFromResource success' + JSON.stringify(mediaImage));
        let metadata: avSession.AVMetadata = {
          assetId: `${this.musicIndex}`,
          title: this.songList[this.musicIndex].title,
          artist: this.songList[this.musicIndex].singer,
          mediaImage: mediaImage,
          duration: this.getDuration(),
        };
        let lrc = await MediaTools.getLrcFromRawFile(this.context, this.songList[this.musicIndex].lyric);
        if (lrc) {
          metadata.lyric = lrc;
        }
        if (this.AVSession) {
          this.AVSession.setAVMetadata(metadata).then(() => {
            Logger.info(TAG, 'SetAVMetadata successfully');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
          });
        }
      }
    } catch (error) {
      Logger.error(TAG, `SetAVMetadata try: code: ${(error as BusinessError).code}`);
    }
  }
  // [End set_avmetadata]

  // [Start set_listener_for_mes_from_controller]
  async setListenerForMesFromController() {
    if (!this.AVSession) {
      return;
    }
    this.AVSession.on('play', this.onPlay);
    this.AVSession.on('pause', this.onPause);
    this.AVSession.on('playNext', this.onPlayNext);
    this.AVSession.on('playPrevious', this.onPlayPrevious);
    this.AVSession.on('seek', this.onSeek);
    this.AVSession.on('setLoopMode', this.onSetLoopMode);
    this.AVSession.on('toggleFavorite', this.onToggleFavorite);
  }
  // [End set_listener_for_mes_from_controller]
  private onPlay: () => void = () => {
    Logger.info(TAG, `on play , do play task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onPlay');
      return;
    }
    if (this.getFirst()) {
      this.audioRendererController.play();
    } else {
      this.audioRendererController.start();
    }
  }

  private onPause: () => void = () => {
    Logger.info(TAG, `on pause , do pause task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onPause');
      return;
    }
    this.audioRendererController.pause();
  }

  private onPlayNext: () => void = () => {
    Logger.info(TAG, `on playNext , do playNext task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onPlayNext');
      return;
    }
    this.audioRendererController.playNext();
  }

  private onPlayPrevious: () => void = () => {
    Logger.info(TAG, `on playPrevious , do playPrevious task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onPlayPrevious')
      return;
    }
    this.audioRendererController.playPrevious();
  }

  private onSeek: (curMs: number) => void = (curMs: number) => {
    Logger.info(TAG, `on seek , do seek task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onSeek');
      return;
    }
    this.audioRendererController.seek(curMs);
  }
  // [Start set_loop_mode_call]
  private onSetLoopMode: (loopMode: avSession.LoopMode) => void = (loopMode: avSession.LoopMode) => {
    Logger.info(TAG, `on setLoopMode , do loopMode task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in onSetLoopMode');
      return;
    }
    switch (loopMode) {
      case avSession.LoopMode.LOOP_MODE_SINGLE:
        this.audioRendererController.setPlayModel(MusicPlayMode.ORDER);
        break;
      case avSession.LoopMode.LOOP_MODE_SEQUENCE:
        this.audioRendererController.setPlayModel(MusicPlayMode.RANDOM);
        break;
      case avSession.LoopMode.LOOP_MODE_SHUFFLE:
        this.audioRendererController.setPlayModel(MusicPlayMode.SINGLE_CYCLE);
        break;
      default:
        break;
    }
    this.setPlayModeToAVSession();
    this.setPlayModeToControlArea();
  }
  // [End set_loop_mode_call]
  private onToggleFavorite: (assetId: string) => void = (assetId: string) => {
    Logger.info(TAG, `on toggleFavorite , do toggleFavorite task`);
    this.updateFavoriteState(assetId);
  }

  private setPlayModeToControlArea() {
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in setPlayModeToAVSession');
      return;
    }
    let currentPlayMode: MusicPlayMode = this.audioRendererController.getPlayMode();
    AppStorage.setOrCreate('playMode', currentPlayMode);
  }

  public setPlayModeToAVSession() {
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in setPlayModeToAVSession');
      return;
    }
    let currentPlayMode: MusicPlayMode = this.audioRendererController.getPlayMode();
    let AVSessionLoopMode: avSession.LoopMode | undefined = undefined;
    switch (currentPlayMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        AVSessionLoopMode = avSession.LoopMode.LOOP_MODE_SINGLE;
        break;
      case MusicPlayMode.ORDER:
        AVSessionLoopMode = avSession.LoopMode.LOOP_MODE_SEQUENCE;
        break;
      case MusicPlayMode.RANDOM:
        AVSessionLoopMode = avSession.LoopMode.LOOP_MODE_SHUFFLE;
        break;
      default:
        break;
    }
    if (AVSessionLoopMode !== undefined) {
      this.setLoopModeState(AVSessionLoopMode)
    }
  }
  // [Start set_favorite_state]
  private setFavoriteState(isFavorite: boolean) {
    if (this.AVSession) {
      this.AVSession.setAVPlaybackState({ isFavorite }, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
    }
  }

  public setProgressState(ms: number) {
    if (this.AVSession) {
      this.AVSession.setAVPlaybackState({
        position: {
          elapsedTime: ms,
          updateTime: new Date().getTime()
        }
      }, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
    }
  }

  public setPlayState(isPlay: boolean) {
    if (this.AVSession) {
      this.AVSession.setAVPlaybackState({
        state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      }, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
    }
  }

  // [StartExclude set_favorite_state]
  public async updateFavoriteState(assetId: string, isFavorite: boolean = false) {
    if (!this.context) {
      return;
    }
    let favoriteIds: string[] = await PreferencesUtil.getInstance().getFormIds(this.context);
    if (favoriteIds.includes(assetId)) {
      await PreferencesUtil.getInstance().removeFormId(this.context, assetId);
      isFavorite = false;
    } else {
      await PreferencesUtil.getInstance().addFormId(this.context, assetId);
      isFavorite = true;
    }
    AppStorage.setOrCreate('isFavorite', isFavorite);
    this.setFavoriteState(isFavorite);
  }

  public async getAndUpdateFavoriteState(assetId: string) {
    let isFavorite = false;
    if (!this.context) {
      return;
    }
    let favoriteListIds: string[] = await PreferencesUtil.getInstance().getFormIds(this.context);
    if (favoriteListIds.includes(assetId)) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    AppStorage.setOrCreate('isFavorite', isFavorite);
    this.setFavoriteState(isFavorite);
  }

  // [EndExclude set_favorite_state]
  public async setLoopModeState(AVSessionLoopMode: avSession.LoopMode) {
    if (this.AVSession) {
      this.AVSession.setAVPlaybackState({ loopMode: AVSessionLoopMode }, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
    }
  }

  // [End set_favorite_state]
  async unregisterSessionListener() {
    if (!this.AVSession) {
      return;
    }
    this.AVSession.off('play');
    this.AVSession.off('pause');
    this.AVSession.off('playNext');
    this.AVSession.off('playPrevious');
    this.AVSession.off('setLoopMode');
    this.AVSession.off('seek');
    this.AVSession.off('toggleFavorite');
  }
  // [EndExclude avsession_controller]
}
// [End avsession_controller]