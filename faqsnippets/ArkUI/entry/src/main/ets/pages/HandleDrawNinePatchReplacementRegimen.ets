/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:是否有处理"9图"（又称"draw9patch"、".9图"、"点9图"等）的平替方案
*/

// [Start chat_bubble_stretch_demo]
@Entry
@Component
struct ChatBubbleStretchDemo {
  @State text: string = 'Hello World Hello World Hello World Hello World';
  @State left: number = 10;
  @State right: number = 10;
  @State top: number = 10;
  @State bottom: number = 10;
  @State line: number = 2;
  @State textSize: SizeOptions = this.getUIContext().getMeasureUtils().measureTextSize({
    textContent: this.text
  });

  build() {
    Column() {
      Stack() {
        Image($r('app.media.lightBluexhdpi'))
          .width(this.getUIContext().px2vp(Number(`${this.textSize.width}`)) < 350 ? 60 + px2vp
          (Number(`${this.textSize.width}`)) : 350)
          .height(this.text.length < 40 ? 50 + px2vp(Number(`${this.textSize.height}`))
            : 50 + (this.getUIContext().px2vp(Number(`${this.textSize.height}`)) * this.line))
          // The reason for using the px unit is that the image itself is a physical pixel, and the segmentation algorithm is executed on the image itself. Therefore, these values are ultimately converted into physical pixel values.
          // Therefore, these divided lines must not exceed the size of the picture itself.
          .resizable({
            slice: {
              top: `${this.top}px`,
              left: `${this.left}px`,
              bottom: `${this.bottom}px`,
              right: `${this.right}px`
            }
          })
        Text(this.text)
      }
      .width(350)
      .height(200)
    }
    .height('100%')
    .width('100%')
  }
}

// [End chat_bubble_stretch_demo]