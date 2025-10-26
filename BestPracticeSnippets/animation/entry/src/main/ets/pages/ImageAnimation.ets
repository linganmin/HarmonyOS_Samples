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

// [Start image_animation]
// [Start component_animation]
@Component
export struct ImageAnimation {
  @State imageWidth: number = 60;
  @State imageHeight: number = 60;
  @State xPosition: number = 0;
  @State yPosition: number = 0;
  @State imageScaleX: number = 1;
  @State imageScaleY: number = 1;
  @State imageTranslateX: number = 0;
  @State imageTranslateY: number = 0;

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')
        // [StartExclude image_animation]
        // [StartExclude component_animation]
        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')
        // [EndExclude image_animation]
        // [EndExclude component_animation]
      }
      .height('25%')
      // [StartExclude component_animation]
      // [StartExclude image_animation]
      Row() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')
      }
      .height('25%')

      Row() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.imageWidth)
            .height(this.imageHeight)
            .position({ x: this.xPosition, y: this.yPosition })
            .scale({
              x: this.imageScaleX,
              y: this.imageScaleY,
              centerX: 0,
              centerY: 0
            })
            .translate({ x: this.imageTranslateX, y: this.imageTranslateY })
        }.width('33%')
      }
      .height('25%')
      // [EndExclude image_animation]
      // [EndExclude component_animation]
      Column() {
        // [StartExclude component_animation]
        Button('Change Layout Properties')
          .width('100%')
          // Key Attribute Settings
          .onClick(() => {
            // Loop animation by play count
            for (let i = 0; i < 10; i++) {
              // Interval playback position, width and height changes
              if (i % 2 == 0) {
                setTimeout(() => {
                  this.getUIContext().animateTo({ duration: 1000 }, () => {
                    this.imageWidth = 100;
                    this.imageHeight = 100;
                    this.xPosition = 12;
                    this.yPosition = 12;
                  })
                }, 1000 * i)
              } else {
                setTimeout(() => {
                  this.getUIContext().animateTo({ duration: 1000 }, () => {
                    this.imageWidth = 60;
                    this.imageHeight = 60;
                    this.xPosition = 0;
                    this.yPosition = 0;
                  })
                }, 1000 * i)
              }
            }
          })
        // [EndExclude component_animation]
        Button('Change Image Properties')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Loop animation by play count
            for (let i = 0; i < 10; i++) {
              if (i % 2 == 0) {
                setTimeout(() => {
                  this.getUIContext().animateTo({ duration: 1000 }, () => {
                    this.imageScaleX = 2;
                    this.imageScaleY = 2;
                    this.imageTranslateX = 12;
                    this.imageTranslateY = 12;
                  })
                }, 1000 * i)
              } else {
                setTimeout(() => {
                  this.getUIContext().animateTo({ duration: 1000 }, () => {
                    this.imageScaleX = 1;
                    this.imageScaleY = 1;
                    this.imageTranslateX = 0;
                    this.imageTranslateY = 0;
                  })
                }, 1000 * i)
              }
            }
          })
      }
      .justifyContent(FlexAlign.End)
      .height('25%')
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}
// [End image_animation]
// [End component_animation]