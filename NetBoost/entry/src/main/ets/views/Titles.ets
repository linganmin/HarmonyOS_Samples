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

@Builder
export function Title(title: Resource | string = '') {
  Row() {
    Text(title)
      .fontSize($r('app.float.size_26fp'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.font_primary'))
      .height($r('app.float.size_35vp'))
      .textAlign(TextAlign.Start)
  }
  .width('100%')
  .height($r('app.float.title_bar_default_height'))
  .margin({
    top: $r('app.float.size_56vp')
  })
}

@Builder
export function SubTitle(title: Resource | string = '') {
  Row() {
    Text(title)
      .fontSize($r('app.float.size_14fp'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_secondary'))
      .height($r('app.float.size_19vp'))
      .textAlign(TextAlign.Start)
  }
  .width('100%')
  .margin({
    top: $r('app.float.size_28vp'),
    left: $r('app.float.size_12vp'),
  })
}