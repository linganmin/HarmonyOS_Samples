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

import { CommonConstants as Const } from '../../common/CommonConstants';
import { AVPlayerUtil } from '../../common/utils/AVPlayerUtil';

@Component
export struct VideoControlView {
  @StorageLink('progress') progress: number = 0;
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('currentTime') currentTime: string = '00:00:00';
  @StorageLink('totalTime') totalTime: string = '00:00:00';
  public avPlayerUtil?: AVPlayerUtil;

  build() {
    Column() {
      Row() {
        TimeText({ time: $currentTime })
          .margin({
            left: '36vp',
            right: '2vp'
          })

        Slider({
          min: 0,
          max: Const.PROGRESS_HUNDRED,
          step: 1,
          value: this.progress
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.avPlayerUtil?.sliderChange(value, mode);
          })
          .layoutWeight(1)
          .selectedColor('#ED6F21')
          .trackColor('#33FFFFFF')

        TimeText({ time: $totalTime })
          .margin({
            left: '2vp',
            right: '36vp'
          })
      }
      .width('100%')
      .height('40vp')
      .alignItems(VerticalAlign.Center)

      Row() {
        Row() {
          Image(this.avplayerState === 'playing' ? $r('app.media.ic_public_pause')
            : $r('app.media.ic_public_play'))
            .height('24vp')
            .width('24vp')
            .margin({ left: '24vp' })
            .onClick(() => {
              this.avPlayerUtil?.playerStateControl();
            })

          ImgIcon({ img: $r('app.media.ic_public_play_next') })

          ImgIcon({ img: $r('app.media.ic_public_view_list_white') })
        }
        .margin({
          top: this.currentWidthBreakpoint === Const.BREAKPOINT_SM ? '0' : '14vp',
          bottom: this.currentWidthBreakpoint === Const.BREAKPOINT_SM ? '15vp' : '24vp'
        })

        Blank()

        Row() {
          TextButton({ content: Const.PLAYER_TEXT_LIST[0] })
          TextButton({ content: Const.PLAYER_TEXT_LIST[1] })
          TextButton({ content: Const.PLAYER_TEXT_LIST[2] })
        }
        .margin({
          top: this.currentWidthBreakpoint === Const.BREAKPOINT_SM ? '4vp' : '16vp',
          bottom: this.currentWidthBreakpoint === Const.BREAKPOINT_SM ? '19vp' : '28vp'
        })
      }
      .height('60vp')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.End)
  }
}

@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize('9fp')
      .fontColor(Color.White)
      .lineHeight('12vp')
      .width('38vp')
  }
}

@Component
struct ImgIcon {
  public img?: Resource;

  build() {
    Image(this.img !== undefined ? this.img : '')
      .height('24vp')
      .width('24vp')
      .margin({ left: '24vp' })
  }
}

@Component
struct TextButton {
  public content: ResourceStr = '';

  build() {
    Text(this.content)
      .fontSize('12fp')
      .fontWeight(FontWeight.Normal)
      .fontColor(Color.White)
      .margin({ right: '24vp' })
  }
}