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
import { SongListItem } from '../components/SongListItem';
import { HotPlaylistItem } from '../components/HotPlaylistItem';
import { LazyDataSource } from '../utils/LazyDataSource';

@Component
export struct RecommendedMusic {
  @StorageLink('songList') songList: SongItem[] = [];
  @Consume pageStack: NavPathStack;
  @State playlistsTitles: ResourceStr[] =
    [$r('app.string.hot_playlist1'), $r('app.string.hot_playlist2'), $r('app.string.hot_playlist3'),
      $r('app.string.hot_playlist4')];
  private eventhub = this.getUIContext().getHostContext()!.eventHub;
  private collectedEvent = (songId: string, type: string) => {
    let changeSong = this.songList.find(item => item.id === songId);
    if (changeSong) {
      changeSong.isCollected = (type === '1');
    }
  };

  aboutToAppear(): void {
    this.eventhub.on('collected', this.collectedEvent);
  }

  build() {
    Column() {
      Text($r('app.string.recommended'))
        .width('100%')
        .fontWeight(700)
        .fontSize(26)
        .height(56)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .padding({
          left: 16,
          right: 16
        })
      Scroll() {
        Column() {
          Search({ placeholder: 'Dream' })
            .enabled(false)
            .height(40)
            .margin({
              left: 16,
              right: 16,
              top: 8,
              bottom: 16
            })

          List({ space: 8 }) {
            ForEach(this.playlistsTitles, (item: string, index: number) => {
              ListItem() {
                HotPlaylistItem({ title: item })
                  .onClick(() => {
                    this.pageStack.pushPathByName('Playlists', item);
                  })
                  .margin({
                    left: index === 0 ? 16 : 0,
                    right: index === 3 ? 16 : 0
                  })
              }
            }, (item: string) => item)
          }
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
          .height(280)
          .width('100%')

          Text($r('app.string.hot_music'))
            .height(56)
            .fontWeight(700)
            .fontSize(18)
            .margin({
              left: 16,
              bottom: 8
            })
            .alignSelf(ItemAlign.Start)
            .fontColor($r('sys.color.ohos_id_color_primary'))
            .align(Alignment.Bottom)

          List() {
            LazyForEach(new LazyDataSource(this.songList), (item: SongItem, index: number) => {
              ListItem() {
                SongListItem({ item: item, index: index })
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
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
        }
        .backgroundColor('#F1F3F5')
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
  }
}