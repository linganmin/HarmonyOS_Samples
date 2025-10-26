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

import { Constants } from '../common/Constants';
import { startMode } from '../common/Utils';

@Component
export struct SplitScreen {
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    Column() {
      Row() {
        Text($r('app.string.splice_screen_drag'))
          .fontColor($r('sys.color.font_primary'))
          .width(Constants.FULL_WIDTH)
          .height(Constants.FULL_HEIGHT)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Subtitle_M'))
          .textAlign(TextAlign.Start)
        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor([$r('sys.color.icon_tertiary')])
      }
      .padding({ right: $r('sys.float.padding_level6') })
      .justifyContent(FlexAlign.SpaceBetween)
      .borderColor($r('sys.color.comp_divider'))
      .width(Constants.FULL_WIDTH)
      .height(48)
    }
    .borderRadius(16)
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      let context = this.getUIContext().getHostContext();
      startMode({ 'modeName': 'SingletonAbility' }, 'SingletonAbility', context)
    })
  }
}