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

import { TitleLink } from './TitleLink';
import { CustomizeEmoji } from './CustomizeEmoji';
import { VideoLink } from './VideoLink';
import { ImageText } from './ImageText';

@Entry
@Component
struct Home {
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()

  @Builder
  PagesMap(name: string) {
    if (name === 'TitleLink') {
      TitleLink();
    } else if (name === 'CustomizeEmoji') {
      CustomizeEmoji();
    } else if (name === 'VideoLink') {
      VideoLink();
    } else if (name === 'ImageText') {
      ImageText();
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Row() {
        Column() {
          Text($r('app.string.title_desc'))
            .width('100%')
            .height(88)
            .fontSize(30)
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Bold)
            .padding({ top: '8vp' })
            .margin({ top: '56vp' })

          Blank()

          Button($r('app.string.title_link'))
            .width('100%')
            .backgroundColor($r('app.color.record_button_background_inactive_color'))
            .fontColor($r('app.color.button_color'))
            .onClick(() => {
              this.pageInfos.pushPathByName('TitleLink', '');
            })

          Button($r('app.string.customize_emoji'))
            .width('100%')
            .margin({ top: '12vp' })
            .backgroundColor($r('app.color.record_button_background_inactive_color'))
            .fontColor($r('app.color.button_color'))
            .onClick(() => {
              this.pageInfos.pushPathByName('CustomizeEmoji', '');
            })

          Button($r('app.string.video_link'))
            .width('100%')
            .margin({ top: '12vp' })
            .backgroundColor($r('app.color.record_button_background_inactive_color'))
            .fontColor($r('app.color.button_color'))
            .onClick(() => {
              this.pageInfos.pushPathByName('VideoLink', '');
            })

          Button($r('app.string.image_text'))
            .width('100%')
            .margin({ top: '12vp' })
            .backgroundColor($r('app.color.record_button_background_inactive_color'))
            .fontColor($r('app.color.button_color'))
            .onClick(() => {
              this.pageInfos.pushPathByName('ImageText', '');
            })
        }
        .justifyContent(FlexAlign.Center)
        .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
        .width('100%')
        .height('100%')
      }
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.PagesMap)
  }
}