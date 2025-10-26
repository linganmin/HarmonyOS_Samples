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

import { MediaTools } from '../common/utils/MediaTools';
import { SongItem, ToneQuality } from '../model/SongData';

@Component
export default struct ToneQualityList {
  @StorageLink('selectToneQuality') selectToneQuality: number = ToneQuality.SQ;
  @StorageLink('songList') songList: SongItem[] = [];
  @StorageLink('selectIndex') selectIndex: number = 0;

  @Link isShowToneQualityList: boolean;

  private scroller: Scroller = new Scroller();

  @Builder
  toneQualityListTitle() {
    Row() {
      Text($r('app.string.switch_sound_quality'))
        .maxLines(1)
        .padding({ left: 5 })
        .fontColor(Color.Black)
        .fontSize(16)
    }
    .height(60)
    .width('100%')
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius({
      topRight: 20,
      topLeft: 20
    })
    .position({
      x: 0,
      y: 0
    })
  }

  @Builder
  ToneQualityListContainer(item: number) {
    Column() {
      Row() {
        Column() {
          Text(MediaTools.fetchToneQualityTitle(item))
            .fontColor(this.selectToneQuality === item ? Color.Red : Color.Black)
            .fontSize(14)
            .margin({ bottom: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .onClick(async () => {
        if (this.selectToneQuality !== item) {
          this.selectToneQuality = item;
          this.isShowToneQualityList = false;
        }
      })
      .height(60)
      .width('100%')
    }
    .padding({
      left: 14,
      right: 14
    })
  }

  build() {
    Column() {
      this.toneQualityListTitle();
      List({ scroller: this.scroller }) {
        ForEach(this.songList[this.selectIndex].toneQualityList, (item: number) => {
          ListItem() {
            this.ToneQualityListContainer(item);
          }
        }, (item: SongItem, index: number) => item.toString() + index.toString())
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 60 })
      .layoutWeight(1)
      .divider({
        color: "#1A182431",
        strokeWidth: 0.5,
        startMargin: 14,
        endMargin: 14
      })
    }
    .padding({
      bottom: 48
    })
    .backgroundColor(Color.White)
  }
}