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

import { common } from '@kit.AbilityKit';
import { ViewCodeText } from '../../../commoncomponents/ViewCodeText';
import { startSpecifiedAbility } from '../../../utils/StartAbilityUtils';

@Component
export struct AbilityGlobalDataSyncCode {
  // Initializes the minimum font size.
  private minFontSize: number = 10;
  // Bidirectional synchronization of content font size with home page, Page1, Page2.
  @LocalStorageLink('contentFontSize') contentFontSize: number = 18;
  // Synchronize the night mode status with home page, page E1, and Page2
  @LocalStorageLink('currentModelStatus') currentModelStatus: boolean = true;

  build() {
    Column({ space: 10 }) {
      // View source code.
      ViewCodeText({ webSrc: $rawfile('AbilityGlobalDataSyncCode.ets.html') })
      Row() {
        Text($r('app.string.nightmode'))
          .fontSize(this.contentFontSize)
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
        // Control night mode.
        Toggle({ type: ToggleType.Switch, isOn: this.currentModelStatus })
          .id('abilityGlobalDataSyncCode')
          .selectedColor(Color.Blue)
          .switchPointColor(Color.White)
          .onChange((isOn: boolean) => {
            // The variable data that controls the night mode status is updated.
            // The data variables associated with @StorageLink and @StorageLink are updated.
            this.currentModelStatus = isOn;
          })
      }.justifyContent(FlexAlign.SpaceAround)
      .width('70%')
      .border({ radius: 50, color: Color.Grey, width: $r('app.float.border_width') })

      Text($r('app.string.ability_storage_nightmodelsync'))
        .fontSize(this.contentFontSize)
        .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
        .textAlign(TextAlign.Center)
      // slider slider module controls font size.
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
              // The variables that control the font size status are updated.
              // The data variables associated with @LocalStorageLink and @LocalStorageProp are updated.
              this.contentFontSize = value;
            })
          // toFixed(0) treats the slider return value to integer precision.
          Text(this.contentFontSize.toFixed(0))
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .fontSize($r('app.float.tips_font_size'))
        }
        .width('80%')
      }.margin({ top: 50 })

      Text($r('app.string.ability_storage_fontsizesync'))
        .fontSize(this.contentFontSize)
        .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
        .width('100%')
        .textAlign(TextAlign.Center)
      Button() {
        Text($r('app.string.enter_pageone'))
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
          .fontSize(this.contentFontSize)
          .width('60%')
          .textAlign(TextAlign.Center)
      }
      .id('enterPageOne')
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.button_background_color'))
      .padding($r('app.float.page_padding'))
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/applylevelstagemanagement/abilityglobaldatasync/LocalStoragePropPage' });
      })

      Button() {
        Text($r('app.string.enter_pagetwo'))
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
          .fontSize(this.contentFontSize)
          .width('60%')
          .textAlign(TextAlign.Center)
      }
      .id('enterPageTwo')
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.button_background_color'))
      .padding($r('app.float.page_padding'))
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/applylevelstagemanagement/abilityglobaldatasync/LocalStorageLinkPage' });
      })

      Divider().width('100%').strokeWidth(1)
      Button() {
        Text($r('app.string.enter_ability_outofsync'))
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
          .fontSize(this.contentFontSize)
          .width('60%')
          .textAlign(TextAlign.Center)
      }
      .id('enterOutOfAbility')
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.button_background_color'))
      .padding($r('app.float.page_padding'))
      .onClick(() => {
        startSpecifiedAbility(this.getUIContext().getHostContext() as common.UIAbilityContext, 'OutOfSyncAbility');
      })
    }
    .width('100%')
    .padding(10)
  }
}