/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from 'common';

@Component
export struct MineMenuComponent {
  build() {
    List() {
      ForEach(Const.DEFAULT_MENU_INFO, (item: Resource) => {
        ListItem() {
          Flex({
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Center
          }) {
            Text(item)
              .fontSize($r('app.float.default_16'))
              .height($r('app.float.default_40'))

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_secondary')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_24'))
          }
        }
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          left: $r('app.float.default_24'),
          right: $r('app.float.default_24')
        })
        .height($r('app.float.default_48'))
        .border({
          width: {
            bottom: $r('app.float.default_1')
          },
          color: $r('sys.color.background_tertiary')
        })
      }, (item: Resource, index: number) => index + JSON.stringify(item));
    }
    .border({
      radius: {
        topLeft: $r('app.float.default_24'),
        topRight: $r('app.float.default_24')
      }
    })
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_560)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({
      top: $r('app.float.default_24')
    })
    .padding({
      top: $r('app.float.default_16')
    })
    .flexGrow(Const.FLEX_GROW_1)
    .clip(true)
  }
}