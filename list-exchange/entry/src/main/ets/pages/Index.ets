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

import { ListInfo } from '../viewModel/ListInfo';
import { CommonConstants } from '../constants/CommonConstants';
import { ListExchangeCtrl } from '../viewModel/ListExchangeCtrl';

@Entry
@Component
struct Index {
  UIContext = this.getUIContext()

  @Provide appInfoList: ListInfo[] = CommonConstants.MEMO_DATA;
  @Provide currentData: ListInfo = new ListInfo();
  @State listExchangeCtrl: ListExchangeCtrl<ListInfo> = new ListExchangeCtrl(this.appInfoList, this.UIContext);
  @StorageLink('isLongPress') isLongPress: boolean = false;

  @Builder
  deleteBuilder(item: ListInfo) {
    Image($r("app.media.list_exchange_icon_delete"))
      .width($r('app.float.list_exchange_icon_size'))
      .height($r('app.float.list_exchange_icon_size'))
      .objectFit(ImageFit.Cover)
      .margin({ right: $r('app.float.list_exchange_delete_icon_margin_right') })
      .interpolation(ImageInterpolation.High)
      .onClick(() => {
        this.listExchangeCtrl.deleteItem(item);
      })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.list_exchange_deduction_sort'))
          .fontSize($r('app.float.list_exchange_title_font_size'))
          .textAlign(TextAlign.Start)
        Blank()
        Text($r('app.string.list_exchange_custom_sort'))
          .fontSize($r('app.float.list_exchange_title_font_size'))
      }
      .padding({
        left: $r('app.float.ohos_id_card_padding_start'),
        right: $r('app.float.ohos_id_card_padding_start')
      })
      .margin({
        top: $r('app.float.ohos_id_elements_margin_vertical_l'),
        bottom: $r('app.float.ohos_id_elements_margin_vertical_l')
      })
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.list_exchange_title_height'))

      List() {
        ForEach(this.appInfoList, (item: ListInfo) => {
          ListItem() {
            DeductionView({ listItemInfo: item })
          }
          .zIndex(this.currentData === item ? CommonConstants.COMPONENT_LEVEL1 : CommonConstants.COMPONENT_LEVEL2)
          .swipeAction({ end: this.deleteBuilder(item) })
          .transition(TransitionEffect.OPACITY)
          .attributeModifier(this.listExchangeCtrl.getModifier(item))
          .gesture(
            GestureGroup(GestureMode.Sequence,
              LongPressGesture()
                .onAction((_: GestureEvent) => {
                  this.currentData = item;
                  this.isLongPress = true;
                  this.listExchangeCtrl.onLongPress(item);
                }),
              PanGesture()
                .onActionUpdate((event: GestureEvent) => {
                  this.listExchangeCtrl.onMove(item, event.offsetY);
                })
                .onActionEnd((_: GestureEvent) => {
                  this.listExchangeCtrl.onDrop(item);
                })
            ).onCancel(() => {
              if (!this.isLongPress) {
                return;
              }
              this.listExchangeCtrl.onDrop(item);
            })
          )
        }, (item: ListInfo, index: number) => index + JSON.stringify(item))
      }
      .backgroundColor(Color.White)
      .divider({ strokeWidth: $r('app.float.divider_stroke_width'), color: 0xeaf0ef })
      .scrollBar(BarState.Off)
      .borderRadius($r('app.float.ohos_id_corner_radius_default_l'))
      .backgroundColor(Color.White)
      .width(CommonConstants.FULL_PERCENT)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.list_exchange_background_color'))
    .padding({
      left: $r('app.float.ohos_id_card_padding_start'),
      right: $r('app.float.ohos_id_card_padding_start')
    })
  }
}

/**
 * ListItem Custom Component
 */
@Component
struct DeductionView {
  @ObjectLink listItemInfo: ListInfo;
  @Consume appInfoList: ListInfo[];
  @Consume currentData: ListInfo;

  build() {
    Row() {
      Image(this.listItemInfo.icon)
        .width($r('app.float.list_exchange_icon_size'))
        .height($r('app.float.list_exchange_icon_size'))
        .draggable(false)
      Text(this.listItemInfo.name)
        .fontSize($r('app.float.list_item_font_size'))
        .margin({ left: $r('app.float.ohos_id_elements_margin_vertical_l') })
      Blank()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.ITEM_HEIGHT)
    .backgroundColor(Color.White)
    .padding({
      left: $r('app.float.ohos_id_card_padding_start'),
      right: $r('app.float.ohos_id_card_padding_start')
    })
  }
}