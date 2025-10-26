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

import Constants from '../commom/Constants';
import BrightnessViewModel from '../viewmodel/BrightnessViewModel';

@ComponentV2
export default struct VideoView {
  @Local currentBrightness: number = -1;
  @Local sliderOpacity: number = 0;
  private brightnessViewModel: BrightnessViewModel = new BrightnessViewModel();
  // [Start video_view]
  build() {
    Stack({ alignContent: Alignment.Start }) {
      // [Start video]
      Video({
        src: $rawfile('video1.mp4'),
        previewUri: $r('app.media.img_preview'),
      })
        .loop(true)
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .onStart(() => {
          this.brightnessViewModel.setWindowKeepScreenState(true);
        })
        .onPause(() => {
          this.brightnessViewModel.setWindowKeepScreenState(false);
        })
      // [End video]
      Slider({
        value: this.currentBrightness,
        min: 0,
        max: 1,
        step: 0.01,
        style: SliderStyle.InSet,
        direction: Axis.Vertical,
        reverse: true
      })
        .trackColor('#66A0A0A4')
        .blockColor(Color.Transparent)
        .selectedColor(Color.White)
        .height('80%')
        .margin({ left: 24, bottom: 24 })
        .onChange((value: number, mode: SliderChangeMode) => { // Slider onChange callback
          if (mode === SliderChangeMode.Moving) {
            this.sliderOpacity = 1;
            this.brightnessViewModel.updateVideoBrightness(value);
          } else if (mode === SliderChangeMode.End) {
            this.sliderOpacity = 0;
          }
        })
        .opacity(this.sliderOpacity)
        .animation({
          duration: 300
        })
    }
    .width(Constants.FULL_PERCENT)
    .height(184)
  }
  // [End video_view]
}