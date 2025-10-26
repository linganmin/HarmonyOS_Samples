/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../common/constants/CommonConstants';
import { SectionsPage } from '../view/SectionsWaterFlowComponent';

@Component
export struct SectionsHomePage {
  @State currentIndex: number = 0;
  @State changeValue: string = '';
  @State tabsIndex: number = 0;
  @Consume('pathInfos') pathInfos: NavPathStack;
  tabsController: TabsController = new TabsController();
  controller: SearchController = new SearchController();

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Row() {
      Text(name)
        .constraintSize({ minWidth: $r('app.float.sections_tab_width') })
        .textAlign(TextAlign.Center)
        .fontSize($r('app.float.tab_font_size'))
        .fontColor(this.tabsIndex === index ? Color.White : Color.Black)
        .height('100%')
        .padding({ left: $r('app.float.tab_text_padding_left'), right: $r('app.float.tab_text_padding_right') })
        .backgroundColor(this.tabsIndex === index ? $r('app.color.sections_tab_color_selected') :
        $r('app.color.sections_tab_color_normal'))
        .borderRadius($r('app.float.sections_tab_radius'))
    }
    .padding({
      top: $r('app.float.tab_padding_top'),
      bottom: $r('app.float.tab_padding_bottom'),
      left: 0,
      right: $r('app.float.tab_padding_right')
    })
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.tab_height'))
    .align(Alignment.Center)
    .onClick(() => {
      this.tabsIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width($r('app.float.sections_back_width'))
          .height($r('app.float.sections_back_height'))
          .padding($r('app.float.sections_back_padding'))
          .borderRadius($r('app.float.sections_tab_radius'))
          .backgroundColor($r('app.color.sections_back_bg'))
          .onClick(() => {
            this.pathInfos.pop();
          })
        Search({ value: this.changeValue, placeholder: '', controller: this.controller })
          .searchButton(CommonConstants.SEARCH_TEXT)
          .layoutWeight(1)
          .margin({ left: $r('app.float.sections_margin') })
          .backgroundColor($r('app.color.sections_back_bg'))
      }
      .margin({
        left: $r('app.float.sections_page_margin_left_right'),
        right: $r('app.float.sections_page_margin_left_right'),
        top: $r('app.float.sections_page_margin_top_bottom'),
        bottom: $r('app.float.sections_page_margin_top_bottom'),
      })

      Tabs({ index: this.currentIndex, controller: this.tabsController }) {
        TabContent() {
          SectionsPage()
        }
        .tabBar(this.tabBuilder(0, $r('app.string.sticky_tab_all')))

        TabContent() {
          SectionsPage()
        }
        .tabBar(this.tabBuilder(1, $r('app.string.sticky_tab_merchant')))

        TabContent() {
          SectionsPage()
        }
        .tabBar(this.tabBuilder(2, $r('app.string.sticky_tab_note')))

        TabContent() {
          SectionsPage()
        }
        .tabBar(this.tabBuilder(3, $r('app.string.sticky_tab_group_buy')))

        TabContent() {
          SectionsPage()
        }
        .tabBar(this.tabBuilder(4, $r('app.string.sticky_tab_user')))
      }
      .padding({
        left: $r('app.float.sections_page_margin_left_right'),
        right: $r('app.float.sections_page_margin_left_right')
      })
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
  }
}