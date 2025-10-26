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
import { AVPlayerUtil } from '../utils/AVPlayerUtil'

/**
 * Control interface when playing videos in landscape mode
 */
@Component
export struct VideoControl {
  @Link currentTime: string
  @Link currentProgress: number
  @Prop videoDuration: number
  onChange? = (_value: number, _mode: SliderChangeMode) => {
  }

  @Builder
  showFeatureIcon(src: ResourceStr, content?: ResourceStr) {
    Row({ space: 3 }) {
      Image(src)
        .width(22)
      if (content) {
        Text(content)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(Color.White)
      }
    }
  }

  build() {
    Column() {
      Text() {
        Span(this.currentTime)
          .fontColor(Color.White)
        Span(`  /  `)
          .fontColor($r("app.color.color_white_forty_percent"))
        Span( AVPlayerUtil.getInstance().formatTime(this.videoDuration))
          .fontColor($r("app.color.color_white_forty_percent"))
      }
      .id('play_time')
      .fontSize(9)
      .lineHeight(12)

      Slider({ value: this.currentProgress, max: this.videoDuration, style: SliderStyle.NONE })
        .id('video_progress')
        .selectedColor(Color.White)
        .trackColor($r('app.color.color_white_ninety_percent'))
        .margin({ top: 10 })
        .height(4)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.onChange?.(value, mode)
        })

      Row({ space: 18 }) {
        this.showFeatureIcon($r('app.media.menu_icon_like'), '1557')
        this.showFeatureIcon($r('app.media.menu_icon_comment'), '566')
        this.showFeatureIcon($r('app.media.menu_icon_share'), '147')
      }
      .id('feature_icons')
      .margin({ top: 14 })
    }
    .alignItems(HorizontalAlign.Start)
  }
}