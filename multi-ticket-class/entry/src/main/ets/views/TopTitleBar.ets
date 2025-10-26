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

import { Want } from '@kit.AbilityKit';
import { TextModifier } from '@kit.ArkUI';
import { UniversalIcon, WordBackgroundComm } from './CommonView';
import { BreakpointType } from '../utils/BreakpointType';
import { MultiWindowEntryComponent } from './MultiWindowEntryComponent';

@Component
export struct TopTitleBar {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @StorageLink('lastWidthBreakpoint') lastWidthBreakpoint: number = 1;
  @StorageLink('isSplitScreen') isSplitScreen: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('tabletMode') tabletMode: NavigationMode;
  @State textModifier: TextModifier = new TextModifier();
  @State splitScreenWant: Want = {
    // Modify the bundleName, moduleName and abilityName of the current application, and launch the UIAbility within the application.
    bundleName: 'com.example.multiticketclass',
    moduleName: 'entry',
    abilityName: 'EntryAbility',
  };

  build() {
    // [Start top_title_bar_area]
    Row() {
      // The icon area on the left
      Row() {
        if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG && this.tabletMode === NavigationMode.Split) {
          UniversalIcon({
            icon: $r('sys.symbol.arrow_up_left_and_arrow_down_right'),
            iconBackgroundColor: $r('sys.color.comp_background_tertiary')
          })
          // [StartExclude top_title_bar_area]
            .onClick(() => {
              this.tabletMode = NavigationMode.Stack;
            })
          // [EndExclude top_title_bar_area]
        } else {
          UniversalIcon({
            icon: $r('sys.symbol.chevron_left'),
            iconBackgroundColor: $r('sys.color.comp_background_tertiary')
          })
          // [StartExclude top_title_bar_area]
            .onClick(() => {
              if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG) {
                this.tabletMode = NavigationMode.Split;
              } else {
                this.pageInfos.pop();
              }
            })
          // [EndExclude top_title_bar_area]
        }
      }

      Blank()

      // The central title area at the top
      Column() {
        // [StartExclude top_title_bar_area]
        Text($r('app.string.some_company_technology'))
          .fontSize(16)
          .height(21)
        Row() {
          WordBackgroundComm({
            text: $r('app.string.deep'),
            textFontColor: '#1E6CF3',
            textBackgroundColor: '#E8F0FE'
          })
          Text($r('app.string.closed_day'))
            .fontSize(11)
            .height(15)
            .fontColor('#999999')
        }

        // [EndExclude top_title_bar_area]
      }
      .height(40)

      Blank()

      // The area displayed by the icon on the right side
      Row({ space: 16 }) {
        // split screen
        Row() {
          MultiWindowEntryComponent({
            textModifier: this.textModifier,
            want: this.splitScreenWant
          })
        }
      }
    }
    // [End top_title_bar_area]
    .width('100%')
    .height(new BreakpointType(56, 62, 62).getValue(this.currentWidthBreakpoint))
    .backgroundColor(Color.White)
    .padding({
      right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
      left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
    })
  }
}