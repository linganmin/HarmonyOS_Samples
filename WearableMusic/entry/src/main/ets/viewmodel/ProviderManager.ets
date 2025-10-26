/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { wantAgent, common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { audio } from '@kit.AudioKit';
import { avSession } from '@kit.AVSessionKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { media } from '@kit.MediaKit';
import Constants, { AVPlayerState } from '../common/Constants';
import GlobalContext from '../utils/GlobalContextUtils';
import MediaPlayerUtils from '../utils/MediaPlayerUtils';
import Logger from '../utils/Logger';
import MediaData from '../model/MediaData';

const TAG = 'ProviderFeature';

export class ProviderFeature {
  private static providerSelf: ProviderFeature | undefined = undefined;
  private context: common.UIAbilityContext | undefined =
    GlobalContext.getContext().getObject(Constants.CONTEXT) as common.UIAbilityContext;
  private constants = new MediaData();
  private session: avSession.AVSession | null = null;
  private isPlayLink: SubscribedAbstractProperty<boolean> | null = null;
  private currentPlayItemLink: SubscribedAbstractProperty<avSession.AVQueueItem> | undefined = undefined;
  private currentLoopModeLink: SubscribedAbstractProperty<avSession.LoopMode> | undefined = undefined;
  private seekPositionLink: SubscribedAbstractProperty<number> | undefined = undefined;
  private currentAVMetadataLink: SubscribedAbstractProperty<avSession.AVMetadata> | undefined = undefined;
  private currentImageLink: SubscribedAbstractProperty<PixelMap> | undefined = undefined;
  private queueItems: Array<avSession.AVQueueItem> =
    [this.constants.queueItemFirst, this.constants.queueItemSecond, this.constants.queueItemThird];
  private queueItemPixelMapArray: Array<PixelMap> = [];
  private MetadataPixelMapArray: Array<PixelMap> = [];
  private resourceManager: resourceManager.ResourceManager = this.context!.resourceManager;
  private avMetadataList: Array<avSession.AVMetadata> =
    [this.constants.avMetadataFirst, this.constants.avMetadataSecond, this.constants.avMetadataThird];
  private currentState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE
  };
  private constantsForControl: MediaData = new MediaData();
  private mediaPlayerUtil: MediaPlayerUtils = new MediaPlayerUtils();
  private avPlayer?: media.AVPlayer;
  private currentTime: number = 0;
  private isFavorMapLink: SubscribedAbstractProperty<Map<String, boolean>> | undefined = undefined;
  private playListAssetIdMap: Map<string, number> = new Map();

  static async getInstance(): Promise<ProviderFeature> {
    Logger.info(TAG, ' provider getInstance');
    if (!ProviderFeature.providerSelf) {
      Logger.info(TAG, ' new provider');
      ProviderFeature.providerSelf = new ProviderFeature();
      await ProviderFeature.providerSelf.init();
    }
    return ProviderFeature.providerSelf;
  }

  private constructor() {
    this.isPlayLink = AppStorage.setAndLink('IsPlaying', false);
    this.currentPlayItemLink =
      AppStorage.setAndLink<avSession.AVQueueItem>('CurrentPlayItem', {} as avSession.AVQueueItem);
    this.currentAVMetadataLink =
      AppStorage.setAndLink<avSession.AVMetadata>('CurrentAVMetadata', {} as avSession.AVMetadata);
    this.isFavorMapLink = AppStorage.setAndLink<Map<String, boolean>>('isFavorMap', new Map());
    this.currentImageLink = AppStorage.setAndLink<PixelMap>('CurrentImage', {} as PixelMap);
    this.currentLoopModeLink =
      AppStorage.setAndLink<avSession.LoopMode>('CurrentLoopMode', avSession.LoopMode.LOOP_MODE_SEQUENCE);
    this.seekPositionLink = AppStorage.setAndLink<number>('SeekPosition', 0);
    this.currentAVMetadataLink!.set(this.avMetadataList[0]);
    this.currentLoopModeLink!.set(avSession.LoopMode.LOOP_MODE_SEQUENCE);

    let map: Map<String, boolean> = new Map();
    map.set(this.avMetadataList[0].assetId, false);
    map.set(this.avMetadataList[1].assetId, false);
    map.set(this.avMetadataList[2].assetId, false);
    this.isFavorMapLink!.set(map);

    this.playListAssetIdMap.set(Constants.ENTITY_ID_FIRST_PLAY_LIST, 0);
    this.playListAssetIdMap.set(Constants.ENTITY_ID_SECOND_PLAY_LIST, 1);
    this.playListAssetIdMap.set(Constants.ENTITY_ID_THIRD_PLAY_LIST, 2);
  }

  /**
   * Initialize resources.
   */
  async init(): Promise<void> {
    this.avPlayer = await this.mediaPlayerUtil.init();
    await this.prepareImageResources();
    await this.prepareResourcesForController();
    await this.CreateAVSession();
    await this.InitFirstMusicState();
    await this.RegisterAVPlayerListener();
  }

  async unInit(): Promise<void> {
    this.UnRegisterListener();
    if (this.avPlayer) {
      this.unRegisterAVPlayerListener();
      this.avPlayer.release();
    }
  }

  /**
   * Start a long-time task.
   */
  async startContinuousTask(): Promise<void> {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: Constants.BUNDLE_NAME,
          abilityName: Constants.ABILITY_NAME
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    let tmpWantAgent = await wantAgent.getWantAgent(wantAgentInfo);
    // Sets the application page that can be invoked when a playback control card is clicked.
    this.session?.setLaunchAbility(tmpWantAgent);
    await backgroundTaskManager.startBackgroundRunning(this.context,
      backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, tmpWantAgent);
  }

  /**
   * Close a long-time task.
   */
  async stopContinuousTask(): Promise<boolean> {
    Logger.info(TAG, 'stop background ');
    return new Promise((resolve) => {
      backgroundTaskManager.stopBackgroundRunning(this.context, (err, _) => {
        if (err) {
          Logger.error(TAG, `stop background startBackgroundRunning err ${err.stack}`);
          resolve(false);
        } else {
          Logger.info(TAG, `stop background startBackgroundRunning success`);
          resolve(true);
        }
      });
    });
  }

  /**
   * Create AVSession.
   */
  async CreateAVSession(): Promise<boolean> {
    Logger.info(TAG, `Start create AVSession`);
    let ret: boolean = true;
    if (this.session) {
      Logger.info(TAG, `has a session: ` + this.session.sessionId);
      return ret;
    }
    // Create an audio session. The Favorites, Previous, Pause, and Repeat buttons are displayed on the playback control page.
    // A developer can also create a session of the video type. The playback control page displays the fast-forward, rewind, and pause buttons.
    this.session = await avSession.createAVSession(this.context!, 'AVSessionDemo', 'audio');
    // Activate the session.
    this.RegisterSessionListener();
    await this.session?.activate().catch((err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `Failed to activate AVSession, error info: ${JSON.stringify(err)}`);
        ret = false;
      }
    });
    return ret;
  }

  async InitFirstMusicState(): Promise<void> {
    Logger.info(TAG, ` InitFirstMusicState`);
    await this.mediaPlayerUtil.loadFromRawFile(Constants.MUSIC_FILE_NAME[0]);
    this.isPlayLink!.set(false);
    this.currentImageLink!.set(this.queueItemPixelMapArray[0]);
    this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
    await this.session?.setAVPlaybackState(this.currentState);
    await this.setAVMetadataToController(0);
    this.currentPlayItemLink!.set(this.queueItems![0]);
    this.currentAVMetadataLink!.set(this.avMetadataList[0]);
  }

  /**
   * Registers the session callback function.
   * Register the command as required. If the command is not supported, do not register it.
   * For the session of the audio type, implement the progress bar, favorites, next song, play/pause, and loop mode callback functions. If the functions are not supported, disable the interface or do not register the interface.
   * For a session of the video type, implement the fast-forward, rewind, next episode, and playback pause callback functions. If the functions are not supported, disable the interface or do not register the interface.
   */
  async RegisterSessionListener(): Promise<void> {
    // Processes playback commands.
    this.session?.on('play', async () => {
      Logger.info(TAG, `on play, do play task`);
      this.avPlayer?.play();
      this.isPlayLink!.set(true);
      this.currentState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        position: {
          elapsedTime: this.currentTime,
          updateTime: new Date().getTime(),
        }
      };
      await this.session?.setAVPlaybackState(this.currentState);
    });

    // Suspend instruction processing.
    this.session?.on('pause', async () => {
      Logger.info(TAG, `on pause, do pause task`);
      this.avPlayer?.pause();
      this.isPlayLink!.set(false);
      this.currentState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: this.currentTime,
          updateTime: new Date().getTime(),
        }
      };
      await this.session?.setAVPlaybackState(this.currentState);
    });

    // Stop instruction processing.
    this.session?.on('stop', async () => {
      Logger.info(TAG, `on stop , do stop task`);
      this.avPlayer?.stop();
      this.isPlayLink!.set(false);
      this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
      await this.session?.setAVPlaybackState(this.currentState);
    });

    // Next song/set instruction processing.
    this.session?.on('playNext', async () => {
      Logger.info(TAG, `on playNext , do playNext task`);
      let nextId: number = this.currentPlayItemLink!.get().itemId + 1;
      nextId = this.queueItems!.length > nextId ? nextId : nextId - this.queueItems!.length;
      await this.handleNewItem(nextId);
    });

    // Previous song/set instruction processing.
    this.session?.on('playPrevious', async () => {
      Logger.info(TAG, `on playPrevious , do playPrevious task`);
      let previousId: number = this.currentPlayItemLink!.get().itemId - 1;
      previousId = previousId < 0 ? previousId + this.queueItems!.length : previousId;
      await this.handleNewItem(previousId);
    });

    // Processes the progress bar dragging command.
    this.session?.on('seek', (position) => {
      Logger.info(TAG, 'on seek: seek to' + position);
      // Modify the playback progress based on the instruction.
      if (position >= this.currentAVMetadataLink!.get().duration!) {
        this.next();
      } else {
        this.avPlayer?.seek(position);
        this.currentState.position = {
          elapsedTime: position,
          updateTime: new Date().getTime()
        };
        this.session?.setAVPlaybackState(this.currentState);
      }
    });

    // Processes the favorite/like command for the audio session.
    this.session?.on('toggleFavorite', (assetId) => {
      // If a system callback message is received, the user clicks the favorites button when playing the song.
      // The app stores the favorites status based on the song ID and reports the current favorites status.
      Logger.info(TAG, 'on toggleFavorite session, do toggleFavorite task: ' + assetId);
      this.isFavorMapLink!.get().set(assetId, !this.isFavorMapLink!.get().get(assetId));
      this.currentState.isFavorite = this.isFavorMapLink!.get().get(assetId);
      this.session?.setAVPlaybackState(this.currentState);
    });

    // Cyclic mode instruction processing for audio session.
    this.session?.on('setLoopMode', (mode) => {
      Logger.info(TAG, 'on setLoopMode: ' + mode);
      // The value transferred by the playback control is not processed.
      // The value is switched based on the application sequence.
      let currentMode = this.currentLoopModeLink!.get();
      this.currentLoopModeLink!.set(currentMode === 3 ? 0 : currentMode + 1);
      // The playback status is updated. The cyclic mode after application processing is reported in the playback status.
      this.currentState.loopMode = this.currentLoopModeLink!.get();
      Logger.info(TAG, 'self setLoopMode: ' + this.currentState.loopMode);
      this.session?.setAVPlaybackState(this.currentState);
    });

    // Fast-forward command processing for video sessions.
    this.session?.on('fastForward', (skipInterval?: number) => {
      let currentTime: number =
        (skipInterval! * 1000 + this.avPlayer!.currentTime) > this.currentAVMetadataLink!.get().duration! ?
          this.currentAVMetadataLink!.get().duration! : (skipInterval! * 1000 + this.avPlayer!.currentTime);
      if (currentTime >= this.currentAVMetadataLink!.get().duration!) {
        this.next();
      } else {
        this.avPlayer?.seek(currentTime);
        this.currentState.position = {
          elapsedTime: currentTime,
          updateTime: new Date().getTime()
        };
        this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
        this.session?.setAVPlaybackState(this.currentState);
      }
    });

    // Rewind command processing, for video session.
    this.session?.on('rewind', (skipInterval?: number) => {
      let currentTime: number = (this.avPlayer!.currentTime - skipInterval! * 1000) <= 0 ?
        0 : (this.avPlayer!.currentTime - skipInterval! * 1000);
      this.avPlayer?.seek(skipInterval);
      Logger.info(TAG, ' currentTime' + JSON.stringify(currentTime));
      if (currentTime <= 0) {
        this.previous();
      } else {
        this.avPlayer?.seek(currentTime);
        this.currentState.position = {
          elapsedTime: currentTime,
          updateTime: new Date().getTime()
        };
        this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
        this.session?.setAVPlaybackState(this.currentState);
      }
    });
  }

  /**
   * Deregister a session callback.
   */
  async UnRegisterListener(): Promise<void> {
    if (this.session) {
      this.session.off('play');
      this.session.off('pause');
      this.session.off('stop');
      this.session.off('playNext');
      this.session.off('playPrevious');
      this.session.off('fastForward');
      this.session.off('rewind');
      this.session.off('seek');
      this.session.off('setLoopMode');
      this.session.off('toggleFavorite');

      // Destroys a created session.
      this.session.destroy((err) => {
        if (err) {
          Logger.info(TAG, `Destroy BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'Destroy : SUCCESS');
        }
      });
    }
  }

  /**
   * Processing logic of the avplayer when the playback is paused.
   */
  async localPlayOrPause(): Promise<void> {
    Logger.info(TAG, 'localPlayOrPause start play' + this.avPlayer?.state);
    if (!this.avPlayer) {
      Logger.error(TAG, 'localPlayOrPause start play no avplayer');
      return;
    }
    if (this.avPlayer.state === AVPlayerState.PLAYING) {
      Logger.info(TAG, 'localPlayOrPause start play start pause');
      await this.avPlayer.pause();
      this.isPlayLink!.set(false);
    } else if (this.avPlayer.state === AVPlayerState.STOPPED) {
      Logger.info(TAG, 'localPlayOrPause start play from stopped');
      await this.avPlayer.prepare();
      await this.avPlayer.play();
      this.isPlayLink!.set(true);
    } else {
      Logger.info(TAG, 'localPlayOrPause start play');
      await this.avPlayer.play();
      this.isPlayLink!.set(true);
      Logger.info(TAG, 'localPlayOrPause start play done');
    }
    Logger.info(TAG, 'localPlayOrPause isPlay: ' + this.isPlayLink!.get());
  }

  /**
   * Set AVMetadata.
   */
  async setAVMetadataToController(itemId: number): Promise<void> {
    let avMetadata: avSession.AVMetadata = this.constantsForControl.avMetadataList[itemId];
    Logger.info(TAG, `setAVMetadataToController avMetadata: ` + JSON.stringify(avMetadata));
    await this.session?.setAVMetadata(avMetadata);
  }

  /**
   * In-app favorites button.
   */
  async toggleFavorite(): Promise<void> {
    this.isFavorMapLink!.get()
      .set(this.currentAVMetadataLink!.get().assetId,
        !this.isFavorMapLink!.get().get(this.currentAVMetadataLink!.get().assetId));
    this.currentState.isFavorite = this.isFavorMapLink!.get().get(this.currentAVMetadataLink!.get().assetId);
    Logger.info(TAG, ` Start do toggleFavorite task state isFavorite: ` + this.currentState.isFavorite);
    this.session?.setAVPlaybackState(this.currentState);
  }

  /**
   * In-app circulation mode.
   */
  async loopMode(): Promise<void> {
    let currentMode = this.currentLoopModeLink!.get();
    Logger.info(TAG, 'do setLooMode old: ' + currentMode);
    this.currentLoopModeLink!.set(currentMode === Constants.MAX_LOOP_MODE_COUNT ? 0 : ++currentMode);
    this.currentState.loopMode = this.currentLoopModeLink!.get();
    Logger.info(TAG, 'do setLooMode new: ' + this.currentState.loopMode);
    this.session?.setAVPlaybackState(this.currentState);
  }

  /**
   * Updates the playback status.
   */
  async play(): Promise<void> {
    Logger.info(TAG, `Start do play task`);
    await this.localPlayOrPause();
    let isFavor: boolean | undefined = this.isFavorMapLink!.get().get(this.currentAVMetadataLink!.get().assetId);
    Logger.info(TAG, `currentState assetId ` + this.currentAVMetadataLink!.get().assetId);
    Logger.info(TAG, `currentState isPlay ` + this.isPlayLink!.get());
    this.currentState = {
      state: this.isPlayLink!.get() ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime,
        updateTime: new Date().getTime()
      },
      isFavorite: isFavor
    };
    Logger.info(TAG, `currentState` + JSON.stringify(this.currentState));
    await this.session?.setAVPlaybackState(this.currentState);
  }

  /**
   * In-app pause button.
   */
  async pause(): Promise<void> {
    Logger.info(TAG, `on pause , do pause task`);
    await this.localPlayOrPause();
    let isFavor: boolean | undefined = this.isFavorMapLink!.get().get(this.currentAVMetadataLink!.get().assetId);
    Logger.info(TAG, `currentState assetId ` + this.currentAVMetadataLink!.get().assetId);
    Logger.info(TAG, `currentState isPlay ` + this.isPlayLink!.get());
    this.currentState = {
      state: this.isPlayLink!.get() ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime,
        updateTime: new Date().getTime()
      },
      isFavorite: isFavor
    };
    Logger.info(TAG, `currentState` + JSON.stringify(this.currentState));
    await this.session?.setAVPlaybackState(this.currentState);
  }

  /**
   * In-app previous song button.
   */
  async previous(): Promise<void> {
    Logger.info(TAG, `on playPrevious , do playPrevious task`);
    let previousId: number = this.currentPlayItemLink!.get().itemId - 1;
    previousId = previousId < 0 ? previousId + this.queueItems!.length : previousId;
    await this.handleNewItem(previousId);
  }

  /**
   * In-app next song button.
   */
  async next(): Promise<void> {
    Logger.info(TAG, `on playNext , do playNext task`);
    let nextId: number = this.currentPlayItemLink!.get().itemId + 1;
    nextId = this.queueItems!.length > nextId ? nextId : nextId - this.queueItems!.length;
    await this.handleNewItem(nextId);
  }

  /**
   * Processes the previous/next command.
   */
  async handleNewItem(itemId: number): Promise<void> {
    Logger.info(TAG, ' handleNewItem itemId: ' + itemId);
    this.currentImageLink!.set(this.queueItemPixelMapArray[itemId]);
    await this.setAVMetadataToController(itemId);
    this.currentPlayItemLink!.set(this.queueItems![itemId]);
    this.currentAVMetadataLink!.set(this.avMetadataList[this.currentPlayItemLink!.get().itemId]);
    await this.mediaPlayerUtil.loadFromRawFile(Constants.MUSIC_FILE_NAME[itemId]);
    // The avplayer is ready to play.
    this.mediaPlayerUtil.on('prepared', () => {
      Logger.info(TAG, 'AVPlayer state prepared, start play');
      this.handleNewItemAVPlayback();
    });
    this.mediaPlayerUtil.on('paused', () => {
      this.isPlayLink?.set(false);
    })
    this.mediaPlayerUtil.on('completed', () => {
      this.isPlayLink?.set(false);
    })
  }

  async handleNewItemAVPlayback(): Promise<void> {
    await this.localPlayOrPause();
    let isFavor: boolean | undefined = this.isFavorMapLink!.get().get(this.currentAVMetadataLink!.get().assetId);
    Logger.info(`currentState assetId ` + this.currentAVMetadataLink!.get().assetId);
    Logger.info(`currentState isFavor ` + isFavor);
    this.currentState = {
      state: this.isPlayLink!.get() ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime,
        updateTime: new Date().getTime()
      },
      isFavorite: isFavor
    };
    Logger.info(`currentState` + JSON.stringify(this.currentState));
    await this.session?.setAVPlaybackState(this.currentState);
  }

  /**
   * Processes the playback of historical playlists.
   */
  async handleNewPlayListItem(avQueueId: string): Promise<void> {
    let assetId: number = this.playListAssetIdMap.get(avQueueId)!;
    await this.handleNewItem(assetId);
  }

  /**
   * Prepare media resources.
   */
  async prepareImageResources(): Promise<void> {
    Logger.info(TAG, `prepareImageResources in`);
    this.queueItemPixelMapArray.push(await this.saveRawFileToPixelMap('first.png'));
    this.queueItemPixelMapArray.push(await this.saveRawFileToPixelMap('second.png'));
    this.queueItemPixelMapArray.push(await this.saveRawFileToPixelMap('third.png'));
    this.MetadataPixelMapArray.push(await this.saveRawFileToPixelMap('first_with_background.png'));
    this.MetadataPixelMapArray.push(await this.saveRawFileToPixelMap('second_with_background.png'));
    this.MetadataPixelMapArray.push(await this.saveRawFileToPixelMap('third_with_background.png'));
    for (let i = 0; i < this.queueItemPixelMapArray.length; i++) {
      this.queueItems[i].description!.mediaImage = this.queueItemPixelMapArray[i];
      this.avMetadataList[i].mediaImage = this.MetadataPixelMapArray[i];
      this.avMetadataList[i].avQueueImage = this.queueItemPixelMapArray[i];
    }
    this.currentPlayItemLink!.set(this.queueItems![0]);
    this.currentImageLink!.set(this.queueItemPixelMapArray[0]);
    this.currentAVMetadataLink!.set(this.avMetadataList[0]);
  }

  async saveRawFileToPixelMap(rawFilePath: string): Promise<image.PixelMap> {
    let value: Uint8Array = await this.resourceManager.getRawFileContent(rawFilePath);
    let imageBuffer: ArrayBuffer = value.buffer as ArrayBuffer;
    let imageSource: image.ImageSource = image.createImageSource(imageBuffer);
    let imagePixel: image.PixelMap = await imageSource.createPixelMap({
      desiredSize: {
        width: Constants.IMAGE_PIXEL_MAP_WIDTH,
        height: Constants.IMAGE_PIXEL_MAP_WIDTH
      }
    });
    return imagePixel;
  }

  async prepareResourcesForController(): Promise<void> {
    Logger.info(TAG, `prepareResourcesForController in`);
    this.constantsForControl.avMetadataList[0].mediaImage = await this.saveRawFileToPixelMap('first.png');
    this.constantsForControl.avMetadataList[0].avQueueImage = await this.saveRawFileToPixelMap('first.png');
    this.constantsForControl.avMetadataList[1].mediaImage = await this.saveRawFileToPixelMap('second.png');
    this.constantsForControl.avMetadataList[1].avQueueImage = await this.saveRawFileToPixelMap('second.png');
    this.constantsForControl.avMetadataList[2].mediaImage = await this.saveRawFileToPixelMap('third.png');
    this.constantsForControl.avMetadataList[2].avQueueImage = await this.saveRawFileToPixelMap('third.png');
  }

  /**
   * Registers the avplayer event listener.
   */
  async RegisterAVPlayerListener(): Promise<void> {
    // Registers focus interrupt listening.
    Logger.info(TAG, ` RegisterAVPlayerListener`);
    this.avPlayer?.on('audioInterrupt', (info: audio.InterruptEvent) => {
      Logger.info(TAG, 'audioInterrupt success,and InterruptEvent info is:' + info);
      if (this.avPlayer?.state === AVPlayerState.PLAYING) {
        Logger.info(TAG, 'audio interrupt, start pause');
        this.avPlayer?.pause();
        this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
        this.session?.setAVPlaybackState(this.currentState);
      }
    });
    // Registers the playback time change callback function.
    this.avPlayer?.on('timeUpdate', (time: number) => {
      // The function of obtaining the current location globally is added.
      this.currentTime = time;
      Logger.info(TAG, 'time update progress:' + time);
      this.seekPositionLink!.set(time / this.currentAVMetadataLink!.get().duration! * 100);
    });
  }

  /**
   * UnRegister the event listener for the avplayer.
   */
  async unRegisterAVPlayerListener(): Promise<void> {
    Logger.info(TAG, ` unRegisterAVPlayerListener`);
    // UnRegister the listening of focus interrupt.
    this.avPlayer?.off('audioInterrupt');
    // UnRegister the playback time change callback function.
    this.avPlayer?.off('timeUpdate');
    this.avPlayer?.off('stateChange');
    this.avPlayer?.off('seekDone');
    this.avPlayer?.off('error');
  }
}