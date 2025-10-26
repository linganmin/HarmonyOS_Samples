/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { http } from '@kit.NetworkKit';
import { FormControlData } from '../viewmodel/FormControlData';
import { SongItem } from '../viewmodel/SongItem';
import { Logger } from './Logger';
import { FormInfo } from '../viewmodel/FormInfo';
import { FormRdbHelper } from '../database/FormRdbHelper';
import ImageUtils from './ImageUtils';
import { getRandomLyrics, getInitialLyrics, getSpecificLyrics, getSongLyricsArray } from '../lyric/LrcUtils';
import { SongRdbHelper } from '../database/SongRdbHelper';
import { PreferencesUtil } from '../database/PreferencesUtil';
import { LrcEntry } from '../lyric/LrcEntry';

const TAG = 'FormUtils';

interface UpdateData {
  isCollected?: boolean;
  isNeedRequestUpdate?: boolean;
  formId?: string;
}

class UpdateDynamicLyricsData {
  isPlay: boolean = false;
}

// [Start is_need_request_update]
// [Start music_control_card_get_info]
// [Start music_control_card_update_by_id]
// [Start music_control_card_release_state]
// [Start music_control_card_all_update]
// [Start music_control_card_color_card]
// [Start music_recommended_card_update_image]
// [Start music_heart_card_update]
// src/main/ets/utils/FormUtils.ets
class FormUtils {
  // [StartExclude is_need_request_update]
  // [StartExclude music_control_card_get_info]
  // [StartExclude music_control_card_update_by_id]
  // [StartExclude music_control_card_release_state]
  // [StartExclude music_control_card_all_update]
  // [StartExclude music_control_card_color_card]
  // [StartExclude music_recommended_card_update_image]
  // [StartExclude music_heart_card_update]
  public insertFormData(context: Context, data: FormInfo): Promise<number> {
    return FormRdbHelper.getInstance(context).insertForm(data);
  }

  /**
   * This function is used to update controls related to lyrics, by querying the dynamic lyrics form and updating
   * its content.
   * @param context object, used to retrieve the current environment or state
   * @param lyrics array, containing multiple lyrics entries
   * @aram lyricsIndex is an index of current lyrics used to retrieve specific lyrics
   */
  // [Start dynamic_lyrics_get_near_lyric]
  public async updateControlWithLyrics(context: Context, lyrics: Array<LrcEntry>, lyricsIndex: number) {
    FormRdbHelper.getInstance(context)
      .queryFormByName('DynamicLyrics')
      .then((formList) => {
        formList.forEach((formInfo) => {
          let songData = getSpecificLyrics(context, lyrics, lyricsIndex);
          let songItem: SongItem = songData.songItem as SongItem;

          class CardUpdateData {
            lrcArray: Array<string> = songData.randomLrcStr as Array<string>;
            formId: string = formInfo.formId;
            singer: string = songItem.singer;
            title: string = songItem.title;
            songId: string = songItem.id;
            musicCover: Resource = songItem.label;
          }

          this.updateForm(formInfo.formId, new CardUpdateData());
        });
      });
  }

  // [End dynamic_lyrics_get_near_lyric]
  // [EndExclude music_control_card_all_update]

  // [Start update_cardcollect_status]
  public async updateCardCollectStatus(context: Context, isCollected: boolean) {
    let updateData: UpdateData = {
      isCollected: isCollected,
    };
    let formList: Array<FormInfo> = await FormRdbHelper.getInstance(context).queryFormByName('PlayControlCard');
    formList.forEach((formInfo) => {
      this.updateForm(formInfo.formId, updateData);
    });
  }

  // [End update_cardcollect_status]
  // [EndExclude music_control_card_release_state]

  // [Start update_cardplay_status]
  // [StartExclude music_control_card_all_update]
  public async updateCardPlayStatus(context: Context, isPlay: boolean) {
    class CardUpdateData {
      isPlay: boolean = isPlay;
    }

    let data = new CardUpdateData();
    let formList: Array<FormInfo> = await FormRdbHelper.getInstance(context).queryFormByName('PlayControlCard');
    Logger.info(TAG, `updateCardPlayStatus formList length:  ${formList.length}`);
    formList.forEach((formInfo) => {
      this.updateForm(formInfo.formId, data);
    });
  }

  // [End update_cardplay_status]

  // [StartExclude music_control_card_release_state]
  /**
   * This function is used to update the playback status of dynamic lyric cards. It queries the form information in
   * the database and updates the playback status of each form
   * @param context type is Context, which represents the current context environment and is used for database
   * queries and logging.
   * @param isPlay type is boolean, indicating the playback status, true indicates playback, and false indicates pause.
   */
  // [Start update_dynamic_lyrics_card_play_status]
  public async updateDynamicLyricsCardPlayStatus(context: Context, isPlay: boolean) {
    class CardUpdateData {
      isPlay: boolean = isPlay;
    }

    let data = new CardUpdateData(); // Create card update data object
    let formList: Array<FormInfo> =
      await FormRdbHelper.getInstance(context).queryFormByName('DynamicLyrics'); // Query the form named 'DynamicLyrics'
    Logger.info(TAG, `updateCardPlayStatus formList length:  ${formList.length}`);
    formList.forEach((formInfo) => {
      // Traverse the form list and update the form
      this.updateForm(formInfo.formId, data);
    });
  }

  // [End update_dynamic_lyrics_card_play_status]
  // [EndExclude music_control_card_update_by_id]
  // [EndExclude music_control_card_color_card]

  // [Start update_music_controlcards]
  // [Start dynamic_lyrics_update_music_control_cards]
  public async updateMusicControlCards(context: Context, songItem: SongItem, isPlay: boolean) {
    // [StartExclude music_control_card_update_by_id]
    let isCollected = await SongRdbHelper.getInstance(context).isCollected(songItem.id);
    let imageDealData = await ImageUtils.getImageDealData(context, songItem.label);
    // [EndExclude music_control_card_update_by_id]
    let formList: Array<FormInfo> = await FormRdbHelper.getInstance(context).queryFormByName('PlayControlCard');
    let formData = new FormControlData();
    // [StartExclude music_control_card_color_card]
    formData.isPlay = isPlay;
    formData.singer = songItem.singer;
    formData.title = songItem.title;
    formData.songId = songItem.id;
    formData.musicCover = songItem.label;
    formData.isCollected = isCollected;
    formData.imageColor = imageDealData.imageColor;
    // [EndExclude music_control_card_color_card]
    formData.imageColorHex = imageDealData.imageColorHex;

    formList.forEach((formInfo) => {
      this.updateForm(formInfo.formId, formData);
    });
  }

  // [End dynamic_lyrics_update_music_control_cards]

  // [End update_music_controlcards]

  // [StartExclude music_control_card_color_card]
  // [StartExclude music_control_card_update_by_id]
  /**
   * This function is used to update the data of the dynamic lyric music control card. It queries whether a song has
   * been bookmarked based on the given song information and playback status, obtains the cover image of the song for
   * data processing, and then updates all form data named "DynamicLyrics"
   * @param context object, used to retrieve database instances and perform other operations.
   * @param songItem song object contains detailed information about the song, such as singer, title, ID, and cover.
   * @param isPlay Boolean value, indicating whether the current song is playing.
   */
  // [Start dynamic_lyrics_update_Cards]
  public async updateDynamicLyricsMusicControlCards(context: Context, songItem: SongItem, isPlay: boolean,
    dynamicLyricsSongID?: string) {
    let isCollected = await SongRdbHelper.getInstance(context).isCollected(songItem.id);
    let imageDealData = await ImageUtils.getImageDealData(context, songItem.label);
    let formList: Array<FormInfo> = await FormRdbHelper.getInstance(context).queryFormByName('DynamicLyrics');
    // Determine based on dynamicLyricsSongID After switching songs, the lyrics cannot be updated in a timely manner
    if (!dynamicLyricsSongID) {
      let formData = new FormControlData();
      let dynamicLrcStr = getSongLyricsArray(context, songItem);
      formData.isPlay = isPlay;
      formData.singer = songItem.singer;
      formData.songId = songItem.id;
      formData.title = songItem.title;
      formData.musicCover = songItem.label;
      formData.isCollected = isCollected;
      formData.imageColor = imageDealData.imageColor;
      formData.imageColorHex = imageDealData.imageColorHex;
      formData.lrcArray = dynamicLrcStr;
      formList.forEach((formInfo) => {
        this.updateForm(formInfo.formId, formData);
      });
      AppStorage.setOrCreate('dynamicLyricsSongID', songItem.id);
    } else {
      // The issue of resetting lyrics for one second when only handling card playback pauses in dynamic lyrics
      let formData: UpdateDynamicLyricsData = new UpdateDynamicLyricsData();
      formData.isPlay = isPlay;
      formList.forEach((formInfo) => {
        this.updateForm(formInfo.formId, formData);
      });
    }
  }

  // [End dynamic_lyrics_update_Cards]

  /**
   * Handling dynamic lyric cards during manual playback and pause may cause the lyrics to reset.
   * @param context object, used to retrieve database instances and perform other operations.
   * @param songItem song object contains detailed information about the song, such as singer, title, ID, and cover.
   * @param isPlay Boolean value, indicating whether the current song is playing.
   * @param dynamicLyricsSongID Local stored dynamic lyric card with current song ID
   */
  public async updateDynamicLyricsMusicControlCardsPlayPauseStatus(context: Context, songItem: SongItem,
    isPlay: boolean, dynamicLyricsSongID: string | undefined) {
    let formList: Array<FormInfo> = await FormRdbHelper.getInstance(context).queryFormByName('DynamicLyrics');
    if (dynamicLyricsSongID === songItem.id) {
      let formData: UpdateDynamicLyricsData = new UpdateDynamicLyricsData();
      formData.isPlay = isPlay; // Only update playback status
      formList.forEach((formInfo) => {
        this.updateForm(formInfo.formId, formData);
      });
    }
  }

  // [EndExclude music_control_card_get_info]

  // [Start dynamic_lyrics_get_song_lyrics_arr]
  // [Start dynamic_lyrics_update_music_control_single]
  // [Start update_music_controlsingle]
  // [Start update_music_dynamic_lyrics]
  // src/main/ets/utils/FormUtils.ets
  public async updateMusicControlSingle(context: Context, formId: string) {
    // [Start update_music_dynamic_lyrics]
    let isPlay = AppStorage.get('isPlay') as boolean;
    let songItem: SongItem = AppStorage.get('currentSong') as SongItem;
    // [End update_music_dynamic_lyrics]
    // [StartExclude song_item]
    // [StartExclude song_item_dynamic_lyrics]
    // [StartExclude dynamic_lyrics_update_music_control_single]
    // [StartExclude dynamic_lyrics_get_song_lyrics_arr]
    // [StartExclude music_control_card_get_info]
    if (!songItem) {
      songItem = (await PreferencesUtil.getInstance().getCurrentSong(context)) as SongItem;
    }
    Logger.info(`updateMusicControlSingle isPlay:${isPlay}, songItem:${JSON.stringify(songItem)}`);
    // [EndExclude music_control_card_get_info]
    // [EndExclude song_item_dynamic_lyrics]
    // [EndExclude dynamic_lyrics_update_music_control_single]
    let collectedSongList: Array<SongItem> = await SongRdbHelper.getInstance(context).queryCollectedSongs();
    // [StartExclude music_control_card_get_info]
    let imageDealData = await ImageUtils.getImageDealData(context, songItem.label);
    // [EndExclude dynamic_lyrics_get_song_lyrics_arr]
    let dynamicLrcStr = getSongLyricsArray(context, songItem);
    // [EndExclude music_control_card_get_info]
    let formData = new FormControlData();
    formData.isPlay = isPlay;
    formData.formId = formId;
    // [StartExclude dynamic_lyrics_get_song_lyrics_arr]
    formData.singer = songItem.singer;
    formData.title = songItem.title;
    formData.songId = songItem.id;
    formData.musicCover = songItem.label;
    formData.isCollected = collectedSongList.findIndex((item) => item.id === songItem.id) >= 0;
    // [EndExclude song_item]
    // [StartExclude dynamic_lyrics_update_music_control_single]
    // [StartExclude music_control_card_get_info]
    formData.imageColor = imageDealData.imageColor;
    formData.imageColorHex = imageDealData.imageColorHex;
    // [EndExclude dynamic_lyrics_get_song_lyrics_arr]
    formData.lrcArray = dynamicLrcStr;
    // [StartExclude dynamic_lyrics_get_song_lyrics_arr]
    Logger.info(TAG, `updateMusicControlSingle formData: ${formData}`);
    // [EndExclude dynamic_lyrics_update_music_control_single]
    // [EndExclude dynamic_lyrics_get_song_lyrics_arr]
    // [EndExclude music_control_card_get_info]
    this.updateForm(formData.formId, formData);
  }

  // [End dynamic_lyrics_get_song_lyrics_arr]
  // [End dynamic_lyrics_update_music_control_single]
  // [End update_music_controlsingle]
  // [End update_music_dynamic_lyrics]
  // [EndExclude is_need_request_update]
  // [Start update_music_controlcard]
  // [Start dynamic_lyrics_need_request_update]
  // [StartExclude music_control_card_get_info]
  public updateMusicControlCard(formId: string, needUpdate: boolean) {
    Logger.info(TAG, `updateMusicControlCard formId:${formId},needUpdate:${needUpdate}`);
    let updateData: UpdateData = {
      isNeedRequestUpdate: needUpdate,
      formId: formId,
    };
    this.updateForm(formId, updateData);
  }

  // [End dynamic_lyrics_need_request_update]
  // [End update_music_controlcard]
  // [EndExclude music_heart_card_update]
  // [StartExclude is_need_request_update]
  // [Start updatelyrics_card]
  public async updateLyricsCard(context: Context, formId: string) {
    let songData = getRandomLyrics(context);
    let songItem: SongItem = songData.songItem as SongItem;
    let imageDealData = await ImageUtils.getImageDealData(context, songItem.label);

    class CardUpdateData {
      lrcArray: Array<string> = songData.randomLrcStr as Array<string>;
      formId: string = formId;
      singer: string = songItem.singer;
      title: string = songItem.title;
      songId: string = songItem.id;
      musicCover: Resource = songItem.label;
      imageColor = imageDealData.imageColor;
    }

    this.updateForm(formId, new CardUpdateData());
  }
  // [StartExclude music_heart_card_update]

  // [End updatelyrics_card]

  /**
   *This function is used to update the data of the dynamic lyric music control card. It queries whether a song has
   * been bookmarked based on the given song information and playback status, obtains the cover image of the song for
   * data processing, and then updates all form data named "DynamicLyrics"
   * @param context object, used to retrieve database instances and perform other operations.
   * @param songItem song object contains detailed information about the song, such as singer, title, ID, and cover.
   * @param isPlay Boolean value, indicating whether the current song is playing.
   */
  public async updateDynamicLyricsControlCard(context: Context, formId: string) {
    let songData = getInitialLyrics(context);
    let songItem: SongItem = songData.songItem as SongItem;
    let imageDealData = await ImageUtils.getImageDealData(context, songItem.label);

    class CardUpdateData {
      lrcArray: Array<string> = songData.randomLrcStr as Array<string>;
      formId: string = formId;
      singer: string = songItem.singer;
      title: string = songItem.title;
      songId: string = songItem.id;
      musicCover: Resource = songItem.label;
      imageColor = imageDealData.imageColor;
    }

    this.updateForm(formId, new CardUpdateData());
  }
  // [EndExclude music_recommended_card_update_image]
  public async updateRecommendedCard(context: Context, formId: string, imageUrl: string) {
    try {
      let tempDir = context.getApplicationContext().tempDir;
      let fileName = 'file' + Date.now();
      let tmpFile = tempDir + '/' + fileName + '.jpg';
      let httpRequest = http.createHttp();
      let data = await httpRequest.request(imageUrl);
      let imgMap: Record<string, number> = {};

      class FormDataClass {
        imgBg: string = fileName;
        formImages: Record<string, number> = imgMap;
        isLoaded: boolean = true;
        imageColorHex: string = '';
      }

      if (data.responseCode === http.ResponseCode.OK) {
        let imgFile = fileIo.openSync(tmpFile, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        imgMap[fileName] = imgFile.fd;
        try {
          let imageBuffer: ArrayBuffer = data.result as ArrayBuffer;
          let writeLen: number = fileIo.writeSync(imgFile.fd, imageBuffer);
          let imageDealData = await ImageUtils.getImageDealDataByArr(imageBuffer);
          Logger.info(TAG, `write data to file succeed and size is: ${writeLen}`);
          Logger.info(TAG, `ArkTSCard download complete: ${tmpFile}`);
          let formData = new FormDataClass();
          formData.imageColorHex = imageDealData.imageColorHex;
          this.updateForm(formId, formData);
        } catch (err) {
          Logger.error(TAG, `write data to file failed with error: ${JSON.stringify(err)}`);
        } finally {
          fileIo.closeSync(imgFile);
          httpRequest.destroy();
        }
      } else {
        Logger.error(TAG, `ArkTSCard download task failed`);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `updateRecommendedCard err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

  // [End updatere_commendedcard]
  // [EndExclude is_need_request_update]
  // [EndExclude music_control_card_update_by_id]

  // [Start update_music_controlcard]
  // [Start dynamic_lyrics_need_request_update]
  // [Start dynamic_lyrics_update_music_control_cards]
  // [StartExclude music_recommended_card_update_image]
  private updateForm(formId: string, updateData: object) {
    Logger.info(TAG, `updateForm  updateData: ${JSON.stringify(updateData)}}`);
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(updateData);
    formProvider
      .updateForm(formId, formMsg)
      .then(() => {
        Logger.info(TAG, `updateForm success formId:  ${formId}}`);
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `updateForm failed: ${JSON.stringify(error)}`);
      });
  }

  // [End dynamic_lyrics_update_music_control_cards]

  // [End dynamic_lyrics_need_request_update]

  // [End update_music_controlcard]
  // [EndExclude music_control_card_get_info]
  // [EndExclude music_control_card_release_state]
  // [EndExclude music_control_card_all_update]
  // [EndExclude music_control_card_color_card]
  // [EndExclude music_recommended_card_update_image]
  // [EndExclude music_heart_card_update]
}

// [End is_need_request_update]
// [End music_control_card_get_info]
// [End music_control_card_update_by_id]
// [End music_control_card_release_state]
// [End music_control_card_all_update]
// [End music_control_card_color_card]
// [End music_recommended_card_update_image]
// [End music_heart_card_update]
// [End formutils_class]
export default new FormUtils();
