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

import { DeliveryLiveViewController } from '../utils/DeliveryLiveViewUtil';
import { Logger } from '../utils/LogUtil';
import { BottomTip } from '../components/BottomTip';
import { InstantPageButton } from '../components/InstantPageButton';

@Builder
export function InstantDeliveryBuilder() {
  InstantDelivery();
}

@Entry
@Component
struct InstantDelivery {
  @State liveViewController: DeliveryLiveViewController = new DeliveryLiveViewController();
  @State updateInterval: number = 15 * 1000;
  @Consume('timeOutIdDelivery') timeOutId: number | undefined;
  @Consume('isProcessingDelivery') isProcessing: boolean;
  pathStack: NavPathStack = AppStorage.get('PathStack') as NavPathStack

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r("app.media.delivery_4x"))
          .width('auto')
          .height('70%')
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
          InstantPageButton({ buttonText: $r('app.string.Delivery_submit'), click: this.startLiveView })
          InstantPageButton({ buttonText: $r('app.string.Delivery_update'), click: this.updateLiveView })
          InstantPageButton({ buttonText: $r('app.string.Delivery_stop'), click: this.stopLiveView })
        }
        .height(144)
        .margin({ top: 30 })

        BottomTip()
      }
      .width('100%')
      .height('100%')
    }
    .title('即时配送')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }

  private startLiveView = async () => {
    //Submit the order and create a liveView
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
      Logger.info('updateLiveView isProcessing and return');
      return;
    }
    try {
      Logger.info('updateLiveView not isProcessing');
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