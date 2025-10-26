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

import { displaySync } from '@kit.ArkGraphics2D';

@Component
export struct RotatingCover {
  @StorageLink('isPlay') @Watch('animationFun') isPlay: boolean = false;
  @State imageRotate: number = 0;
  @Prop songLabel: Resource;
  private backDisplaySyncSlow: displaySync.DisplaySync | undefined = undefined;
  private drawFrame = () => {
    if (this.imageRotate >= 360) {
      this.imageRotate = 0;
    }
    this.imageRotate += 1;
  };

  animationFun() {
    if (this.isPlay) {
      this.backDisplaySyncSlow?.start();
    } else {
      this.backDisplaySyncSlow?.stop();
    }
  }

  aboutToAppear() {
    let range: ExpectedFrameRateRange = {
      expected: 30,
      min: 0,
      max: 30
    };

    this.backDisplaySyncSlow = displaySync.create();
    this.backDisplaySyncSlow.setExpectedFrameRateRange(range);
    this.backDisplaySyncSlow.on('frame', this.drawFrame);
  }

  aboutToDisappear(): void {
    this.backDisplaySyncSlow?.off('frame', this.drawFrame);
  }

  build() {
    Column() {
      Image(this.songLabel)
        .height(32)
        .width(32)
        .borderRadius(16)
        .margin({ right: 12 })
        .rotate({ angle: this.imageRotate })
        .onAppear(() => {
          this.animationFun();
        })
    }
  }
}

