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

// [Start nonvisible_page_2]
@Component
struct VisibilityExample {
  // State to control animation visibility
  @State isHidden: boolean = false

  build() {
    Column() {
      // Image animation component with visibility control
      ImageAnimator()
        .images([
          { src: $r('app.media.background') },
          { src: $r('app.media.foreground') }
        ])
        .width('100%')
        .height('30%')
        .duration(600)
        .visibility(this.isHidden ? Visibility.Hidden : Visibility.Visible)
        .state(this.isHidden ? AnimationStatus.Paused : AnimationStatus.Running)
        .iterations(-1) // Infinite loop

        // Toggle button for visibility
        Button(this.isHidden ? 'Show' : 'Hide')
          .width('90%')
          .onClick(() => {
            this.isHidden = !this.isHidden
          })
    }
  }
}
// [End nonvisible_page_2]