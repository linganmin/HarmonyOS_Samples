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

@Component
export struct Title {
  build() {
    Row() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize($r('app.float.size_26fp'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.font_primary'))
        .height($r('app.float.size_35vp'))
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height($r('app.float.title_bar_default_height'))
  }
}

@Component
export struct ContentSubTitle {
  build() {
    Row() {
      Text($r('app.string.asset_overview'))
        .fontSize($r('app.float.size_18fp'))
        .height($r('app.float.size_24vp'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({
          bottom: $r('app.float.size_8vp')
        })
    }
    .alignItems(VerticalAlign.Bottom)
    .width('100%')
    .height($r('app.float.size_50vp'))
  }
}