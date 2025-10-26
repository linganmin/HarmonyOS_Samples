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

import { SongItem } from '../viewmodel/SongItem';
import { SongListItem } from './SongListItem';
import { LazyDataSource } from '../utils/LazyDataSource';

@Component
export struct PlayList {
  @StorageLink('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageLink('songList') songList: SongItem[] = [];

  build() {
    List() {
      LazyForEach(new LazyDataSource(this.songList), (item: SongItem, index: number) => {
        ListItem() {
          SongListItem({
            item: item,
            index: index
          })
        }
      }, (item: SongItem) => item.id)
    }
    .width('100%')
    .height('100%')
    .cachedCount(3)
    .padding({
      bottom: this.naviIndicatorHeight
    })
    .divider({
      strokeWidth: 1,
      color: '#E8E8E8',
      startMargin: 16,
      endMargin: 16
    })
  }
}