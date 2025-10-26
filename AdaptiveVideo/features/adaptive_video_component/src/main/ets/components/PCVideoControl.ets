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
 *
 */
import { CommonConstants } from 'base'
import { media } from '@kit.MediaKit'
import { AVPlayerUtil } from '../utils/AVPlayerUtil'

/**
 * PC video playback progress bar
 */
@Component
export struct PCVideoControl {
  @Link currentTime: string
  @Link currentProgress: number
  @Prop videoDuration: number
  @Prop currentState: media.AVPlayerState
  onChange? = (_value: number, _mode: SliderChangeMode) => {
  }
  onVideoClick? = () => {
  }

  build() {
    Column() {
      Column() {
        Slider({ value: this.currentProgress, max: this.videoDuration, style: SliderStyle.NONE })
          .id('video_progress')
          .selectedColor(Color.White)
          .trackColor($r('app.color.color_white_ninety_percent'))
          .height(4)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.onChange?.(value, mode)
          })
      }
      .height(24)
      .justifyContent(FlexAlign.Center)

      Row() {
        Image(this.currentState === CommonConstants.AV_PLAYER_PAUSED_STATE ? $r("app.media.pc_status_pause") :
        $r("app.media.pc_status_playing"))
          .width(28)
          .padding(2)
          .margin({ right: 4 })
          .onClick(() => {
            this.onVideoClick?.()
          })
        Text() {
          Span(this.currentTime)
            .fontColor(Color.White)
          Span(`  /  `)
            .fontColor($r("app.color.color_white_forty_percent"))
          Span(AVPlayerUtil.getInstance().formatTime(this.videoDuration))
            .fontColor($r("app.color.color_white_forty_percent"))
        }
        .fontSize(14)
        .lineHeight(19)

        Blank()

        Row({ space: 16 }) {
          Text($r('app.string.speed'))
            .fontColor(Color.White)
            .fontSize(14)
            .lineHeight(19)
          Image($r('app.media.volume'))
            .width(24)
            .height(24)
          Image($r('app.media.pc_full_screen'))
            .width(24)
            .height(24)
        }
        .width('auto')
      }
      .width('100%')
      .padding({ top: 4, bottom: 24 })
    }
    .padding({ left: 32, right: 32 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}