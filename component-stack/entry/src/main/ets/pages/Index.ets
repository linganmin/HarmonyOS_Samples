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

import { StackConstant } from '../constant/StackConstant';
import { IconList1, IconList2, IconList3 } from '../view/IconView';
import { ProductList } from '../view/ProductList';

@Entry
@Component
struct Index {
  @State searchHeight: number = StackConstant.SEARCH_HEIGHT_RAW;
  @State opacityList: number = 1;
  @State opacityList2: number = 1;
  @State ratio: number = 1;
  @State isChange: boolean = false;
  @State heightList2: number = StackConstant.HEIGHT_LIST_2_RAW;
  @State marginSpace: number = StackConstant.MAX_MARGIN_SPACE;
  @StorageLink('statusHeight') statusHeight: number = 0;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @StorageLink('screenHeight') screenHeight: number = 0;
  private scroller: Scroller = new Scroller();
  private scroller2: Scroller = new Scroller();

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Image($r("app.media.user_portrait"))
          .width($r('app.integer.user_portrait_width'))
          .aspectRatio(1)
          .borderRadius($r('app.integer.user_portrait_border_radius'))

        Image($r("app.media.stack_scan"))
          .width($r('app.integer.scan_width'))
          .aspectRatio(1)
      }
      .padding({
        left: $r('app.integer.flex_padding_left'),
        right: $r('app.integer.flex_padding_right'),
        top: $r('app.integer.flex_padding_top')
      })
      .width(StackConstant.FULL_PERCENT)
      .height($r('app.integer.flex_height'))

      Scroll(this.scroller) {
        Column() {
          Row() {
            Image($r('app.media.search'))
              .width($r('app.integer.search_width'))
              .aspectRatio(1)
              .margin({ left: $r('app.integer.search_icon_margin_left') })

            Text($r('app.string.search_title'))
              .opacity(StackConstant.OPACITY)
              .fontColor(Color.Black)
              .fontSize($r('app.integer.search_font_size'))
              .margin({ left: $r('app.integer.search_text_margin_left') })
          }
          .width(StackConstant.FULL_PERCENT)
          .height(this.searchHeight)
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.search_border_radius'))
          .onClick(() => {
            try {
              this.getUIContext()
                .getPromptAction()
                .showToast({ message: $r('app.string.component_stack_other_function') });
            } catch (error) {
              console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
            }
          });

          Stack({ alignContent: Alignment.Top }) {
            if (this.isChange) {
              Row() {
                IconList3({ marginSpace: this.marginSpace })
              }
              .backgroundColor($r('app.color.ohos_id_color_sub_background'))
              .width(StackConstant.FULL_PERCENT)
              .height($r('app.integer.icon_list_height3'))
              .opacity(this.opacityList)
              .zIndex(1)
            } else {
              Row() {
                IconList1()
              }
              .width(StackConstant.FULL_PERCENT)
              .height($r('app.integer.icon_list_height1'))
              .opacity(this.opacityList)
            }

            Scroll(this.scroller2) {
              Column() {
                Row() {
                  IconList2({ ratio: this.ratio })
                }
                .width(StackConstant.FULL_PERCENT)
                .height(this.heightList2)
                .opacity(this.opacityList2)

                ProductList()
                  .width(StackConstant.FULL_PERCENT)
                  .height(this.getUIContext().px2vp(this.screenHeight - this.statusHeight - this.bottomHeight) -
                  StackConstant.USED_SPACE)
              }
              .margin({ top: StackConstant.MARGIN_TOP })
            }
            .width(StackConstant.FULL_PERCENT)
            .scrollBar(BarState.Off)
            // Sets the nested scrolling mode in the forward and backward directions to implement scrolling linkage with the parent widget.
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST, // After the parent component is scrolled to the edge, the parent component is scrolled.
              scrollBackward: NestedScrollMode.SELF_FIRST // The parent component is scrolled after the parent component is scrolled to the edge.
            })
            .onScrollFrameBegin((offset: number) => {
              // Change the values of margin and opacity to move and hide the component.
              let yOffset: number = this.scroller2.currentOffset().yOffset;
              this.heightList2 = StackConstant.HEIGHT_LIST_2_RAW - yOffset * 0.5;

              // Set the transparency of IconList2 based on the yOffset value.
              if (1 - yOffset / StackConstant.ICON_LIST_2_RAW >= 0) {
                this.opacityList2 = 1 - yOffset / StackConstant.ICON_LIST_2_RAW;
              } else {
                this.opacityList2 = 0;
              }
              // Zoom with transparency settings.
              this.ratio = this.opacityList2;
              // Set the transparency of IconList1 and the margin of IconList3 based on yOffset.
              if (1 - yOffset / StackConstant.ICON_LIST_1_RAW > 0) {
                this.isChange = false;
                this.opacityList = 1 - yOffset / StackConstant.ICON_LIST_1_RAW;
                this.marginSpace = StackConstant.MAX_MARGIN_SPACE;
              } else {
                this.isChange = true;
                this.opacityList = (yOffset - StackConstant.ICON_LIST_1_RAW) / StackConstant.MAX_MARGIN_SPACE;
                this.marginSpace = StackConstant.ICON_LIST_3_RAW - yOffset > StackConstant.MIN_MARGIN_SPACE ?
                  (StackConstant.ICON_LIST_3_RAW - yOffset) : StackConstant.MIN_MARGIN_SPACE;
              }
              return { offsetRemain: offset };
            })
          }
        }
        .height(StackConstant.FULL_PERCENT)
        .width(StackConstant.FULL_PERCENT)
        .margin({ top: $r('app.integer.margin_search_view') })
      }
      .padding({ left: $r('app.integer.scroll_padding'), right: $r('app.integer.scroll_padding') })
      .width(StackConstant.FULL_PERCENT)
      .height(StackConstant.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .onScrollFrameBegin((offset: number) => {
        // Obtains the sliding distance.
        const yOffset: number = this.scroller.currentOffset().yOffset;
        this.searchHeight = StackConstant.SEARCH_HEIGHT_RAW - yOffset * 0.6;
        return { offsetRemain: offset };
      })
    }
    .width(StackConstant.FULL_PERCENT)
    .layoutWeight(1)
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .padding({ top: $r('app.integer.stack_padding_top') })
  }
}