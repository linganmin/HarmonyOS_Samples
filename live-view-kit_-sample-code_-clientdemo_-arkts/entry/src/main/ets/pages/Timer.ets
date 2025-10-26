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
import { TimerController } from '../utils/TimerUtil';

@Builder
export function TimerBuilder() {
  Timer();
}

@Entry
@Component
struct Timer {
  @State liveViewController: TimerController = new TimerController();
  @State updateInterval: number = 15 * 1000;
  @State isProcessing: boolean = false;
  pathStack: NavPathStack = AppStorage.get('PathStack') as NavPathStack

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Flex({ justifyContent: FlexAlign.Center }) {
        }
        .backgroundImage($r("app.media.timer"), ImageRepeat.NoRepeat)
        .backgroundImagePosition(Alignment.Center)
        .backgroundImageSize(ImageSize.Contain)
        .width('90%')
        .height('70%')
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
          InstantPageButton({ buttonText: $r('app.string.start_order_timer'), click: this.startLiveView })
          InstantPageButton({ buttonText: $r('app.string.start_reOrder_timer'), click: this.startReOrderLiveView })
          InstantPageButton({ buttonText: $r('app.string.pause_timer'), click: this.pauseTimer })
          InstantPageButton({ buttonText: $r('app.string.continue_timer'), click: this.continueTimer })
          InstantPageButton({ buttonText: $r('app.string.end_timer'), click: this.stopLiveView })
        }
        .height(300)
        .margin({ top: 30 })

        BottomTip({ textContent: `点击"正计时"或"倒计时"按钮开始计时` })
      }
    }
    .title('计时')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }

  private startLiveView = async () => {
    //Start timing and create liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      await this.liveViewController.startLiveView();
    } finally {
      this.isProcessing = false;
    }
  }
  private startReOrderLiveView = async () => {
    //Start countdown and create liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      await this.liveViewController.startLiveView(true);
    } finally {
      this.isProcessing = false;
    }
  }

  private pauseTimer = async () => {
    //Pause timing and update liveView
    if (this.isProcessing) {
      return;
    }
    await this.liveViewController.pauseTimer();
  }

  private continueTimer = async () => {
    //Continue timing and update liveView
    if (this.isProcessing) {
      return;
    }
    await this.liveViewController.continueTimer();
  }

  private stopLiveView = async () => {
    //End the timer and destroy liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      await this.liveViewController.stopLiveView();
    } finally {
      this.isProcessing = false;
    }
  }
}