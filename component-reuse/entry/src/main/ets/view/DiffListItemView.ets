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

import { ItemData } from '../model/ItemData';

// [Start node4]
// export the list item component
@Builder
export function listItemBuilder(data: ESObject) {
  DiffListItemView({
    item: data.item
  })
}

// The list item view component
@Component
export struct DiffListItemView {
  // [StartExclude node4]
  @Prop item: ItemData;
  // [EndExclude node4]

  aboutToReuse(params: ESObject): void {
    this.item = params.item;
  }

  build() {
    Row() {
      // [StartExclude node4]
      Column() {
        Text(this.item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .maxLines(2)
          .lineHeight(22)
          .opacity(0.9)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.tail)
          .fontSize(12)
          .opacity(0.4)
          .fontWeight(FontWeight.Regular)
          .margin({ top: 18 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image(this.item.pics[1])
        .width(96)
        .height(78)
        .borderRadius(8)
        .margin({ left: 12 })
      // [EndExclude node4]
    }
    // [StartExclude node4]
    .alignItems(VerticalAlign.Top)
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({ top: 12, left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor(Color.White)
    // [EndExclude node4]
  }
}
// [End node4]