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
import { audio } from '@kit.AudioKit';
import { resourceManager } from '@kit.LocalizationKit';
import { MediaTools } from './MediaTools';
import { SongItem } from '../songdatacontroller/SongData';
import { Logger } from './Logger';
import { AudioRendererController } from './AudioRendererController';
import { SONG_LIST } from '../songdatacontroller/SongListData';

const TAG = 'AVSessionController';

export class AVSessionController {
  private context: common.UIAbilityContext | undefined = undefined;
  private AVSession: avSession.AVSession | undefined = undefined;
  private songList: SongItem[] = SONG_LIST;
  private musicIndex: number | undefined = undefined;
  private audioRendererController: AudioRendererController | undefined = undefined;

  constructor() {
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


  private async initAVSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      Logger.info(TAG, `session create failed : conext is undefined`);
      return;
    }
    let currentAudioStreamUsage: audio.StreamUsage | undefined = AppStorage.get('currentAudioStreamUsage');
    if (!currentAudioStreamUsage) {
      Logger.error(TAG, 'currentAudioStreamUsage is undefined');
      return;
    }
    let audioRendererControllerMap:
    Map<audio.StreamUsage, AudioRendererController> | undefined = AppStorage.get('audioRendererControllerMap');
    if (!audioRendererControllerMap) {
      Logger.error(TAG, 'audioRendererControllerMap is undefined');
      return;
    }
    this.audioRendererController = audioRendererControllerMap.get(currentAudioStreamUsage);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined');
      return;
    }
    this.AVSession = await avSession.createAVSession(this.context, 'PLAY_AUDIO', 'audio');
    await this.AVSession.activate();
    Logger.info(TAG, `session create successed : sessionId : ${this.AVSession.sessionId}`);
    this.setLaunchAbility();
    this.setListenerForMesFromController();

  }

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

  private getFirst(): boolean | undefined {
    if (!this.audioRendererController) {
      return;
    }
    return this.audioRendererController.getFirst();
  }

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
        let metadata: avSession.AVMetadata = {
          assetId: `${this.musicIndex}`,
          title: this.songList[this.musicIndex].title,
          artist: this.songList[this.musicIndex].singer,
          mediaImage: mediaImage,
        };
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

  async setListenerForMesFromController() {
    if (!this.AVSession) {
      return;
    }
    this.AVSession.on('play', this.playCall);
    this.AVSession.on('pause', this.pauseCall);
  }

  private playCall: () => void = () => {
    Logger.info(TAG, `on play , do play task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in playCall');
      return;
    }
    if (this.getFirst()) {
      this.audioRendererController.play();
    } else {
      this.audioRendererController.start();
    }
  };
  private pauseCall: () => void = () => {
    Logger.info(TAG, `on pause , do pause task`);
    if (!this.audioRendererController) {
      Logger.error(TAG, 'audioRendererController is undefined in pauseCall');
      return;
    }
    this.audioRendererController.pause();
  };

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

  async unregisterSessionListener() {
    if (!this.AVSession) {
      return;
    }
    this.AVSession.off('play');
    this.AVSession.off('pause');
    AppStorage.setOrCreate<AVSessionController>('AVSessionController', undefined);
  }
}