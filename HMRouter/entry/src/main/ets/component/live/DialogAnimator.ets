/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

/**
 * 最佳实践：转场动效场景
 */


import { HMNavigation, IHMAnimator } from '@hadss/hmrouter';

// [Start global_dialog]
const globalPageTransitionEffect: IHMAnimator.Effect = new IHMAnimator.Effect({
  direction: IHMAnimator.Direction.BOTTOM_TO_TOP,
  opacity: { opacity: 0.5 },
  scale: { x: 0.5, y: 0.2 }
})

// [End global_dialog]

@Component
export struct DialogAnimator {
  @State message: string = 'Hello World';

  build() {
    // [Start dialog_animator]
    HMNavigation({
      navigationId: 'mainNavigationId', homePageUrl: 'HomeContent', options: {
        dialogAnimator: globalPageTransitionEffect,
      }
    })
    // [End dialog_animator]
  }
}