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

import { AVPlayerConstants, CommonConstants } from '../common/CommonConstants';
import { AVPlayerController } from '../viewmodel/AVPlayerController'

@Component
export struct VideoProgressBar {
  @ObjectLink hlsPlayerController: AVPlayerController;

  build() {
    Row() {
      Text(this.getStringTime(this.hlsPlayerController.currentTime))
        .fontColor(Color.White)
        .fontSize($r('app.float.time_font_size'))
        .margin({
          left: $r('app.float.time_left_margin_large'),
          right: $r('app.float.time_right_margin')
        })

      Slider({
        value: this.hlsPlayerController.currentTime,
        step: AVPlayerConstants.SEEK_STEP,
        min: AVPlayerConstants.MIN_SEEK_TIME_MS,
        max: this.hlsPlayerController.durationTime,
      })
        .height($r('app.float.bar_height'))
        .trackColor($r('app.color.bar_track_color'))
        .showSteps(false)
        .layoutWeight(1)
        .blockColor($r('sys.color.background_primary'))
        .trackBorderRadius($r('app.float.bar_track_border_radius'))
        .selectedBorderRadius($r('app.float.bar_selected_border_radius'))
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderOnChange(value, mode);
        })

      Text(this.getStringTime(this.hlsPlayerController.durationTime))
        .fontColor(Color.White)
        .fontSize($r('app.float.time_font_size'))
        .margin({
          left: $r('app.float.time_left_margin'),
          right: $r('app.float.time_right_margin_large')
        })
    }
  }

  /**
   * Transfer time in second to string
   * @param timeInSecond
   * @returns time info string like '03:45' or '01:12:56'
   */
  private getStringTime(timeInSecond: number): string {
    const hourToSecond = CommonConstants.HOUR_TO_MINUTE * CommonConstants.MINUTE_TO_SECOND;
    const hour = Math.floor(timeInSecond / hourToSecond);
    const minute = Math.floor((timeInSecond - hour * hourToSecond) / CommonConstants.MINUTE_TO_SECOND);
    const second = timeInSecond - hour * hourToSecond - minute * CommonConstants.MINUTE_TO_SECOND;

    const twoDigits = (timePart: number) => {
      if (timePart >= CommonConstants.ZERO_VALUE && timePart < CommonConstants.TIME_CONST_TEN) {
        return `0${timePart}`;
      } else {
        return `${timePart}`;
      }
    };

    return `${twoDigits(hour)}:${twoDigits(minute)}:${twoDigits(second)}`;
  }

  private sliderOnChange(timeInSecond: number, mode: SliderChangeMode) {
    this.hlsPlayerController.setSeekStatus(true);
    this.hlsPlayerController.setCurrentTime(timeInSecond);
    switch (mode) {
      case SliderChangeMode.End:
        this.hlsPlayerController.seek(timeInSecond * CommonConstants.SECOND_TO_MS);
        break;
      default:
        break;
    }
  }
}