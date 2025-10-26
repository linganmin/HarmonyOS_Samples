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

/**
 * 最佳实践：Vsync低功耗优化
 */

import { displaySync } from '@kit.ArkGraphics2D';

@Entry
@Component
struct MyDisplaySyncComponent {
  @State drawFirstSize: number = 25;
  @State drawSecondSize: number = 25;
  private backDisplaySyncSlow: displaySync.DisplaySync | undefined = undefined;
  private backDisplaySyncFast: displaySync.DisplaySync | undefined = undefined;
  private isBigger_30: boolean = true;
  private isBigger_60: boolean = true;

  @Builder doSomeRenderFirst() {
    Text('30')
      .fontSize(this.drawFirstSize)
  }

  @Builder doSomeRenderSecond() {
    Text('60')
      .fontSize(this.drawSecondSize)
  }

  CreateDisplaySyncSlow() {
    let range: ExpectedFrameRateRange = {
      expected: 30,
      min: 0,
      max: 120
    };

    let draw30 = (intervalInfo: displaySync.IntervalInfo) => {
      if (this.isBigger_30) {
        this.drawFirstSize += 1;
        if (this.drawFirstSize > 150) {
          this.isBigger_30 = false;
        }
      } else {
        this.drawFirstSize -= 1;
        if (this.drawFirstSize < 25) {
          this.isBigger_30 = true;
        }
      }
    };

    this.backDisplaySyncSlow = displaySync.create();
    this.backDisplaySyncSlow.setExpectedFrameRateRange(range);
    this.backDisplaySyncSlow.on("frame", draw30);
  }

  CreateDisplaySyncFast() {
    let range: ExpectedFrameRateRange = {
      expected: 60,
      min: 0,
      max: 120
    };

    let draw60 = (intervalInfo: displaySync.IntervalInfo) => {
      if (this.isBigger_60) {
        this.drawSecondSize += 1;
        if (this.drawSecondSize > 150) {
          this.isBigger_60 = false;
        }
      } else {
        this.drawSecondSize -= 1;
        if (this.drawSecondSize < 25) {
          this.isBigger_60 = true;
        }
      }
    };

    this.backDisplaySyncFast = displaySync.create();
    this.backDisplaySyncFast.setExpectedFrameRateRange(range);
    this.backDisplaySyncFast.on("frame", draw60);
  }

  // [Start vsync_power_case_1]
  // 组件卸载时，停止DisplaySync并置空，防止空跑与内存泄露
  aboutToDisappear() {
    if (this.backDisplaySyncSlow) {
      this.backDisplaySyncSlow.stop();
      this.backDisplaySyncSlow = undefined;
    }
    if (this.backDisplaySyncFast) {
      this.backDisplaySyncFast.stop();
      this.backDisplaySyncFast = undefined;
    }
  }
  // [End vsync_power_case_1]

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      // 30FPS 动态文本
      Row() {
        this.doSomeRenderFirst()
      }
      .width('80%')
      .height('auto')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 })

      // 60FPS 动态文本
      Row() {
        this.doSomeRenderSecond()
      }
      .width('80%')
      .height('auto')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 })

      // 操作按钮区域
      Row() {
        Button('Start')
          .id('CustomDrawStart')
          .fontSize(14)
          .fontWeight(500)
          .margin({ left: 10 })
          .fontColor(Color.White)
          .onClick((): void => {
            if (this.backDisplaySyncSlow == undefined) {
              this.CreateDisplaySyncSlow();
            }
            if (this.backDisplaySyncFast == undefined) {
              this.CreateDisplaySyncFast();
            }
            if (this.backDisplaySyncSlow) {
              this.backDisplaySyncSlow.start();
            }
            if (this.backDisplaySyncFast) {
              this.backDisplaySyncFast.start();
            }
          })
          .layoutWeight(1)
          .height(40)
          .shadow(ShadowStyle.OUTER_DEFAULT_LG)

        Button('Stop')
          .id('CustomDrawStop')
          .fontSize(14)
          .fontWeight(500)
          .margin({ left: 10 })
          .fontColor(Color.White)
          .onClick((): void => {
            if (this.backDisplaySyncSlow) {
              this.backDisplaySyncSlow.stop();
            }
            if (this.backDisplaySyncFast) {
              this.backDisplaySyncFast.stop();
            }
          })
          .layoutWeight(1)
          .height(40)
          .shadow(ShadowStyle.OUTER_DEFAULT_LG)
      }
      .width('80%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    // [Start vsync_power_case_2]
    // 当组件不可见时，暂停DisplaySync对象
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (!isExpanding && currentRatio <= 0.0) {
        console.info('Component is completely invisible.');
        if (this.backDisplaySyncSlow) {
          this.backDisplaySyncSlow.stop();
        }
        if (this.backDisplaySyncFast) {
          this.backDisplaySyncFast.stop();
        }
      }
    })
    // [End vsync_power_case_2]
  }
}