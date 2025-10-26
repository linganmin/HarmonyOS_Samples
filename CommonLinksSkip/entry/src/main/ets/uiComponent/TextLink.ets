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

// [Start TextLinkComponent]
@Component
export default struct TextLink {
  @State enableDataDetector: boolean = true;
  public img: string | PixelMap | Resource = $r('app.media.Public_avatar');
  public text: ResourceStr = '';

  // [StartExclude TextLinkComponent]
  build() {
    // [Start Style]
    Row() {
      Image(this.img)
        .width(36)
        .height(36)
      Row() {
        // [Start AddAttributes]
        Text(this.text)
          .enableDataDetector(this.enableDataDetector)
        // [End AddAttributes]
      }
      .borderRadius({
        topLeft: 2,
        topRight: 16,
        bottomLeft: 16,
        bottomRight: 16
      })
      .margin({ left: 8 })
      .padding({
        left: 12,
        right: 12,
        top: 12,
        bottom: 12
      })
      .backgroundColor(Color.White)
      .constraintSize({ maxWidth: 300 })
      .width('100%')
    }
    .alignItems(VerticalAlign.Top)
    .margin({
      left: 16,
      right: 16,
      bottom: 12
    })
    .width('100%')
    // [End Style]
  }
  // [EndExclude TextLinkComponent]
}
// [End TextLinkComponent]