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

import { HomeStore, initCurrentDateInfo } from '../../viewmodel/HomeStore';
import { CommonConstants as Const, convertStr2Date, DayInfo, formatSystemTime } from 'common';

@Component
export struct WeekCalendarComponent {
  @Consume @Watch('onDataChange') homeStore: HomeStore;
  @State showDateStr: string = '';
  @State currentWeekIndex: number = Const.WEEK_DAY_NUM;
  showDate: Date = new Date();
  scroller: Scroller = new Scroller();

  onDataChange() {
    this.showDate = convertStr2Date(this.homeStore.currentDate);
    this.showDateStr = formatSystemTime(this.showDate);
  }

  private async refreshDateInfo(diffDay: number) {
    this.showDate.setDate(this.showDate.getDate() + diffDay);
    this.homeStore = await initCurrentDateInfo(this.showDate);
  }

  /**
   * Switch the week view, swipe left and right to the top and next week after exceeding a certain threshold.
   */
  private weekChange() {
    const center = this.scroller.currentOffset().xOffset;
    if (center <= Const.WEEK_LEFT_LIMIT) {
      this.animateToWeekAndRefresh(-Const.WEEK_DAY_NUM, 0);
    } else if (center >= Const.WEEK_RIGHT_LIMIT) {
      this.animateToWeekAndRefresh(Const.WEEK_DAY_NUM, Const.WEEK_DAY_NUM * 2);
    } else {
      this.getUIContext().animateTo({
        duration: Const.DURATION_200
      }, () => {
        this.scroller.scrollToIndex(Const.WEEK_DAY_NUM);
      });
    }
  }

  private animateToWeekAndRefresh(diffDay: number, toIndex: number) {
    this.getUIContext().animateTo({
      duration: Const.DURATION_100,
      onFinish: async () => {
        await this.refreshDateInfo(diffDay);
        this.scroller.scrollToIndex(Const.WEEK_DAY_NUM);
      }
    }, () => {
      this.scroller.scrollToIndex(toIndex);
    });
  }

  aboutToAppear(): void {
    this.onDataChange();
  }

  build() {
    Column() {
      Column() {
        Row() {
          this.symbolBuild($r('sys.symbol.chevron_left'), async () => {
            await this.refreshDateInfo(-Const.WEEK_DAY_NUM);
          })

          Text(this.showDateStr)
            .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
            .fontWeight(FontWeight.Regular)
            .fontColor($r(`sys.color.font_primary`))
            .fontSize($r('app.float.default_14'))
            .padding({
              left: $r('app.float.default_14'),
              right: $r('app.float.default_14')
            })

          this.symbolBuild($r('sys.symbol.chevron_right'), async () => {
            await this.refreshDateInfo(Const.WEEK_DAY_NUM);
          })
        }

        List({
          scroller: this.scroller,
          initialIndex: this.currentWeekIndex
        }) {
          ForEach(this.homeStore.weekList, (item: DayInfo, index: number) => {
            this.dayOfWeekBuilder(item, index)
          }, (item: DayInfo, index: number) => index + JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_500)
        .onScrollStop(() => {
          this.weekChange();
        })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .justifyContent(FlexAlign.SpaceEvenly)
      .borderRadius($r('sys.float.radio_container_size'))
      .backgroundColor($r('sys.color.background_primary'))
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_420)
    .padding(Const.THOUSANDTH_33)
  }

  @Builder
  dayOfWeekBuilder(item:
    DayInfo, index:
    number
  ) {
    Column() {
      Text(Const.WEEK_SHORTHAND_LIST[index % Const.WEEK_DAY_NUM])
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontColor(this.homeStore.selectedDay === index ? $r('sys.color.brand') : $r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_12'))

      Divider()
        .margin({
          top: $r('app.float.default_2'),
          bottom: $r('app.float.default_4')
        })
        .width($r('app.float.default_12'))
        .color($r('sys.color.brand'))
        .visibility(this.homeStore.selectedDay === index ? Visibility.Visible : Visibility.Hidden)

      Image(item.getProgressImg())
        .height($r('app.float.default_28'))
        .objectFit(ImageFit.Contain)
        .margin({
          top: Const.THOUSANDTH_80
        })
    }
    .width(Const.PERCENTAGE_100_EXCEPT_7)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(async () => {
      if (this.homeStore.selectedDay === index) {
        return;
      }
      const diffDay = index - this.homeStore.selectedDay;
      await this.refreshDateInfo(diffDay);
    })
  }

  @Builder
  symbolBuild(symbolResource:
    Resource, clickFun:
    (event: ClickEvent) => void
  ) {
    SymbolGlyph(symbolResource)
      .fontColor([$r('sys.color.icon_secondary')])
      .fontWeight(FontWeight.Normal)
      .fontSize($r('app.float.default_18'))
      .clickEffect({
        level: ClickEffectLevel.HEAVY,
        scale: Const.SYMBOL_GLYPH_CLICK_SCALE
      })
      .onClick(clickFun)
  }
}