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

import { CommonModifier } from '@kit.ArkUI';
import InTabComponent from './InTabComponent';
import SwitchTabComponent from './SwitchTabComponent';

// [Start tabs_clip]
@Component
export default struct OutTabComponent {
  // [StartExclude tabs_clip]
  @State selectedIndex: number = 0;
  @State currentIndex: number = 0;
  @State tabBarModifier: CommonModifier = new CommonModifier();
  // [EndExclude tabs_clip]
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    this.tabBarModifier.clip(false);
  }

  // [StartExclude tabs_clip]
  @Builder
  tabBuilder(index: number, name: string | Resource, icon: Resource) {
    Column() {
      SymbolGlyph(icon).fontColor([this.selectedIndex === index
        ? $r('app.color.out_tab_bar_font_active_color')
        : $r('app.color.out_tab_bar_font_inactive_color')])
        .fontSize(25)

      Text(name)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.selectedIndex === index
          ? $r('app.color.out_tab_bar_font_active_color')
          : $r('app.color.out_tab_bar_font_inactive_color'))
    }
    .justifyContent(FlexAlign.Center)
    .height(60)
    .width('100%')
    .margin({bottom:60})
    .offset({ y: this.selectedIndex === index ? -18 : 0 })

  }
  // [EndExclude tabs_clip]

  build() {
    Column() {
      // [Start tabs_blur_style]
      Tabs({
        // [StartExclude tabs_blur_style]
        // [StartExclude tabs_clip]
        barPosition: BarPosition.End,
        index: this.currentIndex,
        controller: this.controller,
        // [EndExclude tabs_clip]
        barModifier: this.tabBarModifier
        // [EndExclude tabs_blur_style]
      }) {
        // [StartExclude tabs_blur_style]
        // [StartExclude tabs_clip]
        TabContent() {
          InTabComponent({isFadingEdge:false,isSetTabBarTranslateAndOpacity:false})
        }
        .tabBar(this.tabBuilder(0, $r('app.string.out_bar_text_home'), $r('sys.symbol.house')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])


        TabContent() {
          Column() {
            InTabComponent({isFadingEdge:true,isSetTabBarTranslateAndOpacity:false})
          }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        }.tabBar(this.tabBuilder(1, $r('app.string.out_bar_text_discover'), $r('sys.symbol.map_badge_local')))


        TabContent() {
          Column() {
            InTabComponent({isFadingEdge:false,isSetTabBarTranslateAndOpacity:true})
          }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        }.tabBar(this.tabBuilder(2, $r('app.string.out_bar_text_messages'), $r('sys.symbol.ellipsis_message')))


        TabContent() {
          Column() {
            SwitchTabComponent()
          }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        }.tabBar(this.tabBuilder(3, $r('app.string.out_bar_text_profile'), $r('sys.symbol.person')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        // [EndExclude tabs_blur_style]
        // [EndExclude tabs_clip]
      }
      // [StartExclude tabs_blur_style]
      // [StartExclude tabs_clip]
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barHeight(110)
      .onChange((index: number) => {
        this.currentIndex = index;
        this.selectedIndex = index;
      })
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
      .scrollable(true)
      // [EndExclude tabs_blur_style]
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.Thin)
      // [End tabs_blur_style]
      // [EndExclude tabs_clip]

    }
    .width('100%')
    .height('calc(100% + 60vp)')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
// [End tabs_clip]