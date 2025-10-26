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

import { SideBarAnimationViewConstants } from '../constants/SideBarAnimationViewConstants';
import { CommonLazySource } from '../model/CommonLazySource';

@Component
export struct SideBarView {
  memberArray: CommonLazySource<string> = new CommonLazySource();

  aboutToAppear(): void {
    for (let i = 0; i < SideBarAnimationViewConstants.MEMBER_COUNT; i++) {
      this.memberArray.pushData(SideBarAnimationViewConstants.MEMBER + i);
    }
  }

  @Builder
  buildList() {
    List() {
      LazyForEach(this.memberArray, (_dateItem: string) => {
        ListItem() {
          Row() {
            Image(null)
              .backgroundColor($r('app.color.help_color'))
              .width(SideBarAnimationViewConstants.SIDEBAR_MEMBER_LIST_HEAD_ICON_SIZE)
              .height(SideBarAnimationViewConstants.SIDEBAR_MEMBER_LIST_HEAD_ICON_SIZE)
              .borderRadius(SideBarAnimationViewConstants.SIDEBAR_MEMBER_LIST_HEAD_ICON_RADIUS)
            Row()
              .margin($r('sys.float.ohos_id_card_margin_start'))
              .height(SideBarAnimationViewConstants.SIDEBAR_MEMBER_LIST_NAME_HEIGHT)
              .width($r('app.string.full_size'))
              .backgroundColor($r('app.color.help_color'))
          }
        }
      })
    }
    .padding($r('sys.float.ohos_id_card_margin_start'))
  }

  build() {
    Column() {
      Divider()
        .padding($r('sys.float.ohos_id_card_margin_start'))
      this.buildList()
    }
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }
}