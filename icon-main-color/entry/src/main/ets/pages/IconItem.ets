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
import { AppInfo } from '../viewmodel/AppInfoModel';
import CommonConstants from '../constants/CommonContants';

@Component
export struct IconItem {
  @ObjectLink item: AppInfo ;

  build() {
    Row() {
      Image($rawfile(this.item.icon))
        .height($r('app.integer.image_size_height'))
        .width($r('app.integer.image_size_width'))
        .borderRadius($r('app.integer.icon_image_border_radius'))
      Column() {
        Text(this.item.name)
          .fontSize($r('app.integer.text_name_font_size'))
          .fontWeight(FontWeight.Medium)
          .opacity(CommonConstants.TEXT_NAME_FONT_OPACITY)
        Text(this.item.description)
          .fontSize($r('app.integer.text_description_font_size'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r('app.integer.text_description_margin_top') })
          .opacity(CommonConstants.TEXT_NAME_DESCRIPTION_FONT_OPACITY)
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .height($r('app.integer.icon_column_height'))
      .margin({
        left: $r('app.integer.icon_column_margin_left')
      })
    }
    .padding({
      left: $r('app.integer.icon_item_padding_left')
    })
    .width($r('app.string.percent_100'))
    .height($r('app.integer.icon_item_height'))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.item.backgroundColor === '' ? Color.White : this.item.backgroundColor)
    .borderRadius($r('app.integer.icon_item_radius'))
  }
}