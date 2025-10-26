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

import { TabContentConstants } from '../common/TabContentConstants';
import { Utils } from '../common/Utils';

@Component
export struct TopView {
  private utils = new Utils();

  build() {
    RelativeContainer() {
      Image($r("app.media.tab_search_icon"))
        .width($r('app.integer.tab_search_icon_width'))
        .height($r('app.integer.tab_search_icon_height'))
        .id(TabContentConstants.TAB_SEARCH_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
        })
        .margin({
          top: $r('app.integer.tab_search_image_margin'),
          left: $r('app.integer.tab_search_image_margin')
        })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text($r('app.string.tab_focus'))
        .fontColor($r('app.color.tab_font_color'))
        .fontSize($r('app.integer.tab_tab_font_size'))
        .width($r('app.string.tab_focus_width'))
        .id(TabContentConstants.TAB_FOLLOW_TEXT)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_SEARCH_IMAGE, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_SEARCH_IMAGE, align: HorizontalAlign.End }
        })
        .textAlign(TextAlign.Center)
        .margin({ left: $r('app.integer.tab_search_image_margin') })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text($r('app.string.tab_selected'))
        .fontColor(Color.White)
        .fontSize($r('app.integer.tab_tab_font_size'))
        .width($r('app.string.tab_focus_width'))
        .id(TabContentConstants.TAB_SELECTED_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_FOLLOW_TEXT, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_FOLLOW_TEXT, align: HorizontalAlign.End }
        })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text($r('app.string.tab_recommendation'))
        .fontColor($r('app.color.tab_font_color'))
        .fontSize($r('app.integer.tab_tab_font_size'))
        .width($r('app.string.tab_focus_width'))
        .id(TabContentConstants.TAB_RECOMMENDATION_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_SELECTED_TEXT, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_SELECTED_TEXT, align: HorizontalAlign.End }
        })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text($r('app.string.tab_screening_hall'))
        .fontColor($r('app.color.tab_font_color'))
        .fontSize($r('app.integer.tab_tab_font_size'))
        .width($r('app.string.tab_focus_width'))
        .id(TabContentConstants.TAB_SCREENING_HALL_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_RECOMMENDATION_TEXT, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_RECOMMENDATION_TEXT, align: HorizontalAlign.End }
        })
        .margin({ right: $r('app.integer.tab_search_image_margin') })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Divider()
        .width($r('app.integer.tab_tab_divider_width'))
        .strokeWidth(TabContentConstants.TAB_TWO)
        .color(Color.White)
        .margin({ top: $r('app.integer.tab_divider_margin_top') })
        .id(TabContentConstants.TAB_TOP_VIEW_DIVIDER)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_SELECTED_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_SELECTED_TEXT, align: HorizontalAlign.Center }
        })
        .margin({
          top: $r('app.integer.tab_top_view_divider_margin_top'),
          left: $r('app.integer.tab_top_view_divider_margin_left')
        })
      Image($r("app.media.tab_add"))
        .width($r('app.integer.tab_search_icon_width'))
        .height($r('app.integer.tab_search_icon_height'))
        .id(TabContentConstants.TAB_ADD_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Top },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({
          top: $r('app.integer.tab_search_image_margin'),
          right: $r('app.integer.tab_search_image_margin')
        })
        .onClick(() => {
          this.utils.showPromptAction();
        })
    }
    .height($r('app.integer.tab_top_view_relative_container_height'))
  }
}