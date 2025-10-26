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
export default struct ApplyGlobalDataSyncCode {
  // And Ability1, Ability2 page bidirectional synchronization content font size.
  @StorageLink('contentFontSize') contentFontSize: number = 18;
  // Synchronize night mode status with Ability1 and Ability2 in both directions.
  @StorageLink('currentModelStatus') currentModelStatus: boolean = true;
  // Initializes the minimum font size.
  private minFontSize: number = 10;

  build() {
    Column({ space: 10 }) {
      // View source code.
      ViewCodeText({ webSrc: $rawfile('ApplyGlobalDataSyncCode.ets.html') })
      Row() {
        Text($r('app.string.nightmode'))
          .fontSize(this.contentFontSize)
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
        // Develop control night mode.
        Toggle({ type: ToggleType.Switch, isOn: this.currentModelStatus })
          .id('applyGlobalDataSyncCode')
          .selectedColor(Color.Blue)
          .switchPointColor(Color.White)
          .onChange((isOn: boolean) => {
            // The variable data that controls the night mode status is updated.
            // The data variables associated with @StorageLink and @StorageLink are updated.
            this.currentModelStatus = isOn;
            AppStorage.setOrCreate<boolean>('currentModelStatus', this.currentModelStatus);
          })
      }.justifyContent(FlexAlign.SpaceAround)
      .width('70%')
      .border({ radius: 50, color: Color.Grey, width: $r('app.float.border_width') })

      Text($r('app.string.nightmode_text'))
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
            min: this.minFontSize, // Minimum font size.
            max: 30, // Maximum font size.
            style: SliderStyle.OutSet
          })
            .showTips(true)
            .onChange((value: number, mode: SliderChangeMode) => {
              // Updated variable data that controls font size status.
              // Data variables associated with @StorageLink and @StorageProp were refreshed.
              this.contentFontSize = value;
              AppStorage.setOrCreate<number>('contentFontSize', this.contentFontSize);
            })
          // toFixed(0) treats the slider return value to integer precision.
          Text(this.contentFontSize.toFixed(0))
            .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
            .fontSize($r('app.float.tips_font_size'))
        }
        .width('80%')
      }.margin({ top: 50 })

      Text($r('app.string.fontSize_singlesync_textone'))
        .fontSize(this.contentFontSize)
        .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.tips_font_color'))
        .width('100%')
        .textAlign(TextAlign.Center)
      Button() {
        Text($r('app.string.enter_abilityone'))
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
          .fontSize(this.contentFontSize)
          .width('60%')
          .textAlign(TextAlign.Center)
      }
      .id('enterAbilityOne')
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.button_background_color'))
      .padding($r('app.float.page_padding'))
      .onClick(() => {
        startSpecifiedAbility(this.getUIContext().getHostContext() as common.UIAbilityContext, 'StoragePropAbility');
      })

      Button() {
        Text($r('app.string.enter_abilitytwo'))
          .fontColor(this.currentModelStatus ? $r('app.color.color_white') : $r('app.color.button_text_color'))
          .fontSize(this.contentFontSize)
          .width('60%')
          .textAlign(TextAlign.Center)
      }
      .id('enterAbilityTwo')
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.button_background_color'))
      .padding($r('app.float.page_padding'))
      .onClick(() => {
        startSpecifiedAbility(this.getUIContext().getHostContext() as common.UIAbilityContext, 'StorageLinkAbility');
      })
    }.padding($r('app.float.page_padding'))
  }
}