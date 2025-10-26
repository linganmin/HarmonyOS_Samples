/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { CodeView } from '../../../commoncomponents/CodeView';
import { ViewCodeText } from '../../../commoncomponents/ViewCodeText';
import { TitleBarDark } from '../../../commoncomponents/TitleBarDark';
import { TitleBar } from '../../../commoncomponents/TitleBar';

@Entry
@Component
struct StoragePropAbilityPage {
  @State title: Resource = $r('app.string.abilityone_page');
  // Initializes the minimum font size.
  private minFontSize: number = 10;
  // Bidirectional synchronization of night mode status with home page and Ability2 page.
  @StorageLink('currentModelStatus') currentModelStatus: boolean = true;
  // Unidirectional synchronization of content font size with home page and Ability2 page.
  @StorageProp('contentFontSize') contentFontSize: number = 18;

  build() {
    Column() {
      if (this.currentModelStatus) {
        TitleBarDark({ title: $title, isAbility: true })
      } else {
        TitleBar({ title: $title, isAbility: true })
      }
      CodeView({ title: $title, isShowTitle: false }) {
        Column({ space: 20 }) {
          // View source code.
          ViewCodeText({ webSrc: $rawfile('StoragePropAbilityPage.ets.html') })
          Text($r('app.string.both_data_binding'))
            .fontSize(this.contentFontSize)
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .width('100%')
            .textAlign(TextAlign.Center)
          Text($r('app.string.single_data_binding'))
            .fontSize(this.contentFontSize)
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .width('100%')
            .textAlign(TextAlign.Center)
          Button() {
            Text(this.currentModelStatus ? $r('app.string.close_nightmode') : $r('app.string.start_nightmode'))
              .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
              .fontSize(this.contentFontSize)
              .width('60%')
              .textAlign(TextAlign.Center)
          }
          .id('storagePropAbilityPage')
          .padding($r('app.float.page_padding'))
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.button_background_color'))
          .onClick(() => {
            // The variables that control the night mode status are updated.
            // The data variables associated with @StorageLink and @StorageProp are refreshed.
            this.currentModelStatus = !this.currentModelStatus;
          })

          Text($r('app.string.nigntmode_both_binding'))
            .fontSize(this.contentFontSize)
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .width('100%')
            .textAlign(TextAlign.Center)
          // The slider module controls the font size.
          Column() {
            Text($r('app.string.fontSize_text'))
              .fontSize(this.contentFontSize)
              .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
              .width('100%')
              .textAlign(TextAlign.Center)
            Row() {
              Text(`${this.minFontSize}`)
                .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
                .fontSize($r('app.float.tips_font_size'))
              Slider({
                value: this.contentFontSize,
                min: this.minFontSize,
                max: 30, // Maximum font size.
                style: SliderStyle.OutSet
              })
                .showTips(true)
                .onChange((value: number, mode: SliderChangeMode) => {
                  // Variable data controlling font size was updated.
                  // Data variables associated with @StorageLink were not updated and synchronized.
                  this.contentFontSize = value;
                })
              // toFixed(0) treats the slider return value to integer precision.
              Text(this.contentFontSize.toFixed(0))
                .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
                .fontSize($r('app.float.tips_font_size'))
            }
            .width('80%')
          }.margin({ top: 50 })

          Text($r('app.string.single_fontsize_binding'))
            .fontSize(this.contentFontSize)
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .width('100%')
            .margin({
              bottom: $r('app.float.margin_bottom')
            })
            .textAlign(TextAlign.Center)
        }
        .padding($r('app.float.page_padding'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentModelStatus ? $r('app.color.nightnode_color') : $r('app.color.background_shallow_grey'))
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate('sideBarShow', false);
  }
}