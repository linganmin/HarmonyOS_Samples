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
export struct NetInfoItem {
  @Prop title: Resource;
  @Prop content: ResourceStr;

  build() {
    Column() {
      Text(this.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)

      Text(this.content)
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 10 })
    }
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width('100%')
    .borderRadius(20)
  }
}