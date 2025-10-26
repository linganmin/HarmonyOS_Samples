/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { avSession } from "@kit.AVSessionKit";
import Constants from "../common/Constants";
import { ProviderFeature } from "../viewmodel/ProviderManager";
import MediaData from "../model/MediaData";

@Component
export struct MusicHomeView {
  @StorageLink('SeekPosition') seekPosition: number = 0;
  @StorageLink('CurrentLoopMode') currentLoopMode: avSession.LoopMode.LOOP_MODE_SEQUENCE = 0;
  @StorageLink('IsPlaying') isPlaying: boolean = false;
  @StorageLink('isFavorMap') isFavorMap: Map<String, boolean> | null = null;
  @StorageLink('CurrentPlayItem') currentPlayItem: avSession.AVQueueItem | null = null;
  @StorageLink('CurrentAVMetadata') currentAVMetadata: avSession.AVMetadata | null = null;
  @StorageLink('CurrentImage') currentImage: PixelMap | null = null;
  private providerFeature: ProviderFeature | undefined = undefined;

  async aboutToAppear() {
    this.providerFeature = await ProviderFeature.getInstance();
  }

  aboutToDisappear() {
    this.providerFeature!.unInit();
  }

  onPageHide() {
    // The application page is returned to the background, and a long-time task keep-alive playback is applied for.
    this.providerFeature!.startContinuousTask();
  }

  build() {
    Stack() {
      Progress({ value: this.seekPosition, type: ProgressType.Ring})
        .color(Color.Red)
        .width(Constants.PERCENT_FULL)
        .height(Constants.PERCENT_FULL)
      Column() {
        this.topView();
        this.midView();
        this.bottomView();
      }
      .width(Constants.PERCENT_FULL)
      .height(Constants.PERCENT_FULL)
    }
    .width(Constants.PERCENT_FULL)
    .height(Constants.PERCENT_FULL)
  }

  @Builder
  topView() {
    Column() {
      Text(this.currentAVMetadata!.title ? this.currentAVMetadata!.title: 'No title')
        .width('60%')
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Normal)
        .textAlign(TextAlign.Center)

      Text(this.currentAVMetadata!.artist ? this.currentAVMetadata!.artist : 'No artist')
        .width('80%')
        .height(19)
        .margin({ top: 5 })
        .fontSize(14)
        .fontColor('#535356')
        .textAlign(TextAlign.Center)
    }
    .width(Constants.PERCENT_FULL)
    .height(40)
    .margin({ top: 26 })
  }

  @Builder
  midView() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      Button({ stateEffect: true }) {
        Image($r('app.media.ic_previous'))
      }
      .width(30)
      .aspectRatio(1)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.providerFeature!.previous();
      })

      Button({ stateEffect: true }) {
        Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
      }
      .height(88)
      .aspectRatio(1)
      .backgroundColor(Color.Transparent)
      .id('PlayOrPause')
      .onClick(async () => {
        if (!this.isPlaying) {
          await this.providerFeature!.play();
        } else {
          await this.providerFeature!.pause();
        }
      })

      Button({ stateEffect: true }) {
        Image($r('app.media.ic_next'))
      }
      .width(30)
      .aspectRatio(1)
      .backgroundColor(Color.Transparent)
      .id('Next')
      .onClick(async () => {
        this.providerFeature!.next();
      })
    }
    .width(Constants.PERCENT_FULL)
    .padding({
      left: 24,
      right: 24,
      top: 8
    })
  }

  @Builder
  bottomView() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      Button({ stateEffect: true }) {
        Image(this.isFavorMap!.get(this.currentAVMetadata!.assetId) ? $r('app.media.ic_public_favor_filled') :
        $r('app.media.ic_public_favor'))
          .width(24)
          .height(24)
      }
      .backgroundColor(Color.Transparent)
      .id('Favorite')
      .onClick(async () => {
        await this.providerFeature!.toggleFavorite();
      })

      Button({ stateEffect: true }) {
        Image(MediaData.loopModeList[this.currentLoopMode!])
          .width(24)
          .height(24)
      }
      .backgroundColor(Color.Transparent)
      .id('LoopMode')
      .onClick(async () => {
        this.providerFeature!.loopMode();
      })
    }
    .width(Constants.PERCENT_FULL)
    .padding({
      left: 48,
      right: 48,
      top: 6
    })
  }
}