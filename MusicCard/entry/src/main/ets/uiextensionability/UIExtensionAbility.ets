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

import { UIExtensionContentSession } from '@kit.AbilityKit';
import { LiveFormExtensionAbility, LiveFormInfo, formInfo } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PreferencesUtil } from '../database/PreferencesUtil';
import { SongRdbHelper } from '../database/SongRdbHelper';
import { SongItem } from '../viewmodel/SongItem';
import { getSongListData } from '../viewmodel/SongListData';

const TAG: string = '[MusicCard Extension]';

// [Start overflow]
export default class UIExtensionAbility extends LiveFormExtensionAbility {
  async onLiveFormCreate(liveFormInfo: LiveFormInfo, session: UIExtensionContentSession) {
    hilog.info(0x0000, TAG, `onLiveFormCreate, liveformInfo: ${JSON.stringify(liveFormInfo)}`);

    let storage: LocalStorage = new LocalStorage();
    storage.setOrCreate('context', this.context);

    let formId: string = liveFormInfo.formId;
    AppStorage.setOrCreate('formId', formId);
    storage.setOrCreate('formId', formId);

    let formRect: formInfo.Rect = liveFormInfo.rect;
    storage.setOrCreate('formRect', formRect);

    let borderRadius: number = liveFormInfo.borderRadius;
    storage.setOrCreate('radius', borderRadius);

    try {
      session.loadContent('uiextensionability/pages/Index', storage);
    } catch (error) {
      hilog.error(0x0000, TAG, `loadContent catch error, code: ${error.code}, message: ${error.message}`)
    }

    let songRdbHelper = SongRdbHelper.getInstance(this.context);
    let initSongs: Array<SongItem> = await songRdbHelper.queryAllSongs();
    if (initSongs.length <= 0) {
      initSongs = getSongListData(this.context);
      songRdbHelper.insertSongs(initSongs);
    }
    AppStorage.setOrCreate('songList', initSongs);
    let currentSong = await PreferencesUtil.getInstance().getCurrentSong(this.context);
    if (!currentSong) {
      currentSong = initSongs[0];
      PreferencesUtil.getInstance().putCurrentSong(this.context, currentSong);
    }
    AppStorage.setOrCreate('currentSong', currentSong);
  }

  onLiveFormDestroy(liveFormInfo: LiveFormInfo): void {
    hilog.info(0x0000, TAG, `onLiveFormDestroy, liveFormInfo: ${JSON.stringify(liveFormInfo)}`);
  }
}
// [End overflow]