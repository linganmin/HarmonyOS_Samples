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

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let storage: LocalStorage = uiContext?.getSharedLocalStorage()!;

@Entry(storage)
@Component
struct StoragePropAbilityPage {
  @State title: Resource = $r('app.string.localStorage_pagetitleone');
  // Initializes the minimum font size.
  private minFontSize: number = 10;
  // Synchronize the night mode status with the home page and Page1.
  @LocalStorageLink('currentModelStatus') currentModelStatus: boolean = true;
  // Unidirectional synchronization of content font size with home page and Page1.
  @LocalStorageProp('contentFontSize') contentFontSize: number = 18;

  build() {
    Column() {
      if (this.currentModelStatus) {
        TitleBarDark({ title: $title })
      } else {
        TitleBar({ title: $title })
      }
      CodeView({ title: $title, isShowTitle: false }) {
        Column({ space: 20 }) {
          // View source code.
          ViewCodeText({ webSrc: $rawfile('LocalStoragePropPage.ets.html') })
          Text($r('app.string.localStorage_both_data_binding'))
            .fontSize(this.contentFontSize)
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .width('100%')
            .textAlign(TextAlign.Center)
          Text($r('app.string.localStorage_single_data_binding'))
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
          .id('localStoragePropPage')
          .padding($r('app.float.page_padding'))
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.button_background_color'))
          .onClick(() => {
            // The variables that control the night mode status are updated.
            // The data variables associated with @StorageLink and @StorageProp are refreshed.
            this.currentModelStatus = !this.currentModelStatus;
          })

          Text($r('app.string.localStorage_nigntmode_both_binding'))
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
                min: 10, // Minimum font size.
                max: 30, // Maximum font size.
                style: SliderStyle.OutSet
              })
                .showTips(true)
                .onChange((value: number, mode: SliderChangeMode) => {
                  // The variable data controlling the font size was updated.
                  // The data variable associated with @LocalStorageLink was not updated.
                  this.contentFontSize = value;
                })
              // toFixed(0) treats the slider return value to integer precision.
              Text(this.contentFontSize.toFixed(0))
                .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
                .fontSize($r('app.float.tips_font_size'))
            }
            .width('80%')
          }.margin({ top: 50 })

          Text($r('app.string.localStorage_single_fontsize_binding'))
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