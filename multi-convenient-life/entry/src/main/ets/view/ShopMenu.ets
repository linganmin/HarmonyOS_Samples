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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { ShopMenuData, ShopMenuItem } from '../viewmodel/ShopDisplayViewModel';
import { ShopDish } from './ShopDish';

@Component
export struct ShopMenu {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @State tabsIndex: number = 0;
  @Consume('ifShowSides') ifShowSides: boolean;
  @Consume('ifScroll') ifScroll: boolean;
  bottomRectHeight: string = AppStorage.get<number>('bottomRectHeight') + 'px';
  topRectHeight: string = AppStorage.get<number>('topRectHeight') + 'px';
  private shopMenuList = new ShopMenuData().getMenuList();
  private scroller: Scroller = new Scroller();
  private tabsController: TabsController = new TabsController();
  private menuClassifyList: string[] =
    ['热销', '优惠', '招牌单品', '美味双拼', '精美小吃', '新品上架', '下单必点', '加料区'];

  build() {
    // [Start scroll_component]
    Row() {
      Column() {
        // [StartExclude scroll_component]
        ForEach(this.menuClassifyList, (item: string, index: number) => {
          Text(item)
            .height($r('app.float.menu_height'))
            .fontColor($r('app.color.sixty_black'))
            .textAlign(TextAlign.Center)
            .fontSize($r('app.float.ranking_font'))
            .onClick(() => {
              this.tabsIndex = index;
              this.tabsController.changeIndex(index);
            })
        })
        // [EndExclude scroll_component]
      }
      // [StartExclude scroll_component]
      .borderRadius({
        topRight: $r('app.float.enlarge_margin_left')
      })
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .width(this.ifShowSides ? new BreakpointType($r('app.float.menu_width_sm'), $r('app.float.menu_width_md'),
        $r('app.float.menu_width_lg')).getValue(this.currentBreakpoint) :
      new BreakpointType($r('app.float.menu_width_sm'), $r('app.float.menu_width_lg'),
        $r('app.float.menu_width_lg_show')).getValue(this.currentBreakpoint))
      .backgroundColor($r('app.color.swiper_choose_background'))

      // [EndExclude scroll_component]
      Scroll(this.scroller) {
        Column() {
          // [StartExclude scroll_component]
          Swiper() {
            Image($r('app.media.shopBanner1'))
            Image($r('app.media.shopBanner2'))
          }
          .indicator(false)
          .itemSpace(CommonConstants.DEFAULT_SPACE)
          .displayCount(this.ifShowSides ? new BreakpointType(1, 1, 2).getValue(this.currentBreakpoint) :
          new BreakpointType(1, 2, 2).getValue(this.currentBreakpoint))
          .margin({
            bottom: $r('app.float.margin_twelves')
          })

          List() {
            ForEach(this.menuClassifyList, () => {
              ListItem() {
                List() {
                  ForEach(this.shopMenuList, (item: ShopMenuItem) => {
                    ShopDish({ shopMenuItem: item, showSelectButton: true })
                  }, (item: string, index: number) => JSON.stringify(item) + JSON.stringify(index))
                }
                .width('auto')
                .height('auto')
              }
            }, (item: string, index: number) => item + JSON.stringify(index))
          }
          .width('auto')
          .height('auto')

          // [EndExclude scroll_component]
        }
      }
      // [StartExclude scroll_component]
      .onDidScroll(() => {
        this.ifScroll = true;
      })
      .onReachStart(() => {
        this.ifScroll = false;
      })
      .scrollBarWidth(0)
      .padding({
        left: $r('app.float.avatar_padding_left'),
        right: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint),
      })
      .layoutWeight(1)
      // [EndExclude scroll_component]
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    }
    // [End scroll_component]
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: $r('app.float.twelves_padding')
    })
  }
}