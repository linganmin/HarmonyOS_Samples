/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { customTitle, getString } from '@ohos/common';
import { MenuList } from '@ohos/menuitems';
import { AsonFunction } from '../components/arkTSUtilcomponents/AsonFunction';

@Builder
export function ArkTSUtilBuilder() {
  ArkTSUtil()
}

@Component
export struct ArkTSUtil {
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        MenuList({ menuList: $r('app.strarray.arkTs_util_menu'), secondLabel: true })
      }
      .margin({ left: -12, right: -12 })
    }
    .title(customTitle(this.selectedLabel))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}