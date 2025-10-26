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

import { HomeStore } from '../../viewmodel/HomeStore';
import { CommonConstants as Const, DayInfo } from 'common';
import { WeekCalendarComponent } from './WeekCalendarComponent';

@Component
export struct HomeTopComponent {
  @Consume @Watch('onDataChange') homeStore: HomeStore;
  @State dayInfo: DayInfo = new DayInfo('', 0, 0);

  onDataChange() {
    this.dayInfo = this.homeStore.weekList[this.homeStore.selectedDay];
  }

  aboutToAppear(): void {
    this.onDataChange();
  }

  build() {
    Column() {
      Text($r('app.string.target_progress'))
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontColor($r(`sys.color.font_secondary`))
        .fontSize($r('app.float.default_16'))
        .width(Const.THOUSANDTH_1000)
        .padding({
          left: $r('app.float.default_24')
        })

      Row() {
        Text(`${this.dayInfo.calculatePercentage()}`)
          .fontFamily(Const.HARMONY_HEI_TI_BOLD)
          .fontWeight(FontWeight.Bold)
          .fontColor($r(`sys.color.font_primary`))
          .fontSize($r('app.float.default_72'))

        Text(Const.PERCENT)
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r(`sys.color.font_primary`))
          .fontSize($r('app.float.default_40'))
          .width(Const.THOUSANDTH_1000)
          .margin({
            top: $r('app.float.default_12'),
            left: $r('app.float.default_8')
          })
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        left: $r('app.float.default_24')
      })

      WeekCalendarComponent()
    }
    .height(Const.THOUSANDTH_500)
    .backgroundImage($r('app.media.ic_home_bg'))
    .backgroundImagePosition({
      x: $r('app.float.default_0'),
      y: $r('app.float.default_0')
    })
    .backgroundImageSize({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_900
    })
    .justifyContent(FlexAlign.End)
  }
}