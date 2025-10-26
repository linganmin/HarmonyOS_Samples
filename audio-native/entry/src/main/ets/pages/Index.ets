/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import CommonConstants from '../constants/CommonConstants';
import { AudioRecording } from '../view/AudioRecording';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    AudioRecording()
  }

  build() {
    Navigation(this.pageInfos) {
      Row() {
        Column() {
          Image($r('app.media.ic_public_audio'))
            .width($r('app.float.audio_width'))
            .height($r('app.float.audio_width'))
            .margin({ top: $r('app.float.audio_margin_top') })
          Text($r('app.string.audio_captures'))
            .fontColor(Color.Black)
            .fontSize($r('app.float.audio_size'))
            .margin({ top: $r('app.float.small_margin') })
        }
        .id('record_play_card')
        .backgroundColor(Color.White)
        .width($r('app.float.audio_button_width'))
        .height($r('app.float.audio_button_height'))
        .borderRadius($r('app.float.border_radius'))
        .onClick(() => {
          this.pageInfos.pushPath({ name: 'default' });
        })
      }
      .padding($r('app.float.common_padding'))
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor($r('app.color.audio_background'))
    .hideTitleBar(true)
    .hideBackButton(false)
    .hideToolBar(true)
    .navDestination(this.PageMap)
  }
}