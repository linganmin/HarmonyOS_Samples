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
 * 最佳实践：Buffer低功耗优化
 */

import webview from '@ohos.web.webview';
import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';

// [Start buffer_power_case_1]
@Component
struct MyWebComponent {
  private src: string = ""
  private controller1: webview.WebviewController = new webview.WebviewController();
  shouldDraw: boolean = true;
  build() {
    Web({ src: this.src, controller: this.controller1 })
      .onPageBegin(() => {
        console.log(this.src, "webpage is onActive")
        this.controller1.onActive();
      })

      .onFirstMeaningfulPaint(() => {
        if (!this.shouldDraw) {
          return;
        }
        console.log(this.src, "webpage is onInactive")
        this.controller1.onInactive()
        this.shouldDraw = false
      })
  }
}
// [End buffer_power_case_1]

// [Start buffer_power_case_2]
@Component
export struct MyVideoComponent {
  @State videoSrc: Resource | string = $r('app.media.test_video');
  private controller: VideoController = new VideoController();


  build() {
    Column() {
      Video({
        src: this.videoSrc,
        controller: this.controller,

      })
        .width(300)
        .height(200)
        .onPrepared(() => {
          this.controller.start();
        })
        // 确保视频组件完全可见时播放，完全不可见时停止
        .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
          if (isExpanding && currentRatio >= 1.0) {
            console.info('Component is completely visiable.');
            if (this.controller) {
              this.controller.start();
            }
          }
          if (!isExpanding && currentRatio <= 0.0) {
            console.info('Component is completely invisible.');
            if (this.controller) {
              this.controller.pause();
            }
          }
        })
    }
  }
}
// [End buffer_power_case_2]


// [Start buffer_power_case_3]
@Component
export struct MyVideoComponent_opacity {
  @State videoSrc: Resource | string = $r('app.media.test_video');
  private controller: VideoController = new VideoController();


  build() {
    Column() {
      Video({
        src: this.videoSrc,
        controller: this.controller,

      })
        .width(300)
        .height(200)
        // .opacity(0.4) 注释掉此段代码，可规避GPU重绘
        .onPrepared(() => {
          this.controller.start();
        })
    }
  }
}
// [End buffer_power_case_3]