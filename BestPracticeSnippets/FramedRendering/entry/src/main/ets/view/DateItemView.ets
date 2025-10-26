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

import { displaySync } from '@kit.ArkGraphics2D';
import { Month } from '../model/MonthDataSource';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/CommonConstants';
import { i18n } from '@kit.LocalizationKit';

const WEEK: Resource[] =
  [
    $r('app.string.sunday'), $r('app.string.january'), $r('app.string.february'), $r('app.string.march'),
    $r('app.string.april'), $r('app.string.may'), $r('app.string.june')
  ]; // Set calendar week, starting on Sunday
const allDisplaySyncArray: displaySync.DisplaySync[] = [];
// [Start Case2]
@Reusable
@Component
export struct DateItemView {
  // [StartExclude Case2]
  monthItem: Month = {
    month: '',
    num: 0,
    days: [],
    lunarDays: [],
    year: 0
  };
  @State month: string = '';
  @State monthNumber: number = 0;
  @State days: number[] = [];
  @State lunarDays: string[] = [];
  private currentMonth: number = new Date().getMonth() + 1;
  private currentDay: number = new Date().getDate();
  private displaySync: displaySync.DisplaySync | undefined = undefined;
  private temp: Month[] = [];
  private step: number = 0;
  private maxStep: number = 2;
  private readonly MAX_EVERY_FRAME: number = 5; // Only five-day data is updated for one frame
  // [Start Case4]
  aboutToReuse(params: Record<string, Object>): void {
    hiTraceMeter.startTrace('reuse_' + (params.monthItem as Month).month, 1);
    this.temp.push(params.monthItem as Month);
    hiTraceMeter.finishTrace('reuse_' + (params.monthItem as Month).month, 1);
  }
  // [End Case4]

  aboutToRecycle(): void {
    hiTraceMeter.startTrace('recycle_', 1);
    this.temp = [];
    this.step = 0;
    this.maxStep = 2;
    hiTraceMeter.finishTrace('recycle_', 1);
  }
  // [EndExclude Case2]
  aboutToAppear(): void {
    hiTraceMeter.startTrace('appear_', 1);
    this.displaySync = displaySync.create();
    const range: ExpectedFrameRateRange = {
      expected: 120,
      min: 60,
      max: 120
    };
    this.displaySync.setExpectedFrameRateRange(range);
    this.displaySync.on('frame', () => {
      // [StartExclude Case2]
      // [Start Case3]
      if (this.temp.length > 0) {
        if (this.step === 0) {
          // Step 1: Add the monthly data and calculate the maximum number of frames required to complete the data operation.
          hiTraceMeter.startTrace('reuse_' + this.step, 1);
          this.month = this.temp[0].month;
          this.monthNumber = this.temp[0].num;
          this.maxStep = this.maxStep + Math.ceil(this.temp[0].days.length / this.MAX_EVERY_FRAME);
          hiTraceMeter.finishTrace('reuse_' + this.step, 1);
          this.step += 1;
        } else if (this.step === this.maxStep - 1) {
          // Final step: Initialize partial count data.
          this.temp = [];
          this.step = 0;
          this.maxStep = 2;
        } else {
          hiTraceMeter.startTrace('reuse_' + this.step, 1);
          const start: number = this.MAX_EVERY_FRAME * (this.step - 1);
          const end: number = (this.MAX_EVERY_FRAME * this.step) > this.temp[0].days.length ?
          this.temp[0].days.length : this.MAX_EVERY_FRAME * this.step;
          for (let i = start; i < end; i++) {
            this.days[i] = this.temp[0].days[i];
            this.lunarDays[i] = this.temp[0].lunarDays[i];
          }
          hiTraceMeter.finishTrace('reuse_' + this.step, 1);
          this.step += 1;
        }
      }
      // [End Case3]
      // [EndExclude Case2]
    });
    this.displaySync.start();
    allDisplaySyncArray.push(this.displaySync);
    this.temp.push(this.monthItem);
    hiTraceMeter.finishTrace('appear_', 1);
  }
  // [StartExclude Case2]
  aboutToDisappear(): void {
    if (allDisplaySyncArray.length > 0) {
      allDisplaySyncArray.forEach((displaySync: displaySync.DisplaySync) => {
        displaySync.stop();
      });
    }
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
      Text(this.month)
        .fontSize(16)
        .fontColor(Color.Black)
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Center)
        .lineHeight(21)

      Row() {
        ForEach(WEEK, (weekday: Resource, index: number) => {
          Text(weekday)
            .fontSize(12)
            .fontWeight(400)
            .height(16)
            .lineHeight(16)
            .fontColor(index === 0 || index === 6 ? '#66000000' : Color.Black)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }, (index: number): string => index.toString())
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_PERCENT)
      .margin({ top: 16 })

      ForEach(this.days, (day: number, index: number) => {
        Text() {
          Span(day.toString() + '\n')
            .fontSize(18)
            .fontWeight(700)
            .lineHeight(24)
          Span(this.lunarDays[index] === '' || i18n.System.getSystemLanguage() === 'en-Latn-US' ? '' : this.lunarDays[index])
            .fontSize(10)
            .fontWeight(400)
            .lineHeight(13)
        }
        .width(50)
        .height(50)
        .fontColor(day === this.currentDay && this.monthNumber === this.currentMonth ? Color.White :
          index % 7 === 0 || (index - 6) % 7 === 0 ? '#66000000' : Color.Black)
        .textAlign(TextAlign.Center)
        .borderRadius(25)
        .opacity(day === 0 ? 0 :
          1) // Set the value 0 in the date array to not display, that is, the content of the last month and the next month is not displayed.
        .backgroundColor(day === this.currentDay && this.monthNumber === this.currentMonth ?
          '#0a59f7' : Color.Transparent)
        .layoutWeight(1)
      }, (index: number): string => index.toString())
    }
    .alignSelf(ItemAlign.Center)
    .margin({ top: 5 })
    .width(CommonConstants.FULL_PERCENT)
  }
  // [EndExclude Case2]
  // [EndExclude date_item]
}
// [End Case2]
