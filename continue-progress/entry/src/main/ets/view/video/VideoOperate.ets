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

import { timeConvert } from '../../utils/TimeUtils';
import avPlayManage from '../../viewmodel/video/AvPlayManager';
import { SpeedDialog } from './SpeedDialog';

@Component
export struct VideoOperate {
  @State speedList: Resource[] =
    [$r('app.string.video_speed_1_0X'), $r('app.string.video_speed_1_25X'), $r('app.string.video_speed_1_75X'),
      $r('app.string.video_speed_2_0X')];
  @StorageLink('currentTime') currentTime: number = 0;
  @StorageLink('flag') flag: boolean = true;
  @StorageLink('speedIndex') speedIndex: number = 0; // Index of the playback rate list.
  @StorageLink('sliderWidth') sliderWidth: string = '';
  @StorageLink('speedSelect') @Watch('changeSpeed') speedSelect: number = 0; // Speed Magnification Selection
  @State speed: number = this.speedSelect; // Speed Magnification Selection
  @StorageLink('speedName') speedName: Resource = this.speedList[this.speedSelect];
  @Link durationTime: number;
  @Link isSwiping: boolean;
  @Link avPlayManage: avPlayManage;
  @Link XComponentFlag: boolean;
  @State videoList: Resource[] = [$r('app.string.video_res_1'), $r('app.string.video_res_2')];
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SpeedDialog({ speed: $speed }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });

  changeSpeed() {
    this.speedName = this.speedList[this.speedSelect];
    this.speed = this.speedSelect;
  }

  build() {
    Row() {
      Row() {
        Image(this.flag ? $r('app.media.ic_video_play') : $r('app.media.ic_video_pause'))// Pause/Play
          .id('play')
          .width($r('app.float.size_40'))
          .height($r('app.float.size_40'))
          .onClick(() => {
            if (this.flag) {
              this.avPlayManage.videoPause();
              this.flag = false;
            } else {
              this.avPlayManage.videoPlay();
              this.flag = true;
            }
          })

        // Left side time
        Text(timeConvert(this.currentTime))
          .fontColor(Color.White)
          .textAlign(TextAlign.End)
          .fontWeight(FontWeight.Regular)
          .margin({ left: $r('app.float.size_10') })
      }

      Row() {
        Slider({
          value: this.currentTime,
          min: 0,
          max: this.durationTime,
          style: SliderStyle.OutSet
        })
          .id('Slider')
          .blockColor(Color.White)
          .trackColor(Color.Gray)
          .selectedColor($r('app.color.slider_selected'))
          .showTips(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.Begin) {
              this.avPlayManage.sliderAction(true);
            }
            this.avPlayManage.videoSeek(value);

            if (mode === SliderChangeMode.End) {
              this.avPlayManage.sliderAction(false);
            }
          })
      }
      .layoutWeight(1)

      Row() {
        // Right side time
        Text(timeConvert(this.durationTime))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Regular)
      }
    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: $r('app.float.size_25'), right: $r('app.float.size_30') })
    .width('100%')
  }
}