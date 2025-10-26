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

import { AVPlayerItem } from '../view/AVPlayerItem';
import SampleUnitAVPlayView from '../view/SampleUnitAVPlayView';
import { displaySync } from '@kit.ArkGraphics2D';
import { router } from '@kit.ArkUI';
import { CONSTANT } from '../constant/Constant';

@Entry
@Component
struct NewPlayPage {
  @State rotateAngle: number = 0;
  @State avPlayer: AVPlayerItem = new AVPlayerItem();
  private backDisplaySync: displaySync.DisplaySync | undefined = undefined;

  aboutToAppear(): void {
    this.avPlayer.avPlayerPlay(this.getUIContext());
    if (this.backDisplaySync === undefined) {
      this.CreateDisplaySync();
    }
    if (this.backDisplaySync) {
      this.backDisplaySync.start();
    }
  }

  aboutToDisappear() {
    if (this.backDisplaySync) {
      this.backDisplaySync.stop();
      this.backDisplaySync = undefined;
    }
  }

  CreateDisplaySync() {
    let range: ExpectedFrameRateRange = {
      expected: 30,
      min: 0,
      max: 120
    };
    let draw = (intervalInfo: displaySync.IntervalInfo) => {
      if (this.rotateAngle === 360) {
        this.rotateAngle = 0;
      }
      this.rotateAngle += 15;
    };
    this.backDisplaySync = displaySync.create();
    this.backDisplaySync.setExpectedFrameRateRange(range);
    this.backDisplaySync.on("frame", draw);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .fillColor(Color.White)
          .margin({ left: CONSTANT.COMMON_DISTANCE })
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })
          .width(CONSTANT.STATIC_ICON_SIZE)
          .height(CONSTANT.STATIC_ICON_SIZE)
          .objectFit(ImageFit.Contain)
      }
      .justifyContent(FlexAlign.Start)
      .width(CONSTANT.FULL_SIZE)

      SampleUnitAVPlayView({
        avPlayer: $avPlayer
      });

      Row() {
        Image($r('app.media.avatar'))
          .width(40)
          .height(40)
          .margin(20)
          .borderRadius(100)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '50%',
            centerY: '50%',
            angle: this.rotateAngle
          })
      }
      .width(CONSTANT.FULL_SIZE)
      .justifyContent(FlexAlign.End)
    }
    .height(CONSTANT.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.Black)
  }
}