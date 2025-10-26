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

import { Constants } from "../common/constant/Constants";
import InTabsComponent from "./InTabsComponent";
import OtherTabContentComponent from "./OtherTabComponent";

// [Start double_tabs_1]
// [Start custom_style_1]
// [Start custom_linkage]
@Component
export default struct OutTabsComponent {
  // [StartExclude double_tabs_1]
  @State currentIndex: number = 0;
  // [EndExclude double_tabs_1]
  // [StartExclude custom_style_1]
  // [StartExclude custom_linkage]
  @State @Watch('onchangeSwitchNext') switchNext: boolean = false;
  // [StartExclude double_tabs_1]
  private tabsController: TabsController = new TabsController();
  // [EndExclude double_tabs_1]
  onchangeSwitchNext() {
    if (this.switchNext) {
      this.switchNext = false;
      this.tabsController.changeIndex(1);
    }
  }
  // [EndExclude custom_linkage]
  // [StartExclude double_tabs_1]
  // [Start custom_style_2]
  @Builder
  tabBuilder(index: number, name: string | Resource, icon: Resource) {
    Column() {
      // set special styles if selected

      SymbolGlyph(icon).fontColor([this.currentIndex === index
        ? $r('app.color.out_tab_bar_font_active_color')
        : $r('app.color.out_tab_bar_font_inactive_color')])
        .fontSize(25)

      Text(name)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndex === index
          ? $r('app.color.out_tab_bar_font_active_color')
          : $r('app.color.out_tab_bar_font_inactive_color'))
    }
    // [StartExclude custom_linkage]
    .justifyContent(FlexAlign.Center)
    .height(Constants.FULL_HEIGHT)
    .width(Constants.FULL_WIDTH)
    .padding({ bottom: 60 })
    // .backgroundColor($r('app.color.out_tab_bar_background_color'))
    // [EndExclude custom_linkage]
  }
  // [Start disable_scroll_switch]
  // [EndExclude double_tabs_1]
  // [End custom_style_2]
  build() {
    // [Start bar_position_end]
    // [Start tabs_vertical]
    // [Start custom_style_3]
    Tabs({
      // [StartExclude disable_scroll_switch]
      // [StartExclude double_tabs_1]
      // [StartExclude custom_style_3]
      // [StartExclude tabs_vertical]
      // [StartExclude custom_linkage]
      barPosition: BarPosition.End,
      // [StartExclude bar_position_end]
      index: this.currentIndex,
      // [EndExclude double_tabs_1]
      controller: this.tabsController,
      // [EndExclude disable_scroll_switch]
      // [EndExclude custom_style_3]
      // [EndExclude bar_position_end]
      // [EndExclude tabs_vertical]
      // [EndExclude custom_linkage]
    }) {
      // [StartExclude disable_scroll_switch]
      // [StartExclude bar_position_end]
      // [StartExclude tabs_vertical]
      // [StartExclude custom_linkage]
      TabContent() {
        InTabsComponent({ switchNext: this.switchNext })
      }.tabBar(this.tabBuilder(0, $r('app.string.out_bar_text_home'), $r('sys.symbol.house')))
      // [StartExclude double_tabs_1]
      // [StartExclude custom_style_3]
      TabContent() {
        OtherTabContentComponent({ bgColor: Color.Blue })
      }
      .tabBar(this.tabBuilder(1, $r('app.string.out_bar_text_discover'), $r('sys.symbol.map_badge_local')))

      TabContent() {
        OtherTabContentComponent({ bgColor: Color.Yellow })
      }
      .tabBar(this.tabBuilder(2, $r('app.string.out_bar_text_messages'), $r('sys.symbol.ellipsis_message')))

      TabContent() {
        OtherTabContentComponent({ bgColor: Color.Orange })
      }
      .tabBar(this.tabBuilder(3, $r('app.string.out_bar_text_profile'), $r('sys.symbol.person')))
      // [EndExclude disable_scroll_switch]
      // [EndExclude double_tabs_1]
      // [EndExclude custom_style_3]
      // [EndExclude bar_position_end]
      // [EndExclude tabs_vertical]
      // [EndExclude custom_linkage]
    }
    // [End bar_position_end]
    // [StartExclude double_tabs_1]
    // [StartExclude disable_scroll_switch]
    // [StartExclude custom_linkage]
    // [StartExclude custom_style_3]
    .vertical(false) // true to make the tab bar in side
    // [End tabs_vertical]
    .barMode(BarMode.Fixed)
    // [EndExclude disable_scroll_switch]
    .scrollable(true) // false to disable scroll to switch
    // .edgeEffect(EdgeEffect.None) // disables edge springback
    // [StartExclude disable_scroll_switch]
    // [EndExclude custom_style_3]
    // [EndExclude custom_linkage]
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    // [End custom_style_3]
    // [StartExclude custom_linkage]
    .height(Constants.FULL_HEIGHT)
    .width(Constants.FULL_WIDTH)
    .backgroundColor($r('app.color.out_tab_bar_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .barHeight(120)
    .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .barOverlap(true)
    // [EndExclude disable_scroll_switch]
    // [EndExclude double_tabs_1]
    // [EndExclude custom_linkage]
  }
  // [End disable_scroll_switch]
  // [EndExclude custom_style_1]
}
// [End double_tabs_1]
// [End custom_style_1]
// [End custom_linkage]