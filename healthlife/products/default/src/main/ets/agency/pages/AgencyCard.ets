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

import { DayTaskInfo, taskBaseInfoList } from 'common';

let agencyStorage = new LocalStorage();

@Entry(agencyStorage)
@Component
struct AgencyCard {
  @LocalStorageProp('dayTaskInfos') dayTaskInfos: DayTaskInfo[] = [];
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The with percentage setting.
   */
  readonly FULL_WIDTH_PERCENT: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';
  /*
   * The empty image width percentage setting.
   */
  readonly EMPTY_IMAGE_WIDTH: string = '31%';
  /*
   * The agency component height percentage setting.
   */
  readonly AGENCY_COMPONENT_HEIGHT: string = '30.5%';
  /*
   * The empty image height percentage setting.
   */
  readonly EMPTY_IMAGE_HEIGHT: string = '51%';
  /*
   * The empty data text component margin top.
   */
  readonly TEXT_MARGIN_TOP: string = '0.5%';
  /*
   * The cross bar symbol stitching
   */
  readonly CROSS_BAR_SYMBOL: string = '--';
  /*
   * The slashes splicing.
   */
  readonly SLASHES: string = '/';
  /*
   * The target value splicing
   */
  readonly TARGET_VALUE_SPLICING: string = this.CROSS_BAR_SYMBOL + this.SLASHES;
  /**
   * The list component space.
   */
  readonly LIST_SPACE: number = 5;
  /**
   * The list component two lanes.
   */
  readonly LIST_TWO_LANES: number = 2;
  /**
   * The empty data text opacity.
   */
  readonly TEXT_OPACITY: number = 0.4;
  /**
   * The target text opacity.
   */
  readonly TARGET_TEXT_OPACITY: number = 0.6;
  /**
   * The target text weight.
   */
  readonly TARGET_TEXT_WEIGHT: number = 1;
  /**
   * The text slightly bold.
   */
  readonly TEXT_SLIGHTLY_BOLD: number = 500;

  build() {
    Column() {
      if (this.dayTaskInfos.length > 0) {
        List({ space: this.LIST_SPACE }) {
          ForEach(this.dayTaskInfos, (taskItem: DayTaskInfo) => {
            ListItem() {
              this.AgencyComponent(taskItem)
            }
            .margin({
              right: $r("app.float.agency_item_margin")
            })
            .borderRadius($r("app.float.agency_item_radius"))
            .backgroundColor(Color.White)
          }, (item: DayTaskInfo, index: number) => index + JSON.stringify(item))
        }
        .padding({
          left: $r('app.float.agency_padding_left'),
          top: $r('app.float.agency_padding_top'),
          right: $r('app.float.agency_padding_right'),
          bottom: $r('app.float.agency_padding_bottom')
        })
        .lanes(this.LIST_TWO_LANES)
        .backgroundColor($r("app.color.list_background_color"))
        .width(this.FULL_WIDTH_PERCENT)
        .height(this.FULL_HEIGHT_PERCENT)
      } else {
        this.AgencyNoData()
      }
    }
  }

  @Builder
  AgencyComponent(taskItem: DayTaskInfo) {
    Row() {
      Image(taskBaseInfoList[taskItem.taskId].icon)
        .width($r('app.float.agency_image_size'))
        .height($r('app.float.agency_image_size'))
        .objectFit(ImageFit.Contain)

      Row() {
        if (taskBaseInfoList[taskItem.taskId].step === 0) {
          Text(taskItem.isDone ? taskItem.targetValue : this.TARGET_VALUE_SPLICING + taskItem.targetValue)
            .fontWeight(FontWeight.Normal)
            .fontColor($r("app.color.text_common_color"))
            .fontSize($r("app.float.text_common_size"))
            .opacity(this.TARGET_TEXT_OPACITY)
            .textAlign(TextAlign.End)
        } else {
          Text(taskItem.finValue === '' ? this.CROSS_BAR_SYMBOL : taskItem.finValue)
            .fontWeight(taskItem.finValue === '' ? FontWeight.Normal : this.TEXT_SLIGHTLY_BOLD)
            .fontColor(taskItem.finValue === '' ? $r('app.color.hex_common_color') : $r('app.color.text_common_color'))
            .fontSize(taskItem.finValue === '' ? $r("app.float.text_common_size") : $r('app.float.agency_text_bold'))

          Text(this.SLASHES + taskItem.targetValue)
            .fontWeight(FontWeight.Normal)
            .fontColor($r('app.color.hex_common_color'))
            .fontSize($r("app.float.text_common_size"))
        }

        Text(taskBaseInfoList[taskItem.taskId].unit)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.hex_common_color'))
          .fontSize($r("app.float.text_common_size"))
      }
      .layoutWeight(this.TARGET_TEXT_WEIGHT)
      .justifyContent(FlexAlign.End)

    }
    .padding({
      left: $r('app.float.agency_row_padding'),
      right: $r('app.float.agency_row_padding')
    })
    .width(this.FULL_WIDTH_PERCENT)
    .height(this.AGENCY_COMPONENT_HEIGHT)
    .onClick(() => {
      this.jumpToAbility();
    })
  }

  @Builder
  AgencyNoData() {
    Column() {
      Image($r('app.media.ic_no_data'))
        .width(this.EMPTY_IMAGE_WIDTH)
        .height(this.EMPTY_IMAGE_HEIGHT)
        .objectFit(ImageFit.Contain)

      Text($r('app.string.agency_no_task'))
        .fontWeight(FontWeight.Normal)
        .fontColor(Color.White)
        .fontSize($r('app.float.empty_data_size'))
        .opacity(this.TEXT_OPACITY)
        .margin({
          top: this.TEXT_MARGIN_TOP
        })
    }
    .justifyContent(FlexAlign.Center)
    .width(this.FULL_WIDTH_PERCENT)
    .height(this.FULL_HEIGHT_PERCENT)
    .backgroundColor($r("app.color.no_data_background"))
    .onClick(() => {
      this.jumpToAbility();
    })
  }

  jumpToAbility() {
    postCardAction(this, {
      'action': this.ACTION_TYPE,
      'abilityName': this.ABILITY_NAME
    });
  }
}