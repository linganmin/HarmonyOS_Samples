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

import { LengthMetrics } from '@kit.ArkUI';
import { FontType } from '../common/CommonData';
import PreferenceUtils, { fp2pxUtil, registerMyFont } from '../common/CommonUtils';

@Component
export struct SettingsPage {
  // [Start Get_fontOffset]
  @StorageLink('fontOffset') fontOffset: string = '';
  // [StartExclude Get_fontOffset]
  @StorageLink('toggleState') toggleState: boolean = false;
  @StorageLink('fontSizeOffset') fontSizeOffset: number = 0;
  @StorageLink('fontWeightOffset') fontWeightOffset: number = 400;
  private menuItemArr: ResourceStr[] = ['', 'HarmonyOS Italic', 'HarmonyOS Condensed'];
  private envFont: FontType | undefined = { fontSizeScale: 0, fontWeightScale: 0 };
  // [EndExclude Get_fontOffset]

  aboutToAppear() {
    // [StartExclude Get_fontOffset]
    // Get system environment change information from AppStorage
    this.envFont = AppStorage.get('envFont');
    // [EndExclude Get_fontOffset]
    // Get font data from preferences
    this.fontOffset = PreferenceUtils.getFont();
    // Register font
    registerMyFont(this.getUIContext());
  }
  // [Start Get_fontOffset]

  @Builder
  textMenu() {
    // [Start Default_Font]
    Menu() {
      ForEach(this.menuItemArr, (item: string) => {
        // [Start Save_Custom_Font]
        MenuItem({
          content: item === '' ? $r('app.string.system_default') : item,
          endIcon: this.fontOffset === item ? $r('app.media.checkmark') : ''
        })
          .onChange(() => {
            this.fontOffset = item;
            PreferenceUtils.saveModifyFont(item);
          })
        // [End Save_Custom_Font]
      }, (item: string) => item)
    }
    // [StartExclude Default_Font]
    .font({ size: this.toggleState ? 16 : fp2pxUtil(16) })
    .menuItemDivider({
      strokeWidth: LengthMetrics.vp(1),
      color: '#c7c7c7',
    })
    // [EndExclude Default_Font]
    // [Start Default_Font]
  }

  build() {
    Column() {
      // [Start fp2px_Util]
      Text($r('app.string.setting'))
        .width('100%')
        .fontWeight(700)
        .fontSize(this.toggleState ? 26 : fp2pxUtil(26))
      // [End fp2px_Util]
      // [Start Use_Register_Font]
      // Example Text Content
      Column() {
        // [Start Preview_Default_Font]
        Text($r('app.string.preview_text'))
          // [StartExclude Use_Register_Font]
          // [StartExclude Preview_Default_Font]
          .fontSize(this.toggleState ? 16 : fp2pxUtil(16 + this.fontSizeOffset))
          .fontWeight(this.toggleState ? this.envFont?.fontWeightScale : this.fontWeightOffset)
          // [StartExclude Use_Register_Font]
          // [EndExclude Preview_Default_Font]
          .fontFamily(this.fontOffset)
        // [Start Preview_Default_Font]
      }
      .width('100%')
      .padding(12)
      .margin({ top: 35 })
      .backgroundColor('#FFF')
      .borderRadius(16)

      // [End Use_Register_Font]

      // Font Style
      Column() {
        Text($r('app.string.font_style'))
          .padding({ left: 12 })
          .fontColor('#606162')
          .font({ size: this.toggleState ? 14 : fp2pxUtil(14), weight: 500 })
        Column({ space: 12 }) {
          // Follow the system
          Row() {
            Text($r('app.string.follow_system'))
              .fontSize(this.toggleState ? 16 : fp2pxUtil(16))
            // [Start Toggle_State]
            Toggle({ type: ToggleType.Switch, isOn: this.toggleState })
              .onChange((isOn: boolean) => {
                this.toggleState = isOn;
              })
            // [End Toggle_State]
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          // Font size
          Column() {
            Row() {
              Text($r('app.string.font_size'))
                .fontSize(this.toggleState ? 16 : fp2pxUtil(16))
              Text(
                this.fontSizeOffset < 0 ? $r('app.string.small') :
                  this.fontSizeOffset === 0 ? $r('app.string.normal') :
                    this.fontSizeOffset < 4 ? $r('app.string.large') : $r('app.string.huge')
              )
                .fontColor('#FF646464')
                .fontSize(this.toggleState ? 14 : fp2pxUtil(14))
            }
            .width('100%')
            .padding({ right: 8 })
            .justifyContent(FlexAlign.SpaceBetween)

            // Adjusting font size
            Row() {
              Text($r('app.string.text_a'))
                .font({ size: this.toggleState ? 14 : fp2pxUtil(14) })
                .fontColor('#666')
              // [Start Write_FontSize_Data]
              Slider({
                min: -4,
                max: 4,
                value: this.fontSizeOffset,
                style: SliderStyle.InSet
              })
                .width('90%')
                .margin({ top: 12 })
                .enabled(!this.toggleState)
                // [Start Write_FontSize_Data]
                .onChange((data: number) => {
                  this.fontSizeOffset = data;
                  PreferenceUtils.saveModifyFontSize(data);
                })
              Text($r('app.string.text_a'))
                .font({ size: this.toggleState ? 16 : fp2pxUtil(16) })
                .fontColor('#666')
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .border({
            width: {
              top: 1,
              bottom: 1
            }
          })
          .borderColor('#CCC')
          .padding({ top: 12, bottom: 12 })

          // Font weight
          Column() {
            Row() {
              Text($r('app.string.font_weight'))
                .fontSize(this.toggleState ? 16 : fp2pxUtil(16))
              Text(
                this.fontWeightOffset < 400 ? $r('app.string.light') :
                  this.fontWeightOffset === 400 ? $r('app.string.normal') :
                    this.fontWeightOffset < 900 ? $r('app.string.bold') : $r('app.string.boldest')
              )
                .fontColor('#FF646464')
                .fontSize(this.toggleState ? 14 : fp2pxUtil(14))
            }
            .width('100%')
            .padding({ right: 8 })
            .justifyContent(FlexAlign.SpaceBetween)

            // Adjust font thickness
            Slider({
              min: 100,
              max: 900,
              step: 100,
              value: this.fontWeightOffset,
              style: SliderStyle.InSet
            })
              .width('100%')
              .stepSize(5)
              .showSteps(true)
              .margin({ top: 12 })
              .enabled(!this.toggleState)
              .onChange((data: number) => {
                this.fontWeightOffset = data;
                PreferenceUtils.saveModifyFontWeight(data);
              })
          }
          .width('100%')

        }
        .width('100%')
        .padding(12)
        .margin({ top: 8 })
        .borderRadius(16)
        .backgroundColor('#FFF')
      }
      .margin({ top: 28 })
      .alignItems(HorizontalAlign.Start)

      // Font
      Column() {
        Text($r('app.string.Font_settings'))
          .padding({ left: 12 })
          .fontColor('#606162')
          .font({ size: this.toggleState ? 14 : fp2pxUtil(14), weight: 500 })
        Row() {
          Text($r('app.string.font'))
            .fontSize(this.toggleState ? 16 : fp2pxUtil(16))
          Row() {
            Text(this.fontOffset === '' ? $r('app.string.system_default') : this.fontOffset)
              .fontSize(this.toggleState ? 14 : fp2pxUtil(14))
              .fontColor('#FF646464')
              .margin({ right: 8 })
            Image($r('app.media.arrow_down'))
              .width(8)
              .height(6)
          }
          .height(32)
          .bindMenu(this.textMenu())
        }
        .width('100%')
        .height(56)
        .padding(12)
        .margin({ top: 8 })
        .borderRadius(16)
        .backgroundColor('#FFF')
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .margin({ top: 28 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 18, left: 16, right: 16 })
  }
}