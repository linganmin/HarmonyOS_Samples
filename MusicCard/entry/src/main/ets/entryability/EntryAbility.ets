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

import { AbilityConstant, Context, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { rpc } from '@kit.IPCKit';
import { MediaService, SongChangedData } from '../utils/MediaService';
import { getSongListData } from '../viewmodel/SongListData';
import { PreferencesUtil } from '../database/PreferencesUtil';
import FormUtils from '../utils/FormUtils';
import { Logger } from '../utils/Logger';
import { CollectAction, PlayActionType, RouterType } from '../widget/model/FormCardConstant';
import WindowUtils from '../utils/WindowUtils';
import { SongRdbHelper } from '../database/SongRdbHelper';
import { SongItem } from '../viewmodel/SongItem';
import { LrcEntry } from '../lyric/LrcEntry';
import { parseLrcLyric } from '../lyric/LrcUtils';
import { util } from '@kit.ArkTS';
import { BackgroundUtil } from '../utils/BackgroundUtil';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'EntryAbility';
let context: Context;

let isInitSuccess = false;

// [Start entryability]
// [Start dynamic_lyrics_call_on]
// [Start is_need_request_update_call_update]
// [Start music_control_card_call_on]
// [Start music_control_card_play_state_call]
// [Start music_control_card_release_state]
// [Start music_control_card_collect_call_on]
// [Start music_control_card_pull_pages]
// [Start music_recommended_card_jump_card]
// src/main/ets/entryability/EntryAbility.ets
export default class EntryAbility extends UIAbility {
  // [StartExclude music_recommended_card_jump_card]
  // [StartExclude music_control_card_pull_pages]
  // [StartExclude music_control_card_collect_call_on]
  // [StartExclude is_need_request_update_call_update]
  // [StartExclude music_control_card_play_state_call]
  // [StartExclude handle_params]
  // [StartExclude music_control_card_release_state]
  playByActionCall = (data: rpc.MessageSequence) => {
    try {
      let params: Record<string, string> = JSON.parse(data.readString());
      Logger.info(TAG, `playByActionCall playActionType:${params.playActionType}`);
      if (params.playActionType) {
        let playActionType: PlayActionType = params.playActionType as PlayActionType;
        if (isInitSuccess) {
          MediaService.getInstance().playByAction(playActionType);
        } else {
          this.initSongData().then(() => {
            MediaService.getInstance().playByAction(playActionType);
          });
        }
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `playByActionCall err, code: ${error.code}, mesage: ${error.message}`);
    }
    return null;
  };
  // [EndExclude music_control_card_collect_call_on]

  // [StartExclude dynamic_lyrics_call_on]
  // [Start collect_action_call]
  // [StartExclude music_control_card_call_on]
  collectActionCall = (data: rpc.MessageSequence) => {
    try {
      let params: Record<string, string> = JSON.parse(data.readString());
      if (params.collectActionType) {
        let songRdbHelper = SongRdbHelper.getInstance(context);
        if (params.collectActionType === CollectAction.COLLECTED) {
          songRdbHelper.updateCollected(params.songId, CollectAction.COLLECTED);
          FormUtils.updateCardCollectStatus(context, true);
          context.eventHub.emit('collected', params.songId, CollectAction.COLLECTED);
        } else {
          songRdbHelper.updateCollected(params.songId, CollectAction.UNCOLLECTED);
          FormUtils.updateCardCollectStatus(context, false);
          context.eventHub.emit('collected', params.songId, CollectAction.UNCOLLECTED);
        }
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `collectActionCall err, code: ${error.code}, mesage: ${error.message}`);
    }
    return null;
  };
  // [End collect_action_call]
  // [StartExclude music_control_card_collect_call_on]

  // [Start request_updateplaycard]
  // [Start dynamic_lyrics_entry_ability_request_update_playcard]
  // [EndExclude is_need_request_update_call_update]
  requestUpdatePlayCard = (data: rpc.MessageSequence) => {
    try {
      Logger.info(TAG, 'requestUpdatePlayCard');
      let params: Record<string, string> = JSON.parse(data.readString());
      let formId = params.formId;
      if (formId) {
        FormUtils.updateMusicControlSingle(context, formId);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `requestUpdatePlayCard err, code: ${error.code}, mesage: ${error.message}`);
    }
    return null;
  };
  // [End request_updateplaycard]
  // [End dynamic_lyrics_entry_ability_request_update_playcard]
  // [StartExclude is_need_request_update_call_update]
  async initSongData() {
    Logger.info(TAG, 'initSongData');
    let songRdbHelper = SongRdbHelper.getInstance(this.context);
    let initSongs = getSongListData(this.context);
    songRdbHelper.insertSongs(initSongs);
    AppStorage.setOrCreate('songList', initSongs);

    let currentSong = await PreferencesUtil.getInstance().getCurrentSong(context);
    if (!currentSong) {
      currentSong = initSongs[0];
      PreferencesUtil.getInstance().putCurrentSong(context, currentSong);
    }
    AppStorage.setOrCreate('currentSong', currentSong);

    MediaService.getInstance().initAudioPlayer(initSongs, currentSong);
    let collectedSongList = await songRdbHelper.queryCollectedSongs();
    AppStorage.setOrCreate('collectedSongList', collectedSongList);
    isInitSuccess = true;
  }

  mLrcEntryList: Array<LrcEntry> = [];

  // [Start get_lrc_entry_list]
  // Get the list of lyrics for the current song
  async getLrcEntryList(currentSong: SongItem): Promise<void> {
    this.mLrcEntryList = [];
    if (!this.context) {
      return;
    }
    try {
      const value = await this.context.resourceManager.getRawFileContent(currentSong.lyric);
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true }); // Create a UTF-8 encoded text decoder
      const stringData = textDecoder.decodeToString(value, { stream: false }); // Convert Uint8Array to a string
      this.mLrcEntryList = parseLrcLyric(stringData); // If the lyrics file ends in LRC, parse the LRC lyrics
    } catch (error) {
      Logger.error(TAG, `Failed to load lyric: ${error}`);
    }
  }

  // [End get_lrc_entry_list]
  /**
   * This function is used to search for the lyric index corresponding to the current playback progress in the lyric
   * list. It uses binary search algorithm combined with time adjustment to quickly locate the currently playing lyrics.
   * @param progress The current playback progress, measured in milliseconds.
   * @param lrcList Lyrics list, each element is an object containing lyrics time and content
   * @returns Return the lyric index corresponding to the current playback progress. If no matching lyric is found,
   * return -1
   */
  // [Start dynamic_lyrics_get_near_lyric]
  findCurrentLyricIndex(progress: number, lrcList: Array<LrcEntry>) {
    // Initialize binary search boundaries
    let low = 0; // Left boundary of search range
    let high = lrcList.length - 1; // Right boundary of search range
    let result = -1; // Final matching result
    const ANIMATION_TIME = 200;

    // Match 200ms in advance, the time is the animation time for switching lyrics components,
    // which can be replaced or changed
    const adjustedProgress = progress + ANIMATION_TIME;

    while (low <= high) {
      const mid = (low + high) >> 1; // Calculate mid index (bitwise operation is faster than Math.floor)
      const currentLine = lrcList[mid]; // Current lyric line being checked

      // Check if adjusted progress is after line start
      if (currentLine.lineStartTime <= adjustedProgress) {
        // Calculate valid end time (compatible with last line)
        // Last line uses theoretical end time
        // Prevent overlap with next line
        const endTime =
          mid === lrcList.length - 1 ? currentLine.lineStartTime + currentLine.lineDuration :
          Math.min(currentLine.lineStartTime + currentLine.lineDuration, lrcList[mid + 1].lineStartTime);

        //  Dual verification mechanism:
        // 1.Adjusted progress within display range (with animation offset)
        // 2.Real progress not exceeding line duration (prevent early switching)
        if (adjustedProgress < endTime && progress <= currentLine.lineStartTime + currentLine.lineDuration) {
          result = mid; // Record candidate index
        }
        low = mid + 1; // Continue searching right for closer matches
      } else {
        high = mid - 1; // Current line starts after adjusted progress, search left
      }
    }
    return result; // Return final result (-1 if not found)
  }

  // [End dynamic_lyrics_get_near_lyric]

  // [EndExclude dynamic_lyrics_call_on]
  // [EndExclude is_need_request_update_call_update]
  // [EndExclude music_control_card_call_on]
  // [EndExclude music_control_card_play_state_call]
  // [EndExclude music_control_card_collect_call_on]
  // [EndExclude music_control_card_pull_pages]
  // [EndExclude music_recommended_card_jump_card]
  // [Start request_updateplaycard]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // [StartExclude music_control_card_pull_pages]
    // [StartExclude music_control_card_collect_call_on]
    // [StartExclude request_updateplaycard]
    // [StartExclude try]
    // [StartExclude dynamic_lyrics_call_on]
    // [StartExclude is_need_request_update_call_update]
    // [StartExclude music_control_card_call_on]
    // [StartExclude music_control_card_play_state_call]
    // [StartExclude music_recommended_card_jump_card]
    Logger.info(TAG, 'Ability onCreate');
    AppStorage.setOrCreate('context', this.context);
    context = this.context;
    // [EndExclude music_control_card_pull_pages]
    // [EndExclude music_recommended_card_jump_card]
    this.handleParams(want);
    // [StartExclude music_control_card_pull_pages]
    // [StartExclude music_recommended_card_jump_card]
    this.initSongData();
    // [EndExclude try]
    // [EndExclude dynamic_lyrics_call_on]
    // [EndExclude music_control_card_call_on]
    // [EndExclude music_control_card_collect_call_on]
    try {
      // [StartExclude music_control_card_collect_call_on]
      this.callee.on('playByAction', this.playByActionCall);
      // [EndExclude music_control_card_collect_call_on]
      // [StartExclude music_control_card_call_on]
      this.callee.on('collectAction', this.collectActionCall);
      // [EndExclude request_updateplaycard]
      // [EndExclude is_need_request_update_call_update]
      // [Start request_updateplaycard]
      // [StartExclude music_control_card_collect_call_on]
      this.callee.on('requestUpdatePlayCard', this.requestUpdatePlayCard);
      // [EndExclude music_control_card_collect_call_on]
      // [End request_updateplaycard]
      // [EndExclude music_control_card_call_on]
      // [StartExclude request_updateplaycard]
      // [StartExclude is_need_request_update_call_update]
    } catch (error) {
      Logger.error(TAG, `playByAction register failed with error ${JSON.stringify(error)}`);
    }
    // [StartExclude music_control_card_collect_call_on]
    // [StartExclude dynamic_lyrics_call_on]
    // [Start dynamic_lyrics_set_play_state]
    // [Start dynamic_lyrics_get_dynamic_card_all_info]
    // [StartExclude music_control_card_call_on]
    // src/main/ets/entryability/EntryAbility.ets
    // [EndExclude music_control_card_play_state_call]
    MediaService.getInstance().setOnPlayStateCall(async (data: SongChangedData) => {
      // [StartExclude total_time]
      // [StartExclude dynamic_lyrics_set_play_state]
      // [StartExclude dynamic_lyrics_get_dynamic_card_all_info]
      // [StartExclude music_control_card_play_state_call]
      Logger.info(TAG, `SongChangedData:${JSON.stringify(data)}`);
      AppStorage.setOrCreate('totalTime', data.totalTime);
      AppStorage.setOrCreate('progressMax', data.progressMax);
      // [EndExclude total_time]
      // [EndExclude dynamic_lyrics_set_play_state]
      // [EndExclude dynamic_lyrics_get_dynamic_card_all_info]
      // [EndExclude music_control_card_play_state_call]
      AppStorage.setOrCreate('isPlay', data.isPlay);
      AppStorage.setOrCreate('selectIndex', data.selectIndex);
      AppStorage.setOrCreate('currentSong', data.songItem);
      PreferencesUtil.getInstance().putCurrentSong(context, data.songItem);
      FormUtils.updateMusicControlCards(this.context, data.songItem, data.isPlay);

      // [StartExclude music_control_card_play_state_call]
      // The dynamic lyrics card switching status caused the lyrics to reset separately below
      if (data.isPlay) {
        // When switching music, use initialization method
        if (AppStorage.get('dynamicLyricsSongID') !== data.songItem.id) {
          await FormUtils.updateDynamicLyricsMusicControlCards(this.context, data.songItem, data.isPlay);
        } else {
          // When processing the playback status separately from pause to play,
          // there is no need to initialize all content
          await FormUtils.updateDynamicLyricsMusicControlCards(this.context, data.songItem, data.isPlay,
            AppStorage.get('dynamicLyricsSongID'));
        }
      } else {
        await FormUtils.updateDynamicLyricsMusicControlCardsPlayPauseStatus(this.context, data.songItem, data.isPlay,
          AppStorage.get('dynamicLyricsSongID'));
      }
      // [StartExclude dynamic_lyrics_set_play_state]

      await this.getLrcEntryList(data.songItem);
      // [StartExclude dynamic_lyrics_get_dynamic_card_all_info]

      await FormUtils.updateControlWithLyrics(context, this.mLrcEntryList,
        AppStorage.get('currentLyricIndex') as number);
      if (data.isPlay) {
        BackgroundUtil.startContinuousTask(this.context);
      } else {
        BackgroundUtil.stopContinuousTask(this.context);
      }
      // [EndExclude dynamic_lyrics_set_play_state]
      // [EndExclude dynamic_lyrics_get_dynamic_card_all_info]
      // [EndExclude music_control_card_play_state_call]
    });
    // [End dynamic_lyrics_set_play_state]
    // [End dynamic_lyrics_get_dynamic_card_all_info]

    // [Start dynamic_lyrics_get_near_lyric]
    // [StartExclude music_control_card_play_state_call]
    MediaService.getInstance().setTimeUpdateCall(async (progress: number, updateTimeStr: string) => {
      AppStorage.setOrCreate('currentTime', updateTimeStr);
      AppStorage.setOrCreate('progress', progress);
      Logger.info(TAG, `time update:${JSON.stringify(updateTimeStr)},${JSON.stringify(progress)}`);
      // Call when playing progress updates
      const currentIndex = this.findCurrentLyricIndex(progress, this.mLrcEntryList);
      if (currentIndex !== -1) {
        await FormUtils.updateControlWithLyrics(context, this.mLrcEntryList, currentIndex);
      }
    });
    // [End dynamic_lyrics_get_near_lyric]
    // [EndExclude request_updateplaycard]
    // [EndExclude dynamic_lyrics_call_on]
    // [EndExclude music_control_card_pull_pages]
    // [EndExclude music_recommended_card_jump_card]
  }

  // [End request_updateplaycard]

  // [Start on_new_want]
  // [StartExclude dynamic_lyrics_call_on]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleParams(want);
  }

  // [End on_new_want]

  handleParams(want: Want) {
    Logger.info(TAG, 'handleParams');
    if (want?.parameters?.params) {
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      let type = params.type as string;
      // [StartExclude music_recommended_card_jump_card]
      Logger.info(TAG, `handleParams type: ${type}`);

      if (type === RouterType.PLAYER) {
        AppStorage.setOrCreate('isShowPlay', true);
        AppStorage.setOrCreate('mainTabIndex', 0);
      }
      // [StartExclude music_control_card_pull_pages]
      if (type === RouterType.LYRICS) {
        if (AppStorage.get('selectIndex') !== 0) {
          MediaService.getInstance().playByIndex(0);
        }
        AppStorage.setOrCreate('currentSong', getSongListData(this.context)[0]);
        AppStorage.setOrCreate('isShowPlay', true);
      }
      // [EndExclude music_recommended_card_jump_card]
      if (type === RouterType.PLAYLISTS) {
        AppStorage.setOrCreate('isToHotPlaylist', true);
      }

      if (type === RouterType.COLLECTED) {
        AppStorage.setOrCreate('mainTabIndex', 1);
        AppStorage.setOrCreate('isShowPlay', false);
      }
      // [EndExclude music_control_card_pull_pages]
    }
  }

  // [End handle_params]

  // [EndExclude dynamic_lyrics_call_on]
  // [EndExclude music_control_card_call_on]
  // [EndExclude music_control_card_release_state]
  // [EndExclude music_control_card_collect_call_on]
  // [Start ondestroy]
  // [StartExclude music_control_card_pull_pages]
  // [StartExclude music_recommended_card_jump_card]
  onDestroy() {
    try {
      // [StartExclude music_control_card_collect_call_on]
      // [StartExclude callee1]
      // [StartExclude ondestroy]
      // [StartExclude music_control_card_release_state]
      Logger.info(TAG, 'Ability onDestroy');
      this.callee.off('playByAction');
      // [EndExclude music_control_card_collect_call_on]
      // [StartExclude dynamic_lyrics_call_on]
      // [StartExclude music_control_card_call_on]
      this.callee.off('collectAction');
      // [StartExclude music_control_card_collect_call_on]
      this.callee.off('requestUpdatePlayCard');
      // [EndExclude callee1]
      // [EndExclude ondestroy]
      // [EndExclude music_control_card_release_state]
      let isPlay = AppStorage.get('isPlay') as boolean;
      // [StartExclude music_control_card_release_state]
      Logger.info(TAG, `onDestroy isPlay ${isPlay}`);
      // [EndExclude music_control_card_release_state]
      if (isPlay) {
        FormUtils.updateCardPlayStatus(this.context, false);
        // [StartExclude music_control_card_release_state]
        FormUtils.updateDynamicLyricsCardPlayStatus(this.context, false);
        // [EndExclude music_control_card_release_state]
      }
      // [EndExclude dynamic_lyrics_call_on]
      // [EndExclude music_control_card_collect_call_on]
      // [EndExclude music_control_card_call_on]
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `onDestroy err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

  // [End ondestroy]
  // [StartExclude dynamic_lyrics_call_on]
  // [StartExclude music_control_card_call_on]
  // [StartExclude music_control_card_release_state]
  // [StartExclude music_control_card_collect_call_on]

  onWindowStageCreate(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);

    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause: ${JSON.stringify(err) ?? ''}`);
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      WindowUtils.initWindow(windowStage);
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  // [EndExclude dynamic_lyrics_call_on]
  // [EndExclude is_need_request_update_call_update]
  // [EndExclude music_control_card_call_on]
  // [EndExclude music_control_card_play_state_call]
  // [EndExclude music_control_card_release_state]
  // [EndExclude music_control_card_collect_call_on]
  // [EndExclude music_control_card_pull_pages]
  // [EndExclude music_recommended_card_jump_card]
}

// [End entryability]
// [End is_need_request_update_call_update]
// [End music_control_card_call_on]
// [End music_control_card_play_state_call]
// [End music_control_card_release_state]
// [End music_control_card_collect_call_on]
// [End music_control_card_pull_pages]
// [End music_recommended_card_jump_card]
// [End dynamic_lyrics_call_on]
