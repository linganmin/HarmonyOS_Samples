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
export struct BottomView {
  build() {
    Row() {
      Image($r('app.media.icon_user3'))
        .height(36)
        .width(36)
      Row() {
        Image($r('app.media.icon_edit'))
          .height(16)
          .width(16)
        Image($r('app.media.icon_face'))
          .height(24)
          .width(24)
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor('#F2F2F2F2')
      .borderRadius(20)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ left: 12 })
      .padding({
        left: 12,
        right: 12
      })
    }
    .width('100%')
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: 16,
      top: 20,
      right: 16,
      bottom: (AppStorage.get<number>('naviIndicatorHeight') || 0) + 12
    })
  }
}