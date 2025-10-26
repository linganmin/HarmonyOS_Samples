/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
export struct ActionButtonView {
  @Prop count: number = 0;
  @Prop textWidth: Resource = $r('app.float.default_icon_width');
  @Prop imgResource: Resource = $r('app.media.ic_failure');

  build() {
    Row() {
      Stack() {
        Image(this.imgResource)
          .margin({ right: 4 })
          .size({ width: 16, height: 16 })
      }

      Text(this.count.toString())
        .fontFamily('HarmonyHeiTi')
        .fontSize(12)
        .width(this.textWidth)
        .opacity(0.6)
    }
    .width(56)
    .padding({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}