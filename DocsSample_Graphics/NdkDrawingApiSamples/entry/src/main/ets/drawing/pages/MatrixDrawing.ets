/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import XComponentContext from '../../interface/XComponentContext';

@Entry
@Component
struct MatrixDrawing {
  private xComponentContext: XComponentContext | undefined = undefined;

  build() {
    Column() {
      XComponent({ id: 'basicEffectXComponent', type: XComponentType.SURFACE, libraryname: 'entry' })
        .onLoad((xComponentContext) => {
          this.xComponentContext = xComponentContext as XComponentContext;
        })
        .backgroundColor(Color.White)
        .width('100%')
        .height('70%')
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Start
      }) {
        Button('MatrixBasic')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'MatrixBasic');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('Translation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'TranslationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PreTranslation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PreTranslationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PostTranslation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PostTranslationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('Rotation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'RotationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PreRotation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PreRotationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PostRotation')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PostRotationOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('Scale')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'ScaleOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PreScale')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PreScaleOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('PostScale')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'PostScaleOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
        Button('Concat')
          .onClick((): void => {
            if (this.xComponentContext) {
              this.xComponentContext.draw('CanvasGet', 'ConcatOperation');
            }
          })
          .margin({ top: 5, bottom: 5, left: 5, right: 5 })
      }
      .width('100%')
      .height('30%')
    }
  }
}