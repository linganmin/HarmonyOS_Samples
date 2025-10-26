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

@Builder
export function Question3CorrectBuilder() {
  Question3Correct()
}

// [Start Question3_correct]
@Component
export struct Question3Correct {
  build() {
    NavDestination() {
      Column() {
        Video({ src: $rawfile('testVideo2.mp4') })
          // [StartExclude  Question3_correct]
          .height('100%')
          .width('100%')
          .autoPlay(true)
          .controls(false)
            // [EndExclude  Question3_correct]
          .objectFit(ImageFit.Contain)
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
  }
}
// [End Question3_correct]