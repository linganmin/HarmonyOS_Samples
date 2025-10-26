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
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import CommonConstants from '../common/CommonConstants'
import { promptAction } from '@kit.ArkUI';

@Component
export struct ArkTSPerfTag {
  @Consume('pageInfos') pageInfos: NavPathStack;
  // Used for avoiding the status bar.
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.ArkTSPerfTag_Title'));

  // Calculate the results of the Fibonacci sequence.
  doFib(n: number): number {
    if (n <= 0) {
      return 0;
    } else if (n === 1) {
      return 1;
    } else {
      return this.doFib(n - 1) + this.doFib(n - 2);
    }
  }

  case() {
    // HiTraceMeter Start tagging.
    hiTraceMeter.startTrace(CommonConstants.TASK_NAME, CommonConstants.TASK_ID);
    this.doFib(CommonConstants.FIB_VALUE);
    // HiTraceMeter Finish tagging.
    hiTraceMeter.finishTrace(CommonConstants.TASK_NAME, CommonConstants.TASK_ID);
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.ArkTSPerfTag_Button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
          .fontSize(CommonConstants.BUTTON_FONT_SIZE)
          .onClick(() => {
            this.case();
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.ArkTSPerfTag_Toast'),
              duration: CommonConstants.TOAST_DURATION
            })
          })
      }
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.FULL_PARENT)
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .padding({ top: this.topRectHeight, bottom: this.bottomRectHeight })
    .backgroundColor($r('app.color.window_background_color'))
    .title(this.title)
  }
}
