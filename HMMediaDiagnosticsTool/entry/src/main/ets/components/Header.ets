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
export struct Header {
  @Prop description: ResourceStr = '';

  build() {
    Column() {
      Column() {
        Text($r('app.string.detection_title'))
          .width('100%')
          .height('100%')
          .margin({ bottom: 8 })
          .fontSize(30)
          .fontWeight(700)
          .lineHeight(40)
          .textAlign(TextAlign.Start);
      }
      .height(40)
      .margin({ bottom: 2 });

      Column() {
        Text(this.description)
          .width('100%')
          .fontSize(14)
          .fontColor($r('app.color.text'))
          .opacity(0.6)
          .lineHeight(19)
          .textAlign(TextAlign.Start);
      };
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 30
    });
  }
}