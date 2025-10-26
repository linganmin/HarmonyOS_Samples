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
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Component
export struct VideoDes {
  @State name: Resource =  $r('app.string.user');
  @State description: Resource = $r('app.string.desc');
  @State hotspot: Resource = $r('app.string.hot_dot');
  @State time: string = TabContentConstants.TAB_VIDEO_DES_TIME;

  private showPromptAction() {
    try {
      uiContext?.getPromptAction().showToast({
        message: $r('app.string.tab_toast_message'),
        duration: TabContentConstants.TAB_DURATION
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag',`showToast failed, Code:${error.code}, message:${error.message}`);
    }
  }

  build() {
    RelativeContainer() {
      Text(this.name)
        .fontSize($r('app.integer.tab_name_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .id(TabContentConstants.TAB_NAME_TEXT)
        .padding({ left: $r('app.integer.tab_name_text_margin_left') })
      Text(this.description)
        .fontSize($r('app.integer.tab_des_text_font_size'))
        .fontColor(Color.White)
        .maxLines(TabContentConstants.TAB_MAX_LINE)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .id(TabContentConstants.TAB_DESCRIPTION_TEXT)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_NAME_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_NAME_TEXT, align: HorizontalAlign.Start }
        })
        .margin({ top: $r('app.integer.tab_des_text_margin_top') })
        .padding({ left: $r('app.integer.tab_des_text_padding_left') })
      Text(this.time)
        .fontSize($r('app.integer.tab_time_text_font_size'))
        .fontColor($r('app.color.tab_time_text_font_color'))
        .id(TabContentConstants.TAB_TIME_TEXT)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_DESCRIPTION_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_DESCRIPTION_TEXT, align: HorizontalAlign.Start }
        })
        .padding({ left: $r('app.integer.tab_des_text_padding_left') })
      Text()
        .width($r('app.string.tab_full_size'))
        .height($r('app.integer.tab_upgrade_height'))
        .backgroundColor($r('app.color.tab_gray_background_color'))
        .opacity(TabContentConstants.TAB_OPACITY)
        .padding({
          left: $r('app.integer.tab_upgrade_padding'),
          right: $r('app.integer.tab_upgrade_padding')
        })
        .margin({ top: $r('app.integer.tab_gray_background_margin_top') })
        .id(TabContentConstants.TAB_GRAY_BACKGROUND)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_TIME_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_TIME_TEXT, align: HorizontalAlign.Start }
        })
        .onClick(() => {
          this.showPromptAction();
        })
      Image($r('app.media.tab_upgrade_filled'))
        .height($r('app.integer.tab_upgrade_icon_size'))
        .width($r('app.integer.tab_upgrade_icon_size'))
        .id(TabContentConstants.TAB_HOT_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_GRAY_BACKGROUND, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_GRAY_BACKGROUND, align: HorizontalAlign.Start }
        })
        .margin({
          top: $r('app.integer.tab_upgrade_filled_margin_top'),
          left: $r('app.integer.tab_des_text_padding_left')
        })
        .onClick(() => {
          this.showPromptAction();
        })
      Text($r('app.string.tab_upgrade_hot'))
        .fontSize($r('app.integer.tab_upgrade_text_font_size'))
        .fontColor($r('app.color.tab_up_color'))
        .id(TabContentConstants.TAB_HOT_TEXT)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_HOT_IMAGE, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_HOT_IMAGE, align: HorizontalAlign.End }
        })
        .onClick(() => {
          this.showPromptAction();
        })
      Text(this.hotspot)
        .fontSize($r('app.integer.tab_mus_font_size'))
        .fontColor(Color.White)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .id(TabContentConstants.TAB_HOT_SPOT)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_HOT_TEXT, align: VerticalAlign.Top },
          bottom: { anchor: TabContentConstants.TAB_HOT_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_HOT_TEXT, align: HorizontalAlign.End }
        })
        .onClick(() => {
          this.showPromptAction();
        })
      Image($r("app.media.tab_arrow_right"))
        .height($r('app.integer.tab_upgrade_icon_size'))
        .width($r('app.integer.tab_upgrade_icon_size'))
        .id(TabContentConstants.TAB_PEOPLE_NUM_ARROW)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_HOT_TEXT, align: VerticalAlign.Top },
          bottom: { anchor: TabContentConstants.TAB_HOT_TEXT, align: VerticalAlign.Bottom },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ right: $r('app.integer.tab_arrow_right_margin_right') })
        .onClick(() => {
          this.showPromptAction();
        })
      Text($r('app.string.tab_online_people'))
        .fontSize($r('app.integer.tab_mus_font_size'))
        .fontColor(Color.White)
        .id(TabContentConstants.TAB_PEOPLE_NUM)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_PEOPLE_NUM_ARROW, align: VerticalAlign.Top },
          bottom: { anchor: TabContentConstants.TAB_PEOPLE_NUM_ARROW, align: VerticalAlign.Bottom },
          right: { anchor: TabContentConstants.TAB_PEOPLE_NUM_ARROW, align: HorizontalAlign.Start }
        })
        .onClick(() => {
          this.showPromptAction();
        })
      Divider()
        .vertical(true)
        .color(Color.White)
        .strokeWidth(TabContentConstants.TAB_ONE)
        .height($r('app.integer.tab_upgrade_text_font_size'))
        .id(TabContentConstants.TAB_DIVIDER)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_PEOPLE_NUM_ARROW, align: VerticalAlign.Top },
          bottom: { anchor: TabContentConstants.TAB_PEOPLE_NUM_ARROW, align: VerticalAlign.Bottom },
          right: { anchor: TabContentConstants.TAB_PEOPLE_NUM, align: HorizontalAlign.Start }
        })
        .margin({ right: $r('app.integer.tab_divider_margin_right') })
        .onClick(() => {
          this.showPromptAction();
        })
    }
    .height($r('app.integer.tab_video_des_relative_container_height'))
  }
}