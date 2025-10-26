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
export default struct TextRefectionView {
  @State message: ResourceStr = '';

  build() {
    Stack() {
      Text(this.message)
        .fontSize($r('app.float.content_font_size'))
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Bold)
      Text(this.message)
        .fontSize($r('app.float.content_font_size'))
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Bold)
        .rotate({
          x: 1,
          y: 0,
          z: 0,
          angle: Constants.ANGLE_DEGREE,
          centerX: Constants.FIFTY_PERCENT,
          centerY: Constants.FULL_PERCENT
        })
        .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
    }
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[Color.Transparent, 0], [Color.Transparent, 0.50],
        [Color.Red, 0.50], [$r('app.color.text_reflection_color'), 1]]
    })
    .height($r('app.float.text_refection_height'))
    .alignContent(Alignment.Top)
    .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
  }
}