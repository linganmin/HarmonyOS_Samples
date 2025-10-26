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

import { HdsActionBar, ActionBarButton, ActionBarStyle } from '@kit.UIDesignKit';
import { deviceInfo } from '@kit.BasicServicesKit';

@Component
export struct ActionBarAdapter {
  @State isExpand: boolean = true;
  @State isPrimaryIconChanged: boolean = false;
  // [Start action_bar_api]
  build() {
    Column() {
      // Regarding the proprietary interfaces of HarmonyOS, specifically the interfaces marked as since M.F.S(N).
      // Compatibility judgment, the value corresponding to version 6.0.0(20) is 60000,
      // which is derived from the new interface's since field 6*10000 + 0*100 + 0.
      if (deviceInfo.distributionOSApiVersion >= 60000) {
        // Component that calls the API of version 6.0.0(20)
        HdsActionBar({
          startButtons: [new ActionBarButton({
            baseIcon: $r('sys.symbol.stopwatch_fill')
          })],
          endButtons: [new ActionBarButton({
            baseIcon: $r('sys.symbol.mic_fill')
          })],
          // [StartExclude action_bar_api]
          primaryButton: new ActionBarButton({
            baseIcon: $r('sys.symbol.plus'),
            altIcon: $r('sys.symbol.play_fill'),
            onClick: () => {
              this.isExpand = !this.isExpand;
              this.isPrimaryIconChanged = !this.isPrimaryIconChanged;
            }
          }),
          actionBarStyle: new ActionBarStyle({
            isPrimaryIconChanged: this.isPrimaryIconChanged
          }),
          isExpand: this.isExpand!!
          // [EndExclude action_bar_api]
        })
      } else {
        // Downgrading plan
        Row({ space: 25 }) {
          // [StartExclude action_bar_api]
          if (this.isExpand) {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.stopwatch_fill'))
                .fontSize(24)
                .fontColor([$r('sys.color.font_secondary')])
            }
            .aspectRatio(1)
            .height(45)
            .backgroundColor($r('sys.color.background_secondary'))
            .margin({ left: 10 })
          }

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph(this.isExpand ? $r('sys.symbol.plus') : $r('sys.symbol.play_fill'))
              .fontSize(24)
              .fontColor([$r('sys.color.white')])
          }
          .aspectRatio(1)
          .height(55)
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.isExpand = !this.isExpand;
          })

          if (this.isExpand) {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.mic_fill'))
                .fontSize(24)
                .fontColor([$r('sys.color.font_secondary')])
            }
            .aspectRatio(1)
            .height(45)
            .backgroundColor($r('sys.color.background_secondary'))
            .margin({ right: 10 })
          }
          // [EndExclude action_bar_api]
        }
        // [StartExclude action_bar_api]
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(30)
        // [EndExclude action_bar_api]
      }
    }
    // [StartExclude action_bar_api]
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    // [EndExclude action_bar_api]
  }
  // [End action_bar_api]
}