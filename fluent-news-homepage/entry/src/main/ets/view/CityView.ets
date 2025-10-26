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


import { CityType, CITY_DATA, HOT_CITY, TAB_VALUE } from '../viewmodel/CityDetailData';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct CityView {
  @State stabIndex: number = CommonConstants.ZERO;
  @State location: boolean = true;
  @Link isSearchState: boolean;
  @StorageProp('currentLocal') currentLocal: string = '';
  private scroller: Scroller = new Scroller();
  curCity: string = '';
  controller: SearchController = new SearchController();

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text($r('app.string.location'))
            .fontSize($r('app.integer.text_font'))
            .fontColor($r('app.color.text_font_color'))
            .opacity(CommonConstants.TEXT_OPACITY[2])
            .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.row_margin_bottom') })

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
            Text(this.currentLocal)
              .margin({ bottom: $r('app.integer.text_margin_bottom'), left: $r('app.integer.text_margin_left2') })
              .width($r('app.string.city_text_width'))
              .height($r('app.integer.text_height'))
              .textAlign(TextAlign.Center)
              .fontSize($r('app.integer.text_font'))
              .maxLines(CommonConstants.MAX_LINES)
              .fontColor($r('app.color.text_font_color2'))
              .backgroundColor($r('app.color.text_bgc'))
              .borderRadius($r('app.integer.text_border_radius'))
              .onClick(() => {
                AppStorage.setOrCreate('local', this.currentLocal);
                this.getUIContext().getRouter().back();
              })
          }
          .width(CommonConstants.FULL_PERCENT)

          Text($r('app.string.hotCity'))
            .fontSize($r('app.integer.text_font'))
            .fontColor($r('app.color.text_font_color'))
            .opacity(CommonConstants.TEXT_OPACITY[2])
            .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.row_margin_bottom') })

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
            ForEach(HOT_CITY, (item: string) => {
              Text(`${item}`)
                .margin({ bottom: $r('app.integer.text_margin_bottom'), left: $r('app.integer.text_margin_left2') })
                .width($r('app.string.city_text_width'))
                .height($r('app.integer.text_height'))
                .textAlign(TextAlign.Center)
                .fontSize($r('app.integer.text_font'))
                .maxLines(CommonConstants.MAX_LINES)
                .fontColor($r('app.color.text_font_color2'))
                .backgroundColor($r('app.color.text_bgc'))
                .borderRadius($r('app.integer.text_border_radius'))
                .onClick(() => {
                  AppStorage.setOrCreate('local', item);
                  this.getUIContext().getRouter().back();
                })
            }, (item: string) => JSON.stringify(item))
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding({ right: $r('app.string.city_padding_right') })

          List({
            space: CommonConstants.LIST_ITEM_SPACE,
            initialIndex: CommonConstants.ZERO,
            scroller: this.scroller
          }) {
            ForEach(CITY_DATA, (index: CityType) => {
              ListItem() {
                Column() {
                  Text(`${index.name}`)
                    .height($r('app.integer.list_item_height'))
                    .fontSize($r('app.integer.font_size'))
                    .fontColor($r('app.color.text_font_color'))
                    .width(CommonConstants.FULL_PERCENT)
                  ForEach(index.city, (item: string) => {
                    Text(item)
                      .height($r('app.integer.list_item_height'))
                      .fontSize($r('app.integer.text_font'))
                      .width(CommonConstants.FULL_PERCENT)
                      .onClick(() => {
                        AppStorage.setOrCreate('local', item);
                        this.getUIContext().getRouter().back();
                      })
                  }, (item: string) => JSON.stringify(item))
                }
              }
            }, (item: CityType) => JSON.stringify(item))
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.txt_margin_bottom') })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
          .edgeEffect(EdgeEffect.None)
          .divider({
            strokeWidth: $r('app.integer.divider_strokeWidth'),
            color: $r('app.color.divider_color'),
            startMargin: $r('app.integer.divider_start'),
            endMargin: $r('app.integer.divider_end')
          })
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
          .onScrollIndex((firstIndex: number, lastIndex: number) => {
            this.stabIndex = firstIndex;
          })
        }
        .alignItems(HorizontalAlign.Start)

        // [Start alphabet_indexer]
        // CityView.ets
        AlphabetIndexer({ arrayValue: TAB_VALUE, selected: this.stabIndex })
          .height(CommonConstants.FULL_PERCENT)
          .selectedColor($r('app.color.alphabet_select_color'))
          .popupColor($r('app.color.alphabet_pop_color'))
          .selectedBackgroundColor($r('app.color.alphabet_selected_bgc'))
          .popupBackground($r('app.color.alphabet_pop_bgc'))
          .popupPosition({ x: $r('app.integer.pop_position_x'), y: $r('app.integer.pop_position_y') })
          .usingPopup(true)
          .selectedFont({ size: $r('app.integer.select_font'), weight: FontWeight.Bolder })
          .popupFont({ size: $r('app.integer.pop_font'), weight: FontWeight.Bolder })
          .alignStyle(IndexerAlign.Right)
          .itemSize(CommonConstants.ITEM_SIZE)
          .onSelect((tabIndex: number) => {
            this.scroller.scrollToIndex(tabIndex);
          })
        // [End alphabet_indexer]
      }
      .margin({ top: $r('app.integer.margin_top') })
    }
    .flexShrink(CommonConstants.LAYOUT_WEIGHT)
    .flexGrow(CommonConstants.LAYOUT_WEIGHT)
    .alignItems(HorizontalAlign.Start)
    .padding({ bottom: $r('app.integer.padding_bottom') })
    .visibility(this.isSearchState ? Visibility.None : Visibility.Visible)
  }
}