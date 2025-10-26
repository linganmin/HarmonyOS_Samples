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

@Component
export struct ScreenBrightnessView {
  @Link screenBrightness: number;
  @Link visible: boolean;

  // [Start SetScreenBrightnessSlider]
  build() {
    Row() {
      Stack() {
        Slider({
          value: this.screenBrightness,
          min: 0,
          max: 1,
          step: 0.05,
          style: SliderStyle.NONE,
          direction: Axis.Vertical,
          reverse: true
        })
          .height(160)
          .selectedColor(Color.White)
          .trackColor(Color.Black)
          .trackThickness(40)

        Image($r('app.media.sun_max_fill'))
          .margin({ top: 120 })
          .width(20)
          .height(20)
      }
      .margin({
        top: 0,
        right: 0
      })
    }
    .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
    .justifyContent(FlexAlign.End)
    .padding({
      right: 30,
      bottom: 20
    })
    .height('100%')
    .width('50%')
  }

  // [End SetScreenBrightnessSlider]
}