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

@Component
export struct CardItem {
  textContent?: Resource;
  onCardItemClick: Function = () => {
  };

  build() {
    Row() {
      Text(this.textContent)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('sys.float.padding_level4') })
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor([$r('sys.color.icon_fourth')])
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      this.onCardItemClick();
    })
  }
}