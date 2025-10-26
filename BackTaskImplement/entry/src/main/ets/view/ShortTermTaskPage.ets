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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ShortTermTaskModel } from '../viewModel/ShortTermTaskModel';
import SuspendTaskUtils from '../utils/SuspendTaskUtils';

const TAG: string = '[ShortTermTaskPage]';

@Component
export struct ShortTermTaskPage {
  private shortTermTaskModel: ShortTermTaskModel = new ShortTermTaskModel();
  private messageCount: number = 0;
  private taskTimer = 0;

  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
    .margin({ bottom: 12 })
  }

  @Builder
  builderTitle() {
    Row() {
      Text($r('app.string.short_time_task'))
        .fontWeight(FontWeight.Bold)
        .maxFontSize(20)
        .minFontSize(10)
        .maxLines(2)
    }
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .margin({
      left: 8
    })
  }

  build() {
    // [Start NavDestination_start]
    NavDestination() {
      // [StartExclude NavDestination_start]
      Column() {
        Button($r('app.string.get_remaining_time'))
          .buttonStyles()
          .onClick(async () => {
            try {
              let delayTime = await SuspendTaskUtils.getRemainingDelayTime(this.shortTermTaskModel.suspendTaskInfo.id);
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.remaining_time', delayTime)
              });
            } catch (err) {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.remain_time_fail')
              });
            }
          })
        Button($r('app.string.cancel_short_task'))
          .buttonStyles()
          .onClick(() => {
            let isCancelSuspendDelay = SuspendTaskUtils.cancelSuspendDelay(this.shortTermTaskModel.suspendTaskInfo.id);
            this.getUIContext().getPromptAction().showToast({
              message: isCancelSuspendDelay ? $r('app.string.cancel_short_success') :
              $r('app.string.cancel_short_failed')
            });
          })
      }
      .padding({
        right: 16,
        left: 16
      })
      .justifyContent(FlexAlign.End)
      .height('100%')
      .width('100%')
      // [EndExclude NavDestination_start]
    }
    .title(this.builderTitle())
    .onAppear(() => {
      this.shortTermTaskModel.subscribeStateChange();
      this.taskTimer = setInterval(() => {
        this.messageCount++;
        hilog.info(0x0000, TAG, `already sent ：${this.messageCount} messages`);
      }, 2000);
    })
    // [End NavDestination_start]
    .onDisAppear(() => {
      clearInterval(this.taskTimer);
      SuspendTaskUtils.cancelSuspendDelay(this.shortTermTaskModel.suspendTaskInfo.id);
      this.shortTermTaskModel.offAppStateChange();
    })
  }
}