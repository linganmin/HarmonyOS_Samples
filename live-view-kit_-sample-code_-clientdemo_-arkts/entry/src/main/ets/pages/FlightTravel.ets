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
import { FlightLiveViewController } from '../utils/FlightLiveViewUtil';
import { InstantPageSplit } from '../components/InstantPageSplit';

@Builder
export function FlightTravelBuilder() {
  FlightTravel();
}

@Entry
@Component
struct FlightTravel {
  @State liveViewController: FlightLiveViewController = new FlightLiveViewController();
  @State updateInterval: number = 15 * 1000;
  @Consume('timeOutIdFlight') timeOutId: number | undefined;
  @Consume('isProcessingFlight') isProcessing: boolean;
  pathStack: NavPathStack = AppStorage.get('PathStack') as NavPathStack;

  aboutToAppear(): void {
    console.log(this.timeOutId + ':zhm:' + this.isProcessing)
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Flex({ justifyContent: FlexAlign.Center }) {
        }
        .backgroundImage($r("app.media.flight"), ImageRepeat.NoRepeat)
        .backgroundImagePosition(Alignment.Center)
        .backgroundImageSize(ImageSize.Contain)
        .width('90%')
        .height('70%')
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
          InstantPageButton({ buttonText: $r('app.string.Flight_commit'), click: this.startLiveView })
          InstantPageButton({ buttonText: $r('app.string.Flight_update'), click: this.updateLiveView })
          InstantPageButton({ buttonText: $r('app.string.Flight_stop'), click: this.stopLiveView })
          InstantPageSplit()
          InstantPageButton({ buttonText: $r('app.string.Flight_delayed'), click: this.delayedLiveView })
          InstantPageButton({ buttonText: $r('app.string.Flight_cancellation'), click: this.cancelLiveView })
          InstantPageButton({ buttonText: $r('app.string.Flight_rescheduling'), click: this.rescheduleLiveView })
          InstantPageButton({ buttonText: $r('app.string.Flight_refund_ticket'), click: this.refundTicketLiveView })
        }
        .height(400)
        .margin({ top: 30 })

        BottomTip()
      }
    }
    .title('航旅出行')
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
      const hasNext = await this.liveViewController.startLiveView();
      if (hasNext) {
        this.timeOutId = setTimeout(this.updateLiveView, this.updateInterval);
      }
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
    // End the progress and destroy the liveView
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

  private delayedLiveView = async () => {
    //Flight delayed, update liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      const hasNext = await this.liveViewController.delayedLiveView();
      if (hasNext) {
        this.timeOutId = setTimeout(this.updateLiveView, this.updateInterval);
      }
    } finally {
      this.isProcessing = false;
    }
  }

  private rescheduleLiveView = async () => {
    //Flight rescheduling, update liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      const hasNext = await this.liveViewController.rescheduleLiveView();
      if (hasNext) {
        this.timeOutId = setTimeout(this.updateLiveView, this.updateInterval);
      }
    } finally {
      this.isProcessing = false;
    }
  }

  private refundTicketLiveView = async () => {
    //User ticket refund, destroy the liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      await this.liveViewController.refundTicketLiveView();
    } finally {
      this.isProcessing = false;
    }
  }

  private cancelLiveView = async () => {
    //Flight cancellation, destroy the liveView
    if (this.isProcessing) {
      return;
    }
    try {
      this.isProcessing = true;
      if (this.timeOutId != undefined) {
        clearTimeout(this.timeOutId);
        this.timeOutId = undefined;
      }
      await this.liveViewController.cancelLiveView();
    } finally {
      this.isProcessing = false;
    }
  }

}