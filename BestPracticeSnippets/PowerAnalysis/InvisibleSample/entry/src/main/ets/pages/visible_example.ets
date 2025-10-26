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
 * 最佳实践：不可见组件低功耗建议
 */

import { ApngController } from '@ohos/apng';
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
        Column() {}
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
            // ImageAnimatorTest()
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
// [Start nonvisible_advise_1]
      .onStateChange((refreshStatus: RefreshStatus) => {
          // status = 0 ： 默认未下拉
          // status = 1、2：下拉中
          // status = 3：下拉完成，回弹中
          // status = 4：刷新结束，返回初始状态
        if (refreshStatus >= 1 && refreshStatus < 4) {
          this.controller.play();
        } else {
          this.controller.stop();
        }
        hilog.info(0x0000, 'testTag', 'Refresh onStatueChange state is ' + refreshStatus);
      })
// [End nonvisible_advise_1]
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefreshing = false;
        }, 2000)
        hilog.info(0x0000, 'testTag', 'onRefreshing test')
      })
    }
  }
}

