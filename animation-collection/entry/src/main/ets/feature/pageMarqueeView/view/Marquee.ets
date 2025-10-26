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

import { FunctionDescription } from '../common/FunctionDescription';
import { TripDataType } from '../model/DataType';
import Constants from '../model/Constants';
import { TripDataSource } from '../model/DataSource';

@Entry
@Component
struct MarqueeView {
  build() {
    Column() {
      FunctionDescription({
        title: $r('app.string.marquee_title'),
        content: $r('app.string.marquee_content')
      })
      TripView()
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .padding($r('app.string.ohos_id_card_padding_start'))
    .linearGradient({
      angle: Constants.ANGLE,
      colors: [[$r('app.color.marquee_bg_color1'), 0], [$r('app.color.marquee_bg_color2'), 1]]
    })
  }
}

@Component
struct TripView {
  @State tripData: TripDataSource = new TripDataSource();

  build() {
    Column() {
      Text($r('app.string.my_trip'))
        .width(Constants.FULL_SIZE)
        .fontSize($r('app.string.ohos_id_text_size_headline'))
        .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
      LazyForEach(this.tripData, (item: TripDataType) => {
        TripMessage({
          tripDataItem: item
        })
      }, (item: TripDataType) => JSON.stringify(item))
    }
  }
}

@Component
struct TripMessage {
  @State delay: number = 0;
  @State ticketCheckTextOffset: number = 0;
  @State ticketCheckTextWidth: number = 0;
  @State ticketCheckScrollWidth: number = 0;
  tripDataItem: TripDataType = {} as TripDataType;

  @Styles
  commonStyles(){
    .width(Constants.FULL_SIZE)
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
  }

  build() {
    Column() {
      Row() {
        Text(this.tripDataItem.trainNumber)
        Text(this.tripDataItem.wholeCourse)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.tripDataItem.startingTime)
          .fontSize($r('sys.float.ohos_id_text_size_headline6'))
          .width(Constants.TEXT_WIDTH_DEFAULT)
          .textAlign(TextAlign.Start)
        Text($r('app.string.plan_text'))
          .fontColor($r('app.color.ohos_id_color_emphasize'))
          .width(Constants.TEXT_WIDTH_MINI)
          .height(Constants.TEXT_HEIGHT_MINI)
          .textAlign(TextAlign.Center)
          .border({
            width: 1,
            radius: $r('app.string.ohos_id_corner_radius_default_m'),
            color: $r('app.color.ohos_id_color_emphasize')
          })
        Text(this.tripDataItem.endingTime)
          .fontSize($r('sys.float.ohos_id_text_size_headline6'))
          .width(Constants.TEXT_WIDTH_DEFAULT)
          .textAlign(TextAlign.End)

      }
      .commonStyles()
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.tripDataItem.origin)
        Text(this.tripDataItem.timeDifference)
        Text(this.tripDataItem.destination)
      }
      .commonStyles()
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Text($r('app.string.ticket_entrance'))
          Text(this.tripDataItem.ticketEntrance)
            .width(120)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
        }

        Row() {
          Text($r('app.string.vehicle_model'))
          Text(this.tripDataItem.vehicleModel)
        }
        .id('vehicleModel')
        .justifyContent(FlexAlign.End)
        .backgroundColor(Color.White)
      }
      .commonStyles()
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding($r('app.string.ohos_id_card_padding_start'))
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_l') })
    .backgroundColor(Color.White)
  }
}

@Builder
export function MarqueeViewContainer(name: string) {
  if (name === 'PageWaterMarqueeView') {
    NavDestination() {
      MarqueeView()
    }
  }
}

export const wrappedBuilderMarqueeView: WrappedBuilder<[string, number]> = wrapBuilder(MarqueeViewContainer);
