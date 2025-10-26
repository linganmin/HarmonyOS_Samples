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

import { genMockItemData } from '../common/MockData';
import { ItemData } from '../model/ItemData';
import { ItemDataSource } from '../model/ItemDataSource';

// [Start Composable]
@Component
export struct ComposableItemPage {
  // [StartExclude Composable]
  private dataSource: ItemDataSource = new ItemDataSource();

  aboutToAppear(): void {
    this.dataSource.pushArray(genMockItemData(1000));
  }
  // [EndExclude Composable]

  @Builder
  itemBuilderSingleImage(item: ItemData) {
    TopView({ item: item }).reuseId('top_id')
    MiddleSingleImageView({ item: item }).reuseId('middle_image_id')
    BottomView({ item: item }).reuseId('bottom_id')
  }

  @Builder
  itemBuilderThreeImage(item: ItemData) {
    TopView({ item: item }).reuseId('top_id')
    MiddleThreeImageView({ item: item }).reuseId('middle_three_image_id')
    BottomView({ item: item }).reuseId('bottom_id')
  }

  @Builder
  itemBuilderVideoImage(item: ItemData) {
    TopView({ item: item }).reuseId('top_id')
    MiddleVideoView({ item: item }).reuseId('middle_video_id')
    BottomView({ item: item }).reuseId('bottom_id')
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          LazyForEach(this.dataSource, (item: ItemData) => {
            ListItem() {
              Column() {
                if (item.type === 0) {
                  this.itemBuilderSingleImage(item)
                } else if (item.type === 1) {
                  this.itemBuilderThreeImage(item)
                } else if (item.type === 2) {
                  this.itemBuilderVideoImage(item)
                }
              }
              // [StartExclude Composable]
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
              // [EndExclude Composable]
            }
          }, (item: ItemData) => item.id.toString())
        }
        // [StartExclude Composable]
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .cachedCount(1)
        .width('100%')
        .height('100%')
        // [EndExclude Composable]
      }
      // [StartExclude Composable]
      .width('100%')
      .height('100%')
      // [EndExclude Composable]
    }
    // [StartExclude Composable]
    .backgroundColor(0xF1F3F5)
    .title(($r('app.string.index_same_list_composable_type')))
    // [EndExclude Composable]
  }
}

@Reusable
@Component
struct TopView {
  // [StartExclude Composable]
  @ObjectLink item: ItemData;

  build() {
    Text(this.item.title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.Black)
      .maxLines(2)
      .lineHeight(22)
      .opacity(0.9)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
  }
  // [EndExclude Composable]
}

@Reusable
@Component
struct BottomView {
  // [StartExclude Composable]
  @ObjectLink item: ItemData;

  build() {
    Text(this.item.tail)
      .fontSize(12)
      .opacity(0.4)
      .fontWeight(FontWeight.Regular)
      .margin({ left: 6 })
      .width('100%')
      .margin({ top: 12 })
  }
  // [EndExclude Composable]
}

@Reusable
@Component
struct MiddleSingleImageView {
  // [StartExclude Composable]
  @ObjectLink item: ItemData;

  build() {
    Image(this.item.preview)
      .width(158)
      .height(96)
      .borderRadius(8)
      .margin({ top: 8 })
  }
  // [EndExclude Composable]
}

@Reusable
@Component
struct MiddleThreeImageView {
  // [StartExclude Composable]
  @ObjectLink item: ItemData;

  build() {
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
  }
  // [EndExclude Composable]
}

@Reusable
@Component
struct MiddleVideoView {
  // [StartExclude Composable]
  @ObjectLink item: ItemData;

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Image(this.item.preview)
        .width(112)
        .height(112)
        .borderRadius(8)
        .margin({ top: 8 })
      Row() {
        Image($r('app.media.play_fill'))
          .width(12).height(12)
        Text(this.item.duration)
          .fontColor(Color.White)
          .fontSize(11)
          .margin({ left: 2 })
          .fontWeight(FontWeight.Medium)
      }.margin(6)
    }
  }
  // [EndExclude Composable]
}
// [End Composable]