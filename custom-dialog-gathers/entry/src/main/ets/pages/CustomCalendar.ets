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
import { CustomCalendarPickerDialog } from '../view/CustomCalendarPickerDialog';
import { DateModel } from '../viewmodel/DateModel';
import { getRealTimeDate } from '../viewmodel/GetDate';
import { CommonConstants } from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct CalendarView {
  private week: ResourceStr[] = [$r('app.string.sunday'), $r('app.string.monday'), $r('app.string.tuesday'), $r('app.string.wednesday'), $r('app.string.thursday'), $r('app.string.friday'), $r('app.string.saturday')];
  @State currentMonth: number = 1;
  @State currentDay: number = 1;
  @State currentYear: number = 1;
  @StorageLink('selectedDate') dateModel: DateModel = new DateModel(0, 0, 0, 0);
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.dateModel = getRealTimeDate();
    this.currentMonth = this.dateModel.month;
    this.currentDay = this.dateModel.day;
    this.currentYear = this.dateModel.year;
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      currentMonth: this.currentMonth,
      currentDay: this.currentDay,
      currentYear: this.currentYear,
      cancel: this.onCancel
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  onCancel() {
  }

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CustomCalendar', `get string failed. code=${err.code}, message=${err.message}`);
    }
    return resourceString;
  }

  @Builder
  calendarMainView() {
    Column({ space: CommonConstants.ELEMENTS_MARGIN_L }) {
      Row() {
        Text($r('app.string.departure'))
          .fontSize($r('app.float.text_size_headline'))
        Image($r('app.media.train_transport_icon'))
          .height($r('app.float.train_image_size'))
          .width($r('app.float.train_image_size'))
        Text($r('app.string.destination'))
          .fontSize($r('app.float.text_size_headline'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)

      Row({ space: CommonConstants.ELEMENTS_MARGIN_M }) {
        Text(`${this.dateModel.month}${this.getResourceString($r('app.string.month'))}${this.dateModel.day}${this.getResourceString($r('app.string.day'))}`)
          .fontSize($r('app.float.text_size_headline'))
        Text(this.week[this.dateModel.week])
          .fontSize($r('app.float.text_size_body1'))
      }
      .justifyContent(FlexAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .onClick(() => {
        this.dialogController.open();
      })

      Button($r('app.string.check_ticket'))
        .fontSize($r('app.float.text_size_headline'))
        .height($r('app.float.check_button_height'))
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .type(ButtonType.Normal)
        .borderRadius($r('app.float.corner_radius_default_m'))
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.button_text')
          });
        })
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding($r('app.float.card_padding'))
    .borderRadius($r('app.float.corner_radius_default_m'))
  }

  build() {
    Navigation() {
      Column() {
        this.calendarMainView()
      }
      .backgroundColor($r('app.color.color_sub_background'))
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
      .padding($r('app.float.corner_radius_default_m'))
    }
    .title($r('app.string.calendar_dialog'))
    .titleMode(NavigationTitleMode.Mini)
  }
}