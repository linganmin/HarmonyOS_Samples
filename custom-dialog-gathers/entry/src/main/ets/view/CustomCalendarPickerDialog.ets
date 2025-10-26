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
import { getMonthDate } from '../viewmodel/GetDate';
import { MonthDataSource, Month } from '../viewmodel/MonthDataSource';
import { DataManager } from '../viewmodel/DataManager';
import { DateModel } from '../viewmodel/DateModel';
import { CommonConstants } from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@CustomDialog
export struct CustomCalendarPickerDialog {
  @State contentData: MonthDataSource = new MonthDataSource();
  @State nextMonth: number = 1;
  @State nextYear: number = 1;
  @State nextMonthDay: number[] = [];
  @State currentMonthDay: number[] = [];
  @State initialIndex: number = 0;
  @Link currentMonth: number;
  @Link currentDay: number;
  @Link currentYear: number;
  @StorageLink('selectedDate') dateModel: DateModel = new DateModel(0, 0, 0, 0);
  controller: CustomDialogController;
  cancel: () => void = () => {};
  private week: ResourceStr[] = [$r('app.string.ri'), $r('app.string.yi'), $r('app.string.er'), $r('app.string.san'), $r('app.string.si'), $r('app.string.wu'), $r('app.string.liu')];
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CustomCalendarPickerDialog', `get string failed. code=${err.code}, message=${err.message}`);
    }
    return resourceString;
  }

  aboutToAppear() {
    this.currentMonthDay = getMonthDate(this.currentMonth, this.currentYear);
    if (this.currentMonth === CommonConstants.MONTHS) {
      this.nextMonth = CommonConstants.JANUARY;
      this.nextYear = this.currentYear + 1;
    } else {
      this.nextMonth = this.currentMonth + 1;
      this.nextYear = this.currentYear;
    }
    this.nextMonthDay = getMonthDate(this.nextMonth, this.nextYear);
    let months: Month[] = [
      {
        month: `${this.currentYear}${this.getResourceString($r('app.string.year'))} ${this.currentMonth}${this.getResourceString($r('app.string.month'))}`,
        num: this.currentMonth,
        days: this.currentMonthDay
      },
      {
        month: `${this.nextYear}${this.getResourceString($r('app.string.year'))} ${this.nextMonth}${this.getResourceString($r('app.string.month'))}`,
        num: this.nextMonth,
        days: this.nextMonthDay
      }
    ]
    this.contentData.pushData(months);
    this.initialIndex = this.dateModel.month > this.currentMonth ? 1 : 0;
  }

  @Builder
  itemHead(text: string) {
    Text(text)
      .backgroundColor($r('app.color.color_sub_background'))
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height($r('app.float.text_height'))
      .textAlign(TextAlign.Center)
  }

  build() {
    Column({ space: CommonConstants.ELEMENTS_MARGIN }) {
      Text($r('app.string.departure_date'))
        .fontSize($r('app.float.text_size_headline'))
      List() {
        ForEach(this.week, (weekInformation: string) => {
          ListItem() {
            Text(weekInformation)
              .textAlign(TextAlign.Center)
              .width(CommonConstants.ONE_HUNDRED_PERCENT)
              .height($r('app.float.text_size_headline'))
              .fontColor(weekInformation === CommonConstants.SUNDAY || weekInformation ===
                CommonConstants.SATURDAY ? $r('app.color.color_warning') : $r('app.color.color_text_primary'))
          }
          .width($r('app.string.week_width'))
        })
      }
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height($r('app.float.text_size_headline'))
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)

      List({ initialIndex: this.initialIndex }) {
        LazyForEach(this.contentData, (monthItem: Month) => {
          ListItemGroup({ header: this.itemHead(monthItem.month) }) {
            ListItem() {
              Grid() {
                ForEach(monthItem.days, (day: number) => {
                  GridItem() {
                    if (day === this.dateModel.day && monthItem.num === this.dateModel.month) {
                      Text(day.toString())
                        .fontSize($r('app.float.text_size_headline'))
                        .fontColor($r('app.color.start_window_background'))
                    } else {
                      Text(day.toString())
                        .fontSize($r('app.float.text_size_headline'))
                        .fontColor(day < this.currentDay && monthItem.num ===
                        this.currentMonth ? $r('app.color.color_text_secondary') : $r('app.color.color_text_primary'))
                    }
                  }
                  .height($r('app.float.calendar_height'))
                  .width($r('app.float.calendar_height'))
                  .borderRadius($r('app.float.corner_radius_default_l'))
                  .backgroundColor(day === this.dateModel.day && monthItem.num ===
                  this.dateModel.month ? $r('app.color.color_warning') : $r('app.color.start_window_background'))
                  .opacity(day === CommonConstants.ZERO ? CommonConstants.ZERO : CommonConstants.JANUARY)
                  .onClick(() => {
                    if (day >= this.currentDay || monthItem.num > this.currentMonth) {
                      let weekIndex = monthItem.days.indexOf(day) % CommonConstants.WEEK_NUMBER;
                      this.dateModel.day = day;
                      this.dateModel.week = weekIndex;
                      this.dateModel.month = monthItem.num;
                      DataManager.setDate(this.context, this.dateModel, () => {});
                      this.controller.close();
                    }
                  })
                }, (day: number, index: number) => index + JSON.stringify(day))
              }
              .backgroundColor($r('app.color.start_window_background'))
              .columnsTemplate(CommonConstants.GRID_SEVEN)
              .rowsTemplate(monthItem.days.length > CommonConstants.MONTH_NUMBER ?
                CommonConstants.GRID_SIX : CommonConstants.GRID_FIVE)
              .height(monthItem.days.length > CommonConstants.MONTH_NUMBER ? CommonConstants.GRID_HEIGHT_L :
              CommonConstants.GRID_HEIGHT_M)
            }
          }
        }, (monthItem: Month) => JSON.stringify(monthItem))
      }
      .height($r('app.string.calendar_height'))
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .sticky(StickyStyle.Header)
    }
    .padding({ top: CommonConstants.ELEMENTS_MARGIN })
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.EIGHTY_FIVE_PERCENT)
    .borderRadius({
      topLeft: $r('app.float.corner_radius_default_l'),
      topRight: $r('app.float.corner_radius_default_l')
    })
    .backgroundColor($r('app.color.start_window_background'))
    .alignItems(HorizontalAlign.Center)
  }
}