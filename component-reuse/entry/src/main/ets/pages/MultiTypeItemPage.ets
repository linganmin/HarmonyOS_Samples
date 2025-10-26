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
import { genMockItemData } from '../common/MockData';
import { ItemDataSource } from '../model/ItemDataSource';

// [Start MultiType]
@Component
export struct MultiTypeItemPage {
  // [StartExclude MultiType]
  private dataSource: ItemDataSource = new ItemDataSource();

  aboutToAppear(): void {
    this.dataSource.pushArray(genMockItemData(1000));
  }
  // [EndExclude MultiType]

  build() {
    NavDestination() {
      Column() {
        List() {
          LazyForEach(this.dataSource, (item: ItemData) => {
            if (item.type === 0) {
              TextTypeItemView({ item: item })
                .reuseId('text_item_id')
            } else if (item.type === 1) {
              ImageTypeItemView({ item: item })
                .reuseId('image_item_id')
            } else if (item.type === 2) {
              ThreeImageTypeItemView({ item: item })
                .reuseId('three_image_item_id')
            }
          }, (item: ItemData) => item.id.toString())
        }
        // [StartExclude MultiType]
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .cachedCount(1)
        .width('100%')
        .height('100%')
        // [EndExclude MultiType]
      }
      // [StartExclude MultiType]
      .width('100%')
      .height('100%')
      // [EndExclude MultiType]
    }
    // [StartExclude MultiType]
    .backgroundColor(0xF1F3F5)
    .title($r('app.string.index_same_list_multi_type'))
    // [EndExclude MultiType]
  }
}

@Reusable
@Component
struct TextTypeItemView {
  // [StartExclude MultiType]
  @ObjectLink item: ItemData;

  build() {
    Column() {
      Text(this.item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .maxLines(3)
        .lineHeight(22)
        .opacity(0.9)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Row() {
        Text(this.item.from)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor(0x0A59F7)
        Text(this.item.tail)
          .fontSize(12)
          .opacity(0.4)
          .fontWeight(FontWeight.Regular)
          .margin({ left: 6 })
          .width('100%')
      }
      .margin({ top: 12 })
    }
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({ top: 12, left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }
  // [EndExclude MultiType]
}


@Reusable
@Component
struct ImageTypeItemView {
  // [StartExclude MultiType]
  @ObjectLink item: ItemData;

  build() {
    Row() {
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

      Image(this.item.preview)
        .width(96)
        .height(78)
        .borderRadius(8)
        .margin({ left: 12 })
    }
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
  }
  // [EndExclude MultiType]
}

@Reusable
@Component
struct ThreeImageTypeItemView {
  // [StartExclude MultiType]
  @ObjectLink item: ItemData;

  build() {
    Column() {
      Text(this.item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .maxLines(2)
        .lineHeight(22)
        .opacity(0.9)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Row() {
        Image(this.item.pics[0])
          .layoutWeight(1)
          .height(98)
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
        Divider().width(2)
        Image(this.item.pics[1])
          .layoutWeight(1)
          .height(98)
        Divider().width(2)
        Image(this.item.pics[2])
          .layoutWeight(1)
          .height(98)
          .borderRadius({ topRight: 8, bottomRight: 8 })
      }
      .margin({ top: 8 })

      Text(this.item.tail)
        .fontSize(12)
        .opacity(0.4)
        .fontWeight(FontWeight.Regular)
        .margin({ top: 18 })
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({ top: 12, left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }
  // [EndExclude MultiType]
}
// [End MultiType]

