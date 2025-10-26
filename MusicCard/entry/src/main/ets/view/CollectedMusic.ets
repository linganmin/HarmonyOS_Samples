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
import { SongRdbHelper } from '../database/SongRdbHelper';
import { LazyDataSource } from '../utils/LazyDataSource';
import { MenuComp } from '../components/MenuComp';

@Component
export struct CollectedMusic {
  @StorageLink('collectedSongList') collectedSongList: SongItem[] = [];
  private labelList: Resource[] = [$r('app.string.collected_label_synthesis'), $r('app.string.collected_label_single'),
    $r('app.string.collected_label_video'), $r('app.string.collected_label_playlists')];
  private dataSource = new LazyDataSource<SongItem>();
  private eventhub = this.getUIContext().getHostContext()!.eventHub;
  private collectedEvent = (songId: string, type: string) => {
    this.getCollectedData();
  };

  getCollectedData() {
    SongRdbHelper.getInstance(this.getUIContext().getHostContext()!).queryCollectedSongs().then((songs) => {
      this.collectedSongList = [...songs];
      this.dataSource.pushArrayData(this.collectedSongList);
      AppStorage.setOrCreate('collectedSongList', this.collectedSongList);
    })
  }

  aboutToAppear(): void {
    this.getCollectedData();
    this.eventhub.on('collected', this.collectedEvent);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.collect'))
          .width('50%')
          .fontWeight(700)
          .fontSize(26)
          .height(56)
          .fontColor($r('sys.color.ohos_id_color_primary'))
          .padding({
            left: 16,
            right: 16
          })
        MenuComp()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Row({ space: 8 }) {
        ForEach(this.labelList, (item: Resource, index: number) => {
          Text(item)
            .height('100%')
            .width(72)
            .fontSize(12)
            .fontColor(index === 0 ? '#FFFFFF' : '#E5000000')
            .fontWeight(index === 0 ? FontWeight.Bold : FontWeight.Normal)
            .backgroundColor(index === 0 ? '#FF1949' : '#E5E7E9')
            .borderRadius(14)
            .textAlign(TextAlign.Center)
        }, (item: string) => item)
      }
      .height(28)
      .margin({
        top: 8,
        bottom: 16
      })
      .padding({
        left: 16,
        right: 16
      })

      Row({ space: 8 }) {
        Image($r('app.media.ic_public_play_red'))
          .height(32)
          .width(32)
        Text($r('app.string.play_all', this.collectedSongList.length))
          .fontWeight(700)
          .fontSize(18)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
      }
      .height(48)
      .alignSelf(ItemAlign.Start)
      .padding({
        left: 16,
        right: 16
      })

      List() {
        LazyForEach(this.dataSource, (item: SongItem) => {
          ListItem() {
            SongListItem({ item: item, isCanPlay: false })
          }
        }, (item: SongItem) => item.id)
      }
      .width('100%')
      .cachedCount(3)
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: '#E8E8E8',
        startMargin: 16,
        endMargin: 16
      })
    }
    .backgroundColor('#F1F3F5')
    .height('100%')
    .width('100%')
  }
}