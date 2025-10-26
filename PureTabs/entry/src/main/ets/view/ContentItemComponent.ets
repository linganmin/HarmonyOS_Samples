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

import { Constants } from "../common/constant/Constants";
import ContentItemViewModel from "../viewmodel/ContentItemViewModel";


@Component
export default struct ContentItemComponent {
  @Prop contentItemViewModel: ContentItemViewModel;

  build() {
    Column() {
      Row() {
        Image(this.contentItemViewModel.imgUrl1)
          .width(30)
          .height(30)
          .borderRadius(15)
        Column() {
          Text(this.contentItemViewModel.username)
            .fontSize(15)
          Text(this.contentItemViewModel.publishTime)
            .fontSize(12)
            .fontColor($r('app.color.content_item_text_color'))
        }
        .margin({ left: 10 })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }

      Column() {
        Text(this.contentItemViewModel.title)
        .fontSize(16)
        .id('title')
        .textAlign(TextAlign.Start)

      }
      .margin({top:10, bottom: 10})

      Row() {
        Image(this.contentItemViewModel.imgUrl2)
          .width(115)
          .height(115)
        Image(this.contentItemViewModel.imgUrl3)
          .width(115)
          .height(115)
        Image(this.contentItemViewModel.imgUrl4)
          .width(115)
          .height(115)
      }
      .width(Constants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(Constants.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)

  }
}