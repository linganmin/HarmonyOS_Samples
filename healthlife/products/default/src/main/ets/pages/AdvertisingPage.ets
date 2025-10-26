/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants as Const } from 'common';

// hilog tag.
const TAG: string = 'AdvertisingPage';

@Entry
@Component
struct AdvertisingPage {
  @State duration: number = Const.AD_DURATION;
  private intervalId: number = -1;

  goToHomePage() {
    clearInterval(this.intervalId);
    this.getUIContext().getRouter().replaceUrl({ url: 'pages/Index' }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Jump to index page failed, code is ${err.code},message is ${err.message}`);
    });
  }

  aboutToAppear() {
    this.intervalId = setInterval(() => {
      if (this.duration > 0) {
        this.duration -= 1;
      } else {
        this.goToHomePage();
      }
    }, Const.DURATION_1000)
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.skip_ads', this.duration))
          .fontSize($r('app.float.default_12'))
          .fontColor($r('sys.color.font_on_primary'))
          .borderRadius($r('app.float.default_16'))
          .letterSpacing($r('app.float.letter_space_1'))
          .height($r('app.float.default_36'))
          .backgroundColor('rgba(0,0,0,0.20)')
          .border({
            color: $r('sys.color.font_on_primary'),
            width: $r('app.float.default_1')
          })
          .margin({
            top: $r('app.float.default_36')
          })
          .padding($r('app.float.default_8'))
          .onClick(() => this.goToHomePage())
      }
      .width(Const.THOUSANDTH_900)
      .justifyContent(FlexAlign.End)

      Row() {
        Image($r('app.media.logo'))
          .width($r('app.float.default_56'))
          .height($r('app.float.default_56'))
          .objectFit(ImageFit.Contain)

        Column({
          space: $r('app.float.default_4')
        }) {
          Text($r('app.string.EntryAbility_label'))
            .fontFamily(Const.HARMONY_HEI_TI_BOLD)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('app.float.default_26'))
            .letterSpacing($r('app.float.letter_space_1'))

          Text($r('app.string.EntryAbility_desc'))
            .fontFamily(Const.HARMONY_HEI_TI)
            .fontWeight(FontWeight.Normal)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('app.float.default_16'))
            .letterSpacing($r('app.float.letter_space_34'))
            .opacity($r('app.float.opacity_6'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          left: $r('app.float.default_12')
        })
      }
      .height($r('app.float.default_100'))
      .width(Const.THOUSANDTH_1000)
      .justifyContent(FlexAlign.Center)
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
    .backgroundImagePosition({
      x: $r('app.float.default_0'),
      y: $r('app.float.default_0')
    })
    .backgroundImage($r('app.media.ic_ad_bg'))
    .backgroundImageSize({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}