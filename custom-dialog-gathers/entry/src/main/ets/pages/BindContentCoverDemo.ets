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
import { curves } from '@kit.ArkUI';
import { ComposeListItem } from "@kit.ArkUI";
import { CommonConstants } from '../common/constants/CommonConstants';
import { PersonList, personList } from '../viewmodel/BindContentModel';

@Entry
@Component
struct BindContentCoverDemo {
  private personList: Array<PersonList> = personList;
  @State isPresent: boolean = false;

  @Builder
  MyBuilder() {
    Column() {
      Row()
        .backgroundColor(Color.White)
        .height($r('app.float.blank_height'))
      Row() {
        Text($r('app.string.select_person'))
          .fontSize($r('app.float.font_size'))
          .fontColor(Color.Black)
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .textAlign(TextAlign.Center)
          .padding({
            top: $r('app.float.corner_radius_default_m'),
            bottom: $r('app.float.column_padding')
          })
      }
      .backgroundColor($r('app.color.start_window_background'))

      Row() {
        Text($r('app.string.add_person'))
          .fontSize($r('app.float.font_size1'))
          .fontColor($r('app.color.color_bind_sheet'))
          .margin({ top: $r('app.float.text_margin') })
          .padding({ top: $r('app.float.train_image_size'), bottom: $r('app.float.train_image_size') })
          .width(CommonConstants.NINETY_TWO_PERCENT)
          .borderRadius($r('app.float.text_size_headline'))
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
      }
      .margin({ bottom: $r('app.float.text_margin') })

      Column() {
        ForEach(this.personList, (item: PersonList, index: number) => {
          Row() {
            if (index % 2 == 0) {
              Checkbox()
                .select(true)
            } else {
              Checkbox()
                .select(false)
            }
            ComposeListItem({
              contentItem: ({
                primaryText: item.name,
                secondaryText: item.cardNum
              }),
              operateItem: ({
                text: $r('app.string.edit')
              })
            })
          }
          .padding({
            left: $r('app.float.text_margin'),
            right: $r('app.float.row_padding')
          })
        }, (item: PersonList) => JSON.stringify(item))
      }
      .width(CommonConstants.NINETY_TWO_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.text_size_headline'))

      Text($r('app.string.confirmed'))
        .margin({ top: $r('app.float.margin_large') })
        .width(CommonConstants.NINETY_TWO_PERCENT)
        .height($r('app.float.text_height'))
        .textAlign(TextAlign.Center)
        .borderRadius($r('app.float.train_image_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.color_warning'))
        .onClick(() => {
          this.isPresent = !this.isPresent;
        })
    }
    .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .backgroundColor($r('app.color.dialog_background'))
    .transition(TransitionEffect.translate({ y: CommonConstants.TRANSLATE })
      .animation({
        curve: curves.springMotion(CommonConstants.ZERO_SIX, CommonConstants.ZERO_EIGHT)
      }))
  }

  build() {
    Navigation() {
      Column() {
        Row() {
          Text($r('app.string.confirm_order'))
            .fontSize($r('app.float.font_size'))
            .fontColor(Color.White)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .textAlign(TextAlign.Center)
            .padding({ top: $r('app.float.row_padding'), bottom: $r('app.float.row_height') })
        }
        .backgroundColor($r('app.color.color_warning'))

        Column() {
          Row() {
            Column() {
              Text($r('app.string.start_time'))
              Text($r('app.string.start_string'))
            }
            .width(CommonConstants.THIRTY_PERCENT)

            Column() {
              Text($r('app.string.car_name'))
              Text($r('app.string.car_time'))
            }
            .width(CommonConstants.THIRTY_PERCENT)

            Column() {
              Text($r('app.string.end_time'))
              Text($r('app.string.end_name'))
            }
            .width(CommonConstants.THIRTY_PERCENT)
          }
        }
        .width(CommonConstants.NINETY_TWO_PERCENT)
        .padding($r('app.float.column_padding'))
        .margin({ top: $r('app.float.column_margin') })
        .backgroundColor(Color.White)
        .shadow({ radius: $r('app.float.row_padding'), color: $r('app.color.color_shadow') })
        .borderRadius($r('app.float.text_margin'))

        Column() {
          Button($r('app.string.button_select'))
            .fontSize($r('app.float.font_size3'))
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .borderRadius($r('app.float.text_size_headline'))
            .bindContentCover(this.isPresent, this.MyBuilder(), ModalTransition.DEFAULT)
            .onClick(() => {
              this.isPresent = !this.isPresent;
            })
        }
        .height(CommonConstants.SEVENTY_FIVE_PERCENT)
        .justifyContent(FlexAlign.End)
        .padding({ left: $r('app.float.text_size_headline'), right: $r('app.float.text_size_headline') })
      }
    }
    .title($r('app.string.dialog_name'))
    .titleMode(NavigationTitleMode.Mini)
  }
}