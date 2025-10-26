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

 import { hilog } from "@kit.PerformanceAnalysisKit";

/**
 * 最佳实践：不可见组件低功耗建议
 */

// [Start nonvisible_page_1]
@Component
struct MyImageAnimator {
  @State running: boolean = false;
  @State animState: AnimationStatus = AnimationStatus.Initial;

  build() {
    ImageAnimator()
      .images([
        {
          src: $r('app.media.background')
        },
        {
          src: $r('app.media.foreground')
        }
      ])
      .width('60%')
      .height('60%')
      .fillMode(FillMode.None)
      .iterations(-1)
      .duration(1000)
      .state(this.running ? AnimationStatus.Running : AnimationStatus.Paused)
      .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
        if (isExpanding && currentRatio >= 1.0) {
            hilog.info(0x0000, 'Sample', `Component is fully visible. currentRatio: ${currentRatio}`);
            this.running = true;
        }
        if (!isExpanding && currentRatio <= 0.0) {
            hilog.info(0x0000, 'Sample', `Component is fully invisible. currentRatio: ${currentRatio}`);
            this.running = false;
        }
      });
  }
}
// [End nonvisible_page_1]