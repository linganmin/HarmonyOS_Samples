/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  parentTitle() {
    Text($r('app.string.index_title'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontSize(30)
      .fontWeight(700)
      .lineHeight(40)
      .padding({
        left: 12,
        right: 20
      })
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        this.parentTitle()
        Column() {
          Button($r('app.string.video_with_blur'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.pathStack.pushPath({ name: 'videoWithBlur' });
            })
          Button($r('app.string.normal_video'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.pathStack.pushPath({ name: 'normalVideo' });
            })
          Button($r('app.string.web_with_blur'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.pathStack.pushPath({ name: 'webWithBlur' });
            })
          Button($r('app.string.normal_web'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.pathStack.pushPath({ name: 'normalWeb' });
            })
          Button($r('app.string.transparent_video'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.pathStack.pushPath({ name: 'transparentVideo' });
            })

          Button($r('app.string.opaque_video'))
            .fontSize(16)
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.pathStack.pushPath({ name: 'opaqueVideo' });
            })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
      }
      .height('100%')
      .width('100%')
      .padding({
        top: 92,
        bottom: 44
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .mode(NavigationMode.Stack)
    .height('100%')
    .hideTitleBar(true)
  }
}