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
import { startSpecifiedAbility } from '../utils/StartAbilityUtils';

@Component
export struct TitleBarDark {
  @Link title: Resource;
  isAbility: boolean = false;

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('app.media.ic_back_white'))
            .size({ width: $r('app.float.icon_back_size'), height: $r('app.float.icon_back_size') })
        }
        .id('titleBarDark')
        .onClick(() => {
          this.isAbility ?
          startSpecifiedAbility(this.getUIContext().getHostContext() as common.UIAbilityContext, 'EntryAbility') :
          this.getUIContext().getRouter().back();
        })
        .backgroundColor($r('app.color.nightnode_color'))

        Text(this.title)
          .fontSize($r('app.float.title_font_size'))
          .margin({ left: $r('app.float.title_margin') })
          .fontColor(Color.White)
      }
      .width('100%')
      .padding($r('app.float.page_padding'))

      Divider()
        .width('100%')
        .height($r('app.float.divider_height'))
        .color($r('app.color.divider_color'))
        .margin({ bottom: 12 })
    }
    .width('100%')
  }
}