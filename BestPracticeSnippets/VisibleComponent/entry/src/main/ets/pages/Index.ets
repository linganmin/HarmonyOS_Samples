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

// [Start segment1]
// VisibleComponent/entry/src/main/ets/pages/Index.ets
import { apng, ApngController } from '@ohos/apng';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct RefreshExample {
  @State isRefreshing: boolean = false;
  @State isRunning: boolean = false;
  @State arr: string[] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  controller: ApngController = new ApngController();

  @Builder
  customRefreshComponent() {
    Stack() {
      Row() {
        Column() {
          apng({
            src: $r('app.media.stack'),
            controller: this.controller
          })
            .margin({ top: 40 })
        }
      }
      .alignItems(VerticalAlign.Center)
    }
    .align(Alignment.Center)
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.customRefreshComponent() }) {
        Scroll() {
          Column() {
            ImageAnimatorTest()
            ForEach(this.arr, (item: string) => {
              ListItem() {
                Text('' + item)
                  .height(80)
                  .fontSize(16)
                  .textAlign(TextAlign.Center)
                  .fontColor(0xF1F3F5)
              }
            }, (item: string) => item)
          }
        }
        .scrollBar(BarState.Off)
      }
      .backgroundColor(0xF1F3F5)
      .pullToRefresh(true)
      .refreshOffset(64)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      // Use onStateChange and apngcontroller to control play and stop
      .onStateChange((refreshStatus: RefreshStatus) => {
        if (refreshStatus >= 1 && refreshStatus < 4) {
          this.controller.play();
        } else {
          this.controller.stop();
        }
        hilog.info(0x0000, 'testTag', 'Refresh onStatueChange state is ' + refreshStatus);
      })
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefreshing = false;
        }, 2000)
        hilog.info(0x0000, 'testTag', 'onRefreshing test')
      })
    }
  }
}

// [End segment1]

// [Start segment2]
// VisibleComponent/entry/src/main/ets/pages/Index.ets
@Component
struct ImageAnimatorTest {
  private uid: number = -1;
  private index: number = 0;
  @State running: boolean = false;
  @State animState: AnimationStatus = AnimationStatus.Initial;

  // Method 1: use aboutToAppear to register a setOnVisibleAreaApproximateChange
  aboutToAppear(): void {
    this.uid = this.getUniqueId();
    hilog.info(0x0000, 'testTag', `getUniqueId in ImageAnimatorTest aboutAppear is ${this.uid}`);
    let node = this.getUIContext().getFrameNodeByUniqueId(this.uid);
    node?.commonEvent.setOnVisibleAreaApproximateChange(
      { ratios: [0], expectedUpdateInterval: 500 },
      (isVisible, currentRatio) => {
        hilog.info(0x0000, 'testTag',
          `Method aboutToAppear: setOnVisibleAreaApproximateChange isVisible:${isVisible}, currentRatio:${currentRatio}`);
        this.running = isVisible;
      })
  }

  build() {
    Column() {
      ImageAnimator()
        .images([
          { src: $r('app.media.background') },
          { src: $r('app.media.foreground') }
        ])
        .id(`ImageAnimator${this.index}}`)
        .width('100%')
        .height('30%')
        .duration(3000)
        .fillMode(FillMode.None)
        .iterations(-1)
        .state(this.running ? AnimationStatus.Running :
        AnimationStatus.Paused)// Method 2: Directly use onVisibleAreaChange
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
          hilog.info(0x0000, 'testTag',
            `Method Direct: onVisibleAreaChange isVisible:${isVisible}, currentRatio:${currentRatio}`);
          if (isVisible && currentRatio >= 1.0) {
            this.running = true;
          }
          if (!isVisible && currentRatio <= 0.0) {
            this.running = false;
          }
        })// Method 3: use onAppear to register a setOnVisibleAreaApproximateChange
        .onAppear(() => {
          let node = this.getUIContext().getFrameNodeById(`ImageAnimator${this.index}`);
          node?.commonEvent.setOnVisibleAreaApproximateChange(
            { ratios: [0], expectedUpdateInterval: 500 },
            (isVisible, currentRatio) => {
              this.running = isVisible;
              hilog.info(0x0000, 'testTag',
                `Method onAppear: setOnVisibleAreaApproximateChange isVisible:${isVisible}, currentRatio:${currentRatio}`);
            }
          )
        })
    }
  }
}

// [End segment2]