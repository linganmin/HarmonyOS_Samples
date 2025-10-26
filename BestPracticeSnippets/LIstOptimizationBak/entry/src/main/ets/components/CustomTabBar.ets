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

import { AppConstants } from '../model/AppConstants';
import { TabBarData, TabBarType, TabsInfo } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @Link currentIndex: TabBarType;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;

  build() {
    Flex({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceAround
    }) {
      ForEach(TabsInfo, (item: TabBarData) => {
        TabItem({
          index: item.id,
          selectedIndex: this.currentIndex,
        })
      }, (item: TabBarData) => item.id.toString())
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding({ bottom: 20 })
    .clip(false)
    .height(80)
    .width(AppConstants.FULL_PERCENT)
  }
}

@Component
struct TabItem {
  @Prop index: number
  @Prop selectedIndex: number;
  @State showAnimation: boolean = false;
  onChange: (index: number) => void = () => {
  };
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private mainCanvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mainRenderingSettings);

  build() {
    Column() {
      Image(this.selectedIndex === this.index ?
        (this.showAnimation ? TabsInfo[this.index].animationIcon : TabsInfo[this.index].activeIcon) :
      TabsInfo[this.index].defaultIcon)
        .size(this.index === TabBarType.CHALLENGE ?
          { width: $r('app.float.tab_big_img_width'), height: $r('app.float.tab_big_img_height') } :
          { width: $r('app.float.tab_img_size'), height: $r('app.float.tab_img_size') })
        .margin({ top: this.index === TabBarType.CHALLENGE ? $r('app.float.tab_margin') : 0 })
      Text(TabsInfo[this.index].title)
        .fontSize($r('app.float.tab_font_size'))
        .margin({ top: $r('app.float.tab_title_margin') })
        .fontWeight(AppConstants.TAB_FONT_WEIGHT)
        .fontColor($r('sys.color.ohos_id_color_bottom_tab_text_off'))
    }
    .clip(false)
    .padding({ top: $r('app.float.sm_padding_margin'), bottom: $r('app.float.sm_padding_margin') })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}