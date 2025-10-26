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

import Constants from '../constants/Constants';

@Component
export default struct TextScrollingView {
  @State message: ResourceStr = '';
  @State value: number = 0;

  build() {
    Row() {
      Text(this.message)
        .fontSize($r('app.float.content_font_size'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
    }
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [[Color.Red, 0.0], [Color.Red, this.value], [Color.Black, this.value], [Color.Black, 1.0]]
    })
    .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
    .backgroundImageSize({
      width: 0,
      height: 0
    })
    .onAppear(() => {
      this.getUIContext().animateTo({
        duration: Constants.TEXT_SCROLL_DURATION,
        finishCallbackType: FinishCallbackType.LOGICALLY,
        curve: Curve.Linear,
        iterations: -1,
        onFinish: () => {
          this.value = 0
        }
      }, () => {
        this.value = 1
      });
    })
  }
}