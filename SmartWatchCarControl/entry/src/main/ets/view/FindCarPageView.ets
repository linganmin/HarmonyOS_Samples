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

import { promptAction } from '@kit.ArkUI';

@Builder
export function findCarPageBuilder() {
  FindCarPageView()
}

/**
 * FindCar Control Page
 */
@Component
struct FindCarPageView {
  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.find_car'))
          .fontSize(19)
          .fontWeight(700)
          .fontColor($r('sys.color.white'))
          .margin({ top: 20 })
        Row() {
          Column() {
            FindCarButtonComponent({
              img: $r('app.media.flash'),
              message: $r('app.string.flash_success')
            })
            Text($r('app.string.flash'))
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_on_secondary'))
              .margin({ top: 5 })
          }

          Column() {
            FindCarButtonComponent({
              img: $r('app.media.voice'),
              message: $r('app.string.Voice_success')
            })
            Text($r('app.string.voice'))
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_on_secondary'))
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .height('70%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .borderRadius('50%')
    .backgroundColor(Color.Black)
  }
}

@Component
struct FindCarButtonComponent {
  @State isFlashLoading: boolean = false;
  @State isButtonEnabled: boolean = true;
  img: ResourceStr = $r('app.media.startIcon');
  message: ResourceStr = '';

  build() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      if (!this.isFlashLoading) {
        Image(this.img)
          .width(30)
          .height(30)
      } else {
        LoadingProgress()
          .width(30)
          .height(30)
          .color(0xFFFFF)
      }
    }
    .width(55)
    .height(55)
    .backgroundColor(this.isFlashLoading ? '#317AFF' : '#979797')
    .enabled(this.isButtonEnabled)
    .onClick(() => {
      this.isFlashLoading = !this.isFlashLoading;
      if (this.isFlashLoading) {
        this.isButtonEnabled = false;
      }
      let timeID = setTimeout(() => {
        this.isFlashLoading = false;
        this.isButtonEnabled = true;
        promptAction.openToast({
          message: this.message,
          duration: 1000
        });
        clearTimeout(timeID);
      }, 1000);
    })
  }
}