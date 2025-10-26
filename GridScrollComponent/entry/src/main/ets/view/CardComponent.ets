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

import { PartReuse } from "@hadss/scroll_components";
import { CommonConstants } from "../common/constants/CommonConstants";
import UserInfoViewModel from "../viewModel/UserInfoViewModel";
import { CardCellData } from "./CardGridComponent";
import { buildManagerCard } from "./ManagerCardComponent";
import { buildUserCard } from "./UserCardComponent";

// [Start combine_item]
// [Start long_press_delete]
// item component
@Component
export default struct CardComponent {
  @State user: UserInfoViewModel = new UserInfoViewModel();

  // [StartExclude long_press_delete]
  aboutToReuse(params: Record<string, ESObject>) {
    let input = params as CardCellData;
    this.user = input.user;
  }

  // [EndExclude long_press_delete]
  // [StartExclude combine_item]
  @Builder
  optMenu() {
    Row() {
      Button() {
        // [StartExclude long_press_delete]
        Text() {
          SymbolSpan($r('sys.symbol.trash'))
        }
        .fontSize(35)
        // [EndExclude long_press_delete]
      }
      .backgroundColor(Color.Red)
      .onClick(() => {
        this.getUIContext().getHostContext()?.eventHub.emit(CommonConstants.EVENT_REMOVE_ITEM, this.user.id);
      })
    }
    // [StartExclude long_press_delete]
    .width(80)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
    // [EndExclude long_press_delete]
  }

  // [EndExclude combine_item]
  build() {
    Column() {
      // [StartExclude long_press_delete]
      if (this.user.role === 'manager') {
        // when need to reuse a subcomponent, use PartReuse to encapsulate it.
        PartReuse({
          type: 'manager',
          builder: wrapBuilder(buildManagerCard),
          data: {
            user: this.user
          }
        })
      } else {
        PartReuse({
          type: 'user',
          builder: wrapBuilder(buildUserCard),
          data: {
            user: this.user
          }
        })
      }
      // [EndExclude long_press_delete]
    }
    .bindContextMenu(this.optMenu(), ResponseType.LongPress)
    // [StartExclude long_press_delete]
    .width('90%')
    .height(80)
    // [EndExclude long_press_delete]
  }
}
// [End long_press_delete]

@Builder
export function buildCard(data: CardCellData) {
  CardComponent({ user: data.user })
}
// [End combine_item]