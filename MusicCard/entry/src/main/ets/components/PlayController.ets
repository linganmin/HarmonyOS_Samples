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

import { PlayerView } from './PlayerView';
import { SongItem } from '../viewmodel/SongItem';
import { MediaService } from '../utils/MediaService';
import { PlayList } from './PlayList';
import { RotatingCover } from '../components/RotatingCover';

// [Start play_controller]
// [Start music_control_card_pull_pages]
// src/main/ets/components/PlayController.ets
@Component
export struct PlayController {
  // [StartExclude music_control_card_pull_pages]
  @StorageLink('isPlay') isPlay: boolean = false;
  // [StartExclude play_controller]
  @StorageProp('currentSong') currentSong: SongItem | undefined = undefined;
  // [EndExclude music_control_card_pull_pages]
  @StorageLink('isShowPlay') isShowPlay: boolean = false;
  // [StartExclude music_control_card_pull_pages]
  @StorageProp('windowHeight') windowHeight: number = 0;
  @StorageLink('songList') songList: SongItem[] = [];
  @State translateY: number = 0;
  @State isShowSheet: boolean = false;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Vertical });

  @Builder
  PlayListSheet() {
    PlayList()
      .width('100%')
      .height('100%')
  }
  // [EndExclude play_controller]
  // [EndExclude music_control_card_pull_pages]

  build() {
    Row() {
      Row() {
        // [StartExclude play_controller]
        // [StartExclude music_control_card_pull_pages]
        RotatingCover({ songLabel: this.currentSong?.label })

        Column() {
          Text($r(this.currentSong?.title))
            .fontSize(14)
            .fontWeight(500)
          Row() {
            Image($r('app.media.ic_vip'))
              .height(16)
              .width(16)
              .margin({ right: 4 })
            Text($r(this.currentSong?.singer))
              .fontSize(10)
              .fontColor('#4D000000')
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      // [EndExclude play_controller]
      // [EndExclude music_control_card_pull_pages]
      .onClick(() => {
        this.isShowPlay = true;
      })
      // [StartExclude play_controller]
      // [StartExclude music_control_card_pull_pages]
      Row() {
        Image($r('app.media.ic_previous'))
          .height(24)
          .width(24)
          .margin({ right: 16 })
          .displayPriority(2)
          .onClick(() => {
            MediaService.getInstance().playPrevious();
          })

        Image(this.isPlay ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
          .height(24)
          .width(24)
          .displayPriority(3)
          .onClick(() => {
            this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play();
          })

        Image($r('app.media.ic_next'))
          .height(24)
          .width(24)
          .margin({
            right: 16,
            left: 16
          })
          .displayPriority(2)
          .onClick(() => {
            MediaService.getInstance().playNext();
          })

        Image($r('app.media.ic_music_list'))
          .height(24)
          .width(24)
          .displayPriority(1)
          .bindSheet($$this.isShowSheet, this.PlayListSheet(), {
            height: '65%',
            dragBar: true,
            showClose: true,
            title: { title: $r('app.string.current_play_list', this.songList.length) }
          })
          .onClick(() => {
            this.isShowSheet = !this.isShowSheet;
          })
      }
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F6F9FC')
    // [EndExclude play_controller]
    .bindContentCover($$this.isShowPlay, this.MusicPlayBuilder(), {
      // [StartExclude play_controller]
      transition: TransitionEffect.translate({ y: this.windowHeight })
        .animation({
          duration: 300,
          curve: Curve.Smooth
        })
    }
      // [EndExclude play_controller]
    )
    // [StartExclude play_controller]
    .padding({
      left: 16,
      right: 16
    })
    // [EndExclude play_controller]
    // [EndExclude music_control_card_pull_pages]
  }

  @Builder
  MusicPlayBuilder() {
    PlayerView({ isShowPlay: this.isShowPlay })
      .height('100%')
      .width('100%')
        // [StartExclude play_controller]
      // [StartExclude music_control_card_pull_pages]
      .onDisAppear(() => {
        this.translateY = 0;
      })
      .translate({ y: this.translateY })
      .gesture(
        PanGesture(this.panOption)
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.translateY = event.offsetY;
              if (this.translateY < 0) {
                this.translateY = 0;
                return;
              }
            }
          })
          .onActionEnd(() => {
            if (this.translateY > this.windowHeight / 2) {
              this.isShowPlay = false;
            } else {
              this.getUIContext().animateTo({
                duration: 300,
                curve: Curve.Smooth
              }, () => {
                this.translateY = 0;
              })
            }
          })
      )
    // [EndExclude play_controller]
    // [EndExclude music_control_card_pull_pages]
  }
}
// [End play_controller]
// [End music_control_card_pull_pages]