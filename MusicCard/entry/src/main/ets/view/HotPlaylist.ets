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

import { SongListItem } from '../components/SongListItem';
import { LazyDataSource } from '../utils/LazyDataSource';
import { SongItem } from '../viewmodel/SongItem';

@Component
export struct HotPlaylist {
  @StorageLink('songList') songList: SongItem[] = [];
  @Consume pageStack: NavPathStack;
  @State title: string = '';

  aboutToAppear(): void {
    let params: Array<string> = this.pageStack.getParamByName('Playlists') as Array<string>
    if (params && params.length > 0) {
      this.title = params[0];
    }
  }

  build() {
    NavDestination() {
      List() {
        LazyForEach(new LazyDataSource(this.songList), (item: SongItem, index: number) => {
          ListItem() {
            SongListItem({ item: item, index: index, isCanPlay: false })
          }
        }, (item: SongItem) => item.id)
      }
      .width('100%')
      .height('100%')
      .cachedCount(3)
      .divider({
        strokeWidth: 1,
        color: '#E8E8E8',
        startMargin: 16,
        endMargin: 16
      })
    }
    .title(this.title)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0
    })
  }
}