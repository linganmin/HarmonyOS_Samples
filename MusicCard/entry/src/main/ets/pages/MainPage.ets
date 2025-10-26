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

import { CollectedMusic } from '../view/CollectedMusic';
import { RecommendedMusic } from '../view/RecommendedMusic';
import { PlayController } from '../components/PlayController';
import { CustomTabBar } from '../components/CustomTabBar';
import { HotPlaylist } from '../view/HotPlaylist';
import { Logger } from '../utils/Logger';

const TAG = 'MainPage';

// [Start want_params_on_change]
// [Start music_recommended_card_jump_hot_music]
// src/main/ets/pages/MainPage.ets
@Entry
@Component
struct MainPage {
  @StorageLink('mainTabIndex') currentIndex: number = 0;
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  // [StartExclude want_params_on_change]
  @StorageLink('isToHotPlaylist') isToHotPlaylist: boolean = false;
  // [StartExclude music_recommended_card_jump_hot_music]
  @State playlistsTitle: ResourceStr[] =
    [$r('app.string.hot_playlist1'), $r('app.string.hot_playlist2'), $r('app.string.hot_playlist3'),
      $r('app.string.hot_playlist4')];
  // [EndExclude music_recommended_card_jump_hot_music]

  @Builder
  PageMap(name: string) {
    if (name === 'Playlists') {
      HotPlaylist()
    }
  }

  onPageShow(): void {
    if (this.isToHotPlaylist) {
      this.isToHotPlaylist = false;
      // [Start stack_index_array]
      // [StartExclude music_recommended_card_jump_hot_music]
      let stackIndexArray = this.pageStack.getAllPathName();
      // [EndExclude music_recommended_card_jump_hot_music]
      if (stackIndexArray.length > 0 && stackIndexArray[stackIndexArray.length-1] === 'Playlists') {
        this.pageStack.replacePathByName('Playlists', this.playlistsTitle);
      } else {
        this.pageStack.pushPathByName('Playlists', this.playlistsTitle);
      }
      // [End stack_index_array]
    }
  }

  // [EndExclude want_params_on_change]
  build() {
    Navigation(this.pageStack) {
      // [StartExclude music_recommended_card_jump_hot_music]
      Column() {
        Tabs({ index: this.currentIndex, barPosition: BarPosition.End }) {
          TabContent() {
            RecommendedMusic()
          }

          TabContent() {
            CollectedMusic()
          }
        }
        // [StartExclude want_params_on_change]
        .layoutWeight(1)
        .barHeight(0)
        .scrollable(false)
        // [EndExclude want_params_on_change]
        .onChange((index) => {
          this.currentIndex = index;
        })

        // [StartExclude want_params_on_change]
        PlayController()

        CustomTabBar({ currentIndex: this.currentIndex })
        // [EndExclude want_params_on_change]
      }
      .padding({
        top: AppStorage.get<number>('statusBarHeight') ?? 0,
        bottom: AppStorage.get<number>('naviIndicatorHeight') ?? 0
      })
      .backgroundColor('#F1F3F5')

      // [EndExclude main_page1]
      // [EndExclude music_recommended_card_jump_hot_music]
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}

// [End want_params_on_change]
// [End music_recommended_card_jump_hot_music]