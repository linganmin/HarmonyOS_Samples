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
import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import SongItemBuilder from './SongItemBuilder';
import { AudioPlayerState, MusicPlayMode } from '../../models/MusicData';
import { SongItem } from '../../models/SongItem';
import { BackgroundUtil } from './BackgroundUtil';
import { MediaTools } from './MediaTools';
import { Logger } from '../Logger';

const TAG = 'MediaService';

export class SongChangedData {
  isPlay: boolean = false;
  totalTime: string = '';
  progressMax: number = 0;
  selectIndex: number = 0;
  songItem: SongItem = new SongItem();
}

export class MediaService {
  private static instance: MediaService;
  private context: common.UIAbilityContext = AppStorage.get('context') as common.UIAbilityContext;
  public avPlayer?: media.AVPlayer;
  private session?: avSession.AVSession;
  private songItemBuilder: SongItemBuilder = new SongItemBuilder(this.context);
  private playMode: MusicPlayMode = MusicPlayMode.ORDER;
  private state: AudioPlayerState = AudioPlayerState.IDLE;
  private isFirstLoadAsset: boolean = true;
  private isPrepared: boolean = false;
  private musicIndex: number = 0;
  private songList: SongItem[] = [];
  private songChangedBack?: Function;
  private timeUpdateCallBack?: Function;
  private changedData: SongChangedData = new SongChangedData();
  private audioFileName?: string;
  private avPlayerSeekDoneCall = (seekDoneTime: number) => {
    Logger.info(TAG, `avPlayerSeekDoneCall seek succeeded, seek time is ${seekDoneTime}`);
    this.setAVSessionPlayState({
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime()
      }
    });
  };
  private avPlayerErrorCall = (error: BusinessError) => {
    Logger.error(TAG, `avPlayerErrorCall error, code is ${error.code}, message is ${error.message}`);
    this.reset();
  };
  private avPlayerTimeUpdateCall = (updateTime: number) => {
    if (this.timeUpdateCallBack) {
      this.timeUpdateCallBack(updateTime, MediaTools.msToCountdownTime(updateTime));
    }
  };
  private avPlayerStateChangeCall = async (state: string) => {
    switch (state) {
      case 'idle':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state idle called.');
        this.state = AudioPlayerState.IDLE;
        this.isPrepared = false;
        this.loadAsset();
        break;
      case 'initialized':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state initialized called.');
        this.state = AudioPlayerState.INITIALIZED;
        this.prepare();
        break;
      case 'prepared':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state prepared called.');
        this.state = AudioPlayerState.PREPARED;
        this.isPrepared = true;
        this.play();
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer prepared succeeded.');
        break;
      case 'playing':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state playing called.');
        if (this.isFirstLoadAsset) {
          BackgroundUtil.startContinuousTask(this.context);
          this.isFirstLoadAsset = false;
        }
        this.state = AudioPlayerState.PLAY;
        this.setCallBackData(true);
        this.updateSessionPlayState(true);
        break;
      case 'paused':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state paused called.');
        this.state = AudioPlayerState.PAUSE;
        this.setCallBackData(false);
        this.updateSessionPlayState(false);
        break;
      case 'completed':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state completed called.');
        this.state = AudioPlayerState.COMPLETED;
        this.playCompleteAuto();
        break;
      case 'stopped':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state stopped called.');
        this.state = AudioPlayerState.STOP;
        this.reset();
        break;
      case 'error':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state error called.');
        this.state = AudioPlayerState.ERROR;
        break;
      case 'released':
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state released called.');
        this.state = AudioPlayerState.RELEASED;
        break;
      default:
        Logger.info(TAG, 'avPlayerStateChangeCall AVPlayer state unknown called.');
        this.state = AudioPlayerState.UNKNOWN;
        break;
    }
  };
  private avSessionPlayCall = () => {
    Logger.info(TAG, `avSessionPlayCall on play , do play task`);
    this.play();
  };
  private avSessionPauseCall = () => {
    Logger.info(TAG, `avSessionPauseCall on pause , do pause task`);
    this.pause();
  };
  private avSessionPlayNextCall = () => {
    Logger.info(TAG, `avSessionPlayNextCall on playNext , do playNext task`);
    this.playNext();
  };
  private avSessionPlayPreviousCall = () => {
    Logger.info(TAG, `avSessionPlayPreviousCall on playPrevious , do playPrevious task`);
    this.playPrevious();
  };

  public getAudioFileName(): string {
    if (this.audioFileName) {
      return this.audioFileName;
    }
    return 'no audio playing';
  }

  public setOnPlayStateCall(callBak: Function): void {
    this.songChangedBack = callBak;
  }

  public setTimeUpdateCall(callBak: Function): void {
    this.timeUpdateCallBack = callBak;
  }

  private setCallBackData(isPlay: boolean): void {
    if (this.songChangedBack) {
      this.changedData.songItem = this.songList[this.musicIndex];
      this.changedData.isPlay = isPlay;
      this.changedData.selectIndex = this.musicIndex;
      this.changedData.totalTime = MediaTools.msToCountdownTime(this.getDuration());
      this.changedData.progressMax = this.getDuration();
      this.songChangedBack(this.changedData);
    }
  }

  public static getInstance(): MediaService {
    if (!MediaService.instance) {
      MediaService.instance = new MediaService();
    }
    return MediaService.instance;
  }

  public initAudioPlayer(audioName: string): void {
    Logger.info(TAG, `initAudioPlayer`);
    media.createAVPlayer().then(async avPlayer => {
      if (avPlayer) {
        this.audioFileName = audioName;
        this.avPlayer = avPlayer;
        this.loadAsset(audioName);
        this.setAVPlayerCallback();
        this.createSession();
        Logger.info(TAG, `initAudioPlayer success`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `initAudioPlayer error, code is ${error.code}, message is ${error.message}`);
    })
  }

  private setAVPlayerCallback(): void {
    if (this.avPlayer) {
      this.avPlayer.on('seekDone', this.avPlayerSeekDoneCall);
      this.avPlayer.on('error', this.avPlayerErrorCall);
      this.avPlayer.on('timeUpdate', this.avPlayerTimeUpdateCall);
      this.avPlayer.on('stateChange', this.avPlayerStateChangeCall)
    }
  }

  private async createSession(): Promise<void> {
    try {
      this.session = await avSession.createAVSession(this.context, 'SESSION_NAME', 'audio');
      this.session.activate()
        .then(() => {
          Logger.info(TAG, `activate succeed.`);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `activate failed. code=${error.code}, message=${error.message}`);
        })
      Logger.info(TAG, `session create done : sessionId : ${this.session.sessionId}`);
    } catch (err) {
    }
    this.setAVMetadata();
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
    }
    wantAgent.getWantAgent(wantAgentInfo)
      .then((agent) => {
        this.session?.setLaunchAbility(agent)
          .catch((error: BusinessError) => {
            Logger.error(TAG, `setLaunchAbility failed. code=${error.code}, message=${error.message}`);
          })
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `getWantAgent failed. code=${error.code}, message=${error.message}`);
      })
    this.setListenerForMesFromController();
  }

  private setListenerForMesFromController(): void {
    if (this.session) {
      try {
        this.session.on('play', this.avSessionPlayCall);
        this.session.on('pause', this.avSessionPauseCall);
        this.session.on('playNext', this.avSessionPlayNextCall);
        this.session.on('playPrevious', this.avSessionPlayPreviousCall);
      } catch (error) {
        Logger.error(TAG, `setListenerForMesFromController failed. code=${error.code}, message=${error.message}`);
      }
    }
  }

  private unregisterSessionListener(): void {
    if (this.session) {
      try {
        this.session.off('play');
        this.session.off('pause');
        this.session.off('playNext');
        this.session.off('playPrevious');
      } catch (error) {
        Logger.error(TAG, `unregisterSessionListener failed. code=${error.code}, message=${error.message}`);
      }
    }
  }

  private async setAVMetadata(): Promise<void> {
    try {
      let metadata: avSession.AVMetadata = {
        assetId: '01',
        title: 'Dream It Possible',
        artist: 'HarmonyOS',
        duration: this.getDuration()
      };
      this.session?.setAVMetadata(metadata).then(() => {
        Logger.info(TAG, 'SetAVMetadata successfully');
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `SetAVMetadata BusinessError: code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      Logger.error(TAG, `SetAVMetadata err, code: ${JSON.stringify(error)}`);
    }
  }

  public controlPlay(musicIndex: number): void {
    this.isFirstLoadAsset = false;
    this.playByIndex(musicIndex);
  }

  public setPlayModel(playMode: MusicPlayMode): void {
    this.playMode = playMode;
    Logger.info(TAG, 'setPlayModel mode: ' + this.playMode);
  }

  public seek(ms: number): void {
    if (this.isPrepared && this.state !== AudioPlayerState.ERROR && this.avPlayer) {
      let seekMode = this.getCurrentTime() < ms ? 0 : 1;
      let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
      this.avPlayer.seek(realTime, seekMode);
    }
  }

  public play(): void {
    if (!this.isPrepared) {
      this.prepare();
    } else {
      this.avPlayer?.play().then(() => {
        Logger.info(TAG, 'AVPlayer play successfully');
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `AVPlayer play failed, code is ${error.code}, message is ${error.message}`);
      })
    }
  }

  public pause(): void {
    if (this.isPrepared && this.state === AudioPlayerState.PLAY && this.avPlayer) {
      this.avPlayer.pause().then(() => {
        Logger.info(TAG, `AVPlayer pause successfully`);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `AVPlayer pause failed, code is ${error.code}, message is ${error.message}`);
      });
    }
  }

  public playNext(): void {
    this.isFirstLoadAsset = false;
    Logger.info(TAG, `playNext Index: ${this.musicIndex}, songList length: ${this.songList.length}`);
    switch (this.playMode) {
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      case MusicPlayMode.ORDER:
      case MusicPlayMode.SINGLE_CYCLE:
        if (this.musicIndex === this.songList.length - 1) {
          this.playByIndex(0);
        } else {
          this.playByIndex(this.musicIndex + 1);
        }
        break;
      default:
        break;
    }
  }

  public playPrevious(): void {
    this.isFirstLoadAsset = false;
    Logger.info(TAG, `playPrevious Index: ${this.musicIndex}, songList length: ${this.songList.length}`);
    switch (this.playMode) {
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      case MusicPlayMode.ORDER:
      case MusicPlayMode.SINGLE_CYCLE:
        if (this.musicIndex === 0) {
          this.playByIndex(this.songList.length - 1);
        } else {
          this.playByIndex(this.musicIndex - 1);
        }
        break;
      default:
        break;
    }
  }

  public async playByIndex(musicIndex: number): Promise<void> {
    if (musicIndex >= this.songList.length) {
      Logger.error(TAG, `playByIndex error, index is ${musicIndex} out of songList length ${this.songList.length}`);
      return;
    }
    this.updateMusicIndex(musicIndex);
    await this.stop();
  }

  public async release(): Promise<void> {
    if (this.avPlayer && this.session && this.context) {
      this.avPlayer.release()
        .catch((error: BusinessError) => {
          Logger.error(TAG, `release error, code=${error.code}, message=${error.message}`);
        })
      this.songItemBuilder.release();
      BackgroundUtil.stopContinuousTask(this.context);
      this.unregisterSessionListener();
      this.session.destroy()
        .catch((error: BusinessError) => {
          Logger.error(TAG, `destroy error, code=${error.code}, message=${error.message}`);
        })
    }
  }

  private async loadAsset(audioName?: string): Promise<void> {
    try {
      if (audioName && this.avPlayer) {
        let fileDescriptor = await this.context.resourceManager.getRawFd(audioName);
        let avFileDescriptor: media.AVFileDescriptor =
          { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
        this.avPlayer.fdSrc = avFileDescriptor;
        Logger.info(TAG, `loadAsset avPlayer url: ${this.avPlayer.fdSrc}}`);
      }
    } catch (e) {
      Logger.error(e.message);
    }
  }

  private updateSessionPlayState(isPlay: boolean): void {
    Logger.info(TAG, `updateIsPlay isPlay: ${isPlay}`);
    this.setAVSessionPlayState({
      state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime()
      }
    });
  }

  private getCurrentTime(): number {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.currentTime;
    }
    return 0;
  }

  private getDuration(): number {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.duration;
    }
    return 0;
  }

  private reset(): void {
    this.avPlayer?.reset().then(() => {
      Logger.info(TAG, 'AVPlayer reset successfully');
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `AVPlayer reset failed, code is ${error.code}, message is ${error.message}`);
    });
  }

  private prepare() {
    this.avPlayer?.prepare().then(() => {
      Logger.info(TAG, 'AVPlayer prepare successfully');
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `AVPlayer prepare failed, code is ${error.code}, message is ${error.message}`);
    });
  }

  private playCompleteAuto(): void {
    switch (this.playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        this.play();
        break;
      case MusicPlayMode.ORDER:
        this.playNext();
        break;
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      default:
        break;
    }
  }

  private playRandom(): void {
    let num = Math.round(Math.random() * (this.songList.length - 1));
    if (this.musicIndex === num) {
      this.playRandom();
    } else {
      this.playByIndex(num);
    }
  }

  private async stop(): Promise<void> {
    if (this.isPrepared && this.avPlayer) {
      this.state = AudioPlayerState.PAUSE;
      this.avPlayer.stop().then(() => {
        Logger.info(TAG, 'AVPlayer stop succeeded.');
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `AVPlayer stop failed, code is ${error.code}, message is ${error.message}`);
      });
    }
  }

  private updateMusicIndex(musicIndex: number): void {
    Logger.info(TAG, `updateMusicIndex: ${musicIndex}`);
    if (this.musicIndex !== musicIndex) {
      this.musicIndex = musicIndex;
    }
  }

  private setAVSessionPlayState(playbackState: avSession.AVPlaybackState): void {
    this.session?.setAVPlaybackState(playbackState).then(() => {
      Logger.info(TAG, 'SetAVPlaybackState successfully');
    }).catch((error: BusinessError) => {
      Logger.info(TAG, `SetAVPlaybackState BusinessError: code: ${error.code}, message: ${error.message}`);
    });
  }
}