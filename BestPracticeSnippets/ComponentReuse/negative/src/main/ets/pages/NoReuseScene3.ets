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

import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';
import { genMockItemData } from '../common/MockData';

@Builder
function buildNoReuseScene3() {
  NoReuseScene3()
}

// 未使用组件复用：场景3
@Component
struct NoReuseScene3 {
  private dataSource: ItemDataSource = new ItemDataSource();

  aboutToAppear(): void {
    this.dataSource.pushArray(genMockItemData(1000));
  }

  @Builder
  itemBuilderSingleImage(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleSingleImageView({ item: item })
      BottomView({ item: item })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({
      top: 12,
      left: 16,
      right: 16
    })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }

  @Builder
  itemBuilderThreeImage(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleThreeImageView({ item: item })
      BottomView({ item: item })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({
      top: 12,
      left: 16,
      right: 16
    })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }

  @Builder
  itemBuilderVideo(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleVideoView({ item: item })
      BottomView({ item: item })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 16,
      bottom: 12,
      left: 16,
      right: 16
    })
    .margin({
      top: 12,
      left: 16,
      right: 16
    })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          LazyForEach(this.dataSource, (item: ItemData) => {
            ListItem() {
              if (item.type === 0) {
                this.itemBuilderSingleImage(item)
              } else if (item.type === 1) {
                this.itemBuilderThreeImage(item)
              } else {
                this.itemBuilderVideo(item)
              }
            }
          }, (item: ItemData) => item.id.toString())
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .cachedCount(1)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
  }
}


@Component
struct TopView {
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
}

@Component
struct BottomView {
  @ObjectLink item: ItemData;

  build() {
    Text(this.item.tail)
      .fontSize(12)
      .opacity(0.4)
      .fontWeight(FontWeight.Regular)
      .margin({ left: 6, top: 12 })
      .width('100%')
  }
}

@Component
struct MiddleSingleImageView {
  @ObjectLink item: ItemData;

  build() {
    Image(this.item.preview)
      .width(158)
      .height(96)
      .borderRadius(8)
      .margin({ top: 8 })
  }
}

@Component
struct MiddleThreeImageView {
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
        .borderRadius({ topLeft: 8, bottomLeft: 8 })
      Divider().width(2)
      Image(this.item.pics[2])
        .layoutWeight(1)
        .height(98)
        .borderRadius({ topLeft: 8, bottomLeft: 8 })
    }
    .margin({ top: 8 })
  }
}

@Component
struct MiddleVideoView {
  @ObjectLink item: ItemData;

  build() {
    Stack() {
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
      }
      .margin(6)
    }
  }
}