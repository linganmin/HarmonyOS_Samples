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

import UserInfoViewModel from "../viewModel/UserInfoViewModel"
import { CardCellData } from "./CardGridComponent";

// [Start combine_item]
// child component in item
@Component
export default struct UserCardComponent {
  @State user: UserInfoViewModel = new UserInfoViewModel();

  aboutToReuse(params: Record<string, ESObject>) {
    let input = params as CardCellData;
    this.user = input.user;
  }

  build() {
    // [StartExclude combine_item]
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Row({ space: 5 }) {
          Image(this.user.iconPixelMap)
            .alt($r('sys.media.ohos_user_auth_icon_face'))
            .sourceSize({
              width: 40,
              height: 40
            })
            .width(40)
            .height(40)
            .borderRadius(20)

          Column({ space: 8 }) {
            Text(this.user.updateTime)
              .fontSize(10)

            Row({ space: 10 }) {
              Text(this.user.name)
                .fontSize(10)
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .margin({
          top: 5
        })
      }

      Row({ space: 5 }) {
        ForEach(this.user.abilities, (item: string) => {
          if (item === 'add') {
            Image($r('sys.media.ohos_ic_public_add'))
              .width(20)
              .height(20)
          } else if (item === 'update') {
            Image($r('sys.media.ohos_ic_public_edit'))
              .width(20)
              .height(20)
          } else if (item === 'delete') {
            Image($r('sys.media.ohos_ic_public_remove'))
              .width(20)
              .height(20)
          } else if (item === 'scan') {
            Image($r('sys.media.ohos_ic_public_scan'))
              .width(20)
              .height(20)
          }
        }, (item: string) => item)
      }
      .margin({
        top: 10,
        bottom: 5
      })
    }
    .width("100%")
    .alignItems(HorizontalAlign.Start)
    // [EndExclude combine_item]
  }
}

@Builder
export function buildUserCard(params: CardCellData) {
  UserCardComponent({ user: params.user })
}
// [End combine_item]