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

import { SongItem } from '../model/SongData';
import { SongDataSource } from '../model/SongDataSource';
import { MusicPlayPage } from './MusicPlayPage';
import { songList } from '../model/SongListData';
import { RouterConstants } from '../common/constants/RouterConstants';

@Entry
@Component
struct Index {
  @StorageLink(RouterConstants.NAV_PATH_STACK_CONSTANTS) musicPageStack: NavPathStack = new NavPathStack();
  @StorageLink('songList') songList: SongItem[] = [];
  @Provide(RouterConstants.NAV_PATH_STACK_CONSTANTS) pageStack: NavPathStack = new NavPathStack()

  @Builder
  PagesMap(name: string, param: number) {
    MusicPlayPage();
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('songList', songList);
  }

  build() {
    Navigation(this.musicPageStack) {
      Column() {
        Row() {
          Text($r('app.string.EntryAbility_label'))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .height(112)
        .width('100%')
        .padding({
          bottom: 8
        })
        .alignItems(VerticalAlign.Bottom)

        Scroll() {
          List({ space: 20 }) {
            LazyForEach(new SongDataSource(this.songList), (item: SongItem, index: number) => {
              ListItem() {
                MusicItem({ item: item })
              }
              .onClick(() => {
                this.musicPageStack.pushPath({ name: 'play', param: index });
                AppStorage.setOrCreate('selectIndex', index);
              })
            }, (item: SongItem, index: number) => item.toString() + index.toString())
          }
          .height('100%')
          .width('100%')
          .backgroundColor(Color.White)
          .layoutWeight(1)
          .cachedCount(2)
          .divider({
            strokeWidth: 1,
            startMargin:  0,
            endMargin:  12,
            color: '#1A182431'
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin(24)
    }
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
  }
};

@Reusable
@Component
struct MusicItem {
  @Prop item: SongItem;

  build() {
    Row() {
      Image(this.item.label)
        .width(48)
        .height(48)
        .borderRadius(12)
      Column() {
        Text(this.item.title)
          .fontSize(16)
          .lineHeight(22)
        Text(this.item.singer)
          .fontSize(14)
          .fontColor($r('sys.color.mask_secondary'))
          .lineHeight(22)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
    }
    .width('100%')
  }
}
