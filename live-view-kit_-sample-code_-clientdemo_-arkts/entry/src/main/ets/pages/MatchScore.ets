/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BottomTip } from '../components/BottomTip';
import { InstantPageButton } from '../components/InstantPageButton';
import { ScoreLiveViewController } from '../utils/ScoreLiveViewUtil';

@Builder
export function MatchScoreBuilder() {
  MatchScore();
}

@Entry
@Component
struct MatchScore {
  @State liveViewController: ScoreLiveViewController = new ScoreLiveViewController();
  @State updateInterval: number = 15 * 1000;
  @Consume('timeOutIdScore') timeOutId: number | undefined;
  @Consume('isProcessingScore') isProcessing: boolean;
  pathStack: NavPathStack = AppStorage.get('PathStack') as NavPathStack

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r("app.media.score"))
          .width('auto')
          .height('50%')
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
          InstantPageButton({ buttonText: $r('app.string.Score_submit'), click: this.startLiveView })
          InstantPageButton({ buttonText: $r('app.string.Score_update'), click: this.updateLiveView })
          InstantPageButton({ buttonText: $r('app.string.Score_stop'), click: this.stopLiveView })
        }
        .height(144)
        .margin({ top: 30 })

        BottomTip()
      }
    }
    .title('赛事比分')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }

  private startLiveView = async () => {
    //Submit the order and create liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      await this.liveViewController.startLiveView();
      this.timeOutId = setTimeout(this.updateLiveView, this.updateInterval);
    } finally {
      this.isProcessing = false;
    }
  }
  private updateLiveView = async () => {
    //Update progress, update liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      const hasNext = await this.liveViewController.updateLiveView();
      if (hasNext) {
        this.timeOutId = setTimeout(this.updateLiveView, this.updateInterval);
      }
    } finally {
      this.isProcessing = false;
    }
  }
  private stopLiveView = async () => {
    //End the progress and destroy the liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      await this.liveViewController.stopLiveView();
    } finally {
      this.isProcessing = false;
    }
  }
}