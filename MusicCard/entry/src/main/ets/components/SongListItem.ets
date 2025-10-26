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

import FormUtils from '../utils/FormUtils';
import { MediaService } from '../utils/MediaService';
import { SongRdbHelper } from '../database/SongRdbHelper';
import { SongItem } from '../viewmodel/SongItem';

// [Start music_control_card_collect_change_status]
@Reusable
@Component
export struct SongListItem {
  // [StartExclude music_control_card_collect_change_status]
  // [StartExclude songlist_item]
  @StorageProp('isPlay') isPlay: boolean = false;
  @StorageProp('currentSong') currentSong: SongItem = new SongItem();
  @Prop item: SongItem;
  private index: number = 0;
  private isCanPlay: boolean = true;
  private isShowCollected: boolean = true;

  // [EndExclude songlist_item]
  // [EndExclude music_control_card_collect_change_status]

  async collected() {
    let context = this.getUIContext().getHostContext()!
    let songRdbHelper = SongRdbHelper.getInstance(context);
    if (this.item.isCollected) {
      await songRdbHelper.updateCollected(this.item.id, '0');
      FormUtils.updateCardCollectStatus(context, false);
      this.item.isCollected = false;
      context.eventHub.emit('collected', this.item.id, '0');
    } else {
      await songRdbHelper.updateCollected(this.item.id, '1');
      FormUtils.updateCardCollectStatus(context, true);
      this.item.isCollected = true;
      context.eventHub.emit('collected', this.item.id, '1');
    }
  }

  build() {
    Row() {
      // [StartExclude songlist_item]
      // [StartExclude music_control_card_collect_change_status]
      Column() {
        Text($r(this.item.title))
          .fontWeight(500)
          .fontColor(this.item.id === this.currentSong.id ? '#FF1949' : $r('sys.color.ohos_id_color_text_primary'))
          .fontSize(16)
          .margin({ bottom: 4 })
        Row({ space: 4 }) {
          Image(this.item.mark === '1' ? $r('app.media.ic_vip') : $r('app.media.ic_sq'))
            .width(16)
            .height(16)
          Text($r(this.item.singer))
            .fontSize(12)
            .fontWeight(400)
            .fontColor(this.item.id === this.currentSong.id ? '#FF1949' : $r('sys.color.ohos_id_color_text_tertiary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      if (this.isShowCollected) {
        // [EndExclude songlist_item]
        // [EndExclude music_control_card_collect_change_status]
        Image(this.item.isCollected ? $r('app.media.ic_item_collected') :
        $r('app.media.ic_item_uncollected'))// [StartExclude music_control_card_collect_change_status]
          // [End songlist_item]
          .height(50)
          .width(50)
          .padding(13)// [Start songlist_item]
            // [EndExclude music_control_card_collect_change_status]
          .onClick(() => {
            this.collected();
          })
        // [End songlist_item]
      }
    }
    // [StartExclude music_control_card_collect_change_status]
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .onClick(() => {
      if (this.isCanPlay && !(this.item.id === this.currentSong.id)) {
        MediaService.getInstance().controlPlay(this.index);
      }
    })
    .width('100%')

    // [Start songlist_item]
    // [EndExclude music_control_card_collect_change_status]
  }
}

// [End music_control_card_collect_change_status]
// [End songlist_item]