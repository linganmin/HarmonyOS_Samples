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

import { Constants } from '../../common/Constants';
import { getStringSync } from '../../utils/StringUtil';
import { UserButton } from '../../view/UserButton';

@Builder
export function  PageTextAndImageIndexBuilder() {
  TextAndImageIndex();
}

@Entry
@Component
struct TextAndImageIndex {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;

  build() {
    NavDestination() {
      Column() {
        List() {
          ListItem() {
            UserButton({ name: 'Text' })
          }
          ListItem() {
            UserButton({ name: 'RichEditor' })
          }
          ListItem() {
            UserButton({ name: 'MultiEntry' })
          }
        }
        .width('auto')
        .height('auto')
        .divider({
          strokeWidth: Constants.BORDER_WIDTH,
          color: $r('sys.color.comp_divider'),
          startMargin: $r('sys.float.padding_level6'),
          endMargin: $r('sys.float.padding_level6'),
        })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .clip(true)
      .padding({
        top: $r('sys.float.padding_level2'),
        bottom: $r('sys.float.padding_level2')
      })
      .margin({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius($r('sys.float.padding_level8'))
    }
    .title(getStringSync(this.getUIContext().getHostContext()!, $r('app.string.text_and_image_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}