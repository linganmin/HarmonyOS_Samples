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

@Component
export struct TitleBackView {
  title: Resource = $r('app.string.edit_image');

  build() {
    Column() {
      Stack() {
        Column() {
          Text(this.title)
            .fontColor(Color.Black)
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        }.width($r('app.string.full_screen'))
        .alignItems(HorizontalAlign.Center)

        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width($r('app.float.icon_size_24'))
            .height($r('app.float.icon_size_24'))
            .objectFit(ImageFit.Fill)
            .margin({ left: $r('sys.float.ohos_id_elements_margin_horizontal_l') })
        }
        .alignItems(VerticalAlign.Center)
        .width($r('app.float.arrow_width'))
        .align(Alignment.Start)
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          this.getUIContext().getRouter().back()
        })

      }.align(Alignment.Start)
      .width($r('app.string.full_screen'))
      .height($r('app.float.navigation_height_sm'))
    }.align(Alignment.Start)
    .width($r('app.string.full_screen'))
    .height($r('app.float.navigation_height_sm'))
  }
}