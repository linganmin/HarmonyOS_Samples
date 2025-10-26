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

import Constants from '../common/Constants';

@Component
export default struct Header {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State backIconBgColor: ResourceColor = $r('sys.color.comp_background_tertiary');
  @Prop headerTitle: Resource;

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize($r('sys.float.Title_M'))
      }
      .height($r('app.float.back_button_height'))
      .aspectRatio(1)
      .margin({ right: $r('sys.float.padding_level4') })
      .backgroundColor(this.backIconBgColor)
      .onClick(() => this.pathInfos.pop())
      .onHover((isHover: boolean) => {
        this.backIconBgColor = isHover ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
      })

      Text(this.headerTitle)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constants.FULL_WIDTH)
    .height($r('app.float.header_height'))
    .backgroundColor(Color.Transparent)
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
  }
}