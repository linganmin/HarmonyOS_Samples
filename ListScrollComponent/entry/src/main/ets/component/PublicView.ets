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

import { BlogData, Params } from '../model/types';

@Component
export struct BlogItemHeaderView {
  @ObjectLink blogData: BlogData;

  build() {
    Row({ space: 8 }) {
      Image(this.blogData.user.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)

      Column() {
        Text(this.blogData.user.name)
          .fontSize(16)
          .fontColor('#333')
        Text(this.blogData.time)
          .fontSize(12)
          .fontColor('#999')
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }

  }
}

@Component
export struct BottomActionView {
  @ObjectLink blogData: BlogData;

  build() {
    Row({ space: 20 }) {
      Row() {
        Image($r('app.media.icon_like'))

          .width(20)
          .height(20)
        Text(this.blogData.likes.toString())
          .margin({ left: 4 })
      }
      .backgroundColor(Color.Transparent)

      Row() {
        Image($r('app.media.icon_comment'))
          .width(20)
          .height(20)
        Text(this.blogData.comments.toString())
          .margin({ left: 4 })
      }
      .backgroundColor(Color.Transparent)

      Row() {
        Image($r('app.media.icon_share'))
          .width(20)
          .height(20)
        Text(this.blogData.reposts.toString())
          .margin({ left: 4 })
      }
      .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 8 })
  }
}

@Component
export struct EasyBlogItem {
  @State blogData: BlogData = new BlogData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.blogData = (params as Params).blogData;
  }

  build() {
    Column({ space: 12 }) {
      BlogItemHeaderView({ blogData: this.blogData })
      Text(this.blogData.content)
        .fontSize(16)
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.None })
        .width('100%')
        .height('auto')
        .onAreaChange((_oldValue, _newValue) => {
        })
      BottomActionView({ blogData: this.blogData })
    }
    .justifyContent(FlexAlign.Start)
    .padding(12)
    .backgroundColor(Color.White)

  }
}