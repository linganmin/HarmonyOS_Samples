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

@Builder
export function searchPageBuilder() {
  SearchPageView()
}

@Component
struct SearchPageView {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.voice_search'))
          .font({
            size: 19,
            weight: 700
          })
          .fontColor($r('sys.color.white'))
          .margin({ top: 17 })

        Search()
          .width(164)
          .height(40)
          .margin({ top: 48 })
          .backgroundColor($r('sys.color.white'))
          .fontColor(Color.Black)

        Row({ space: 16.5 }) {
          Button() {
            Image($r('app.media.cancel'))
              .width(20)
          }
          .backgroundColor('#979797')
          .width(40)
          .height(40)

          Button() {
            Image($r('app.media.voice_input'))
              .width(28)
          }
          .onClick(() => {
            this.pathStack.pushPathByName('ResultsPage', null);
          })
          .backgroundColor('#EB8D00')
          .width(60)
          .height(60)

          Button() {
            Image($r('app.media.voice_convert_text'))
              .width(20)
          }
          .backgroundColor('#979797')
          .width(40)
          .height(40)
        }
        .alignItems(VerticalAlign.Top)
        .margin({ top: 37 })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .hideToolBar(true)
    .height('100%')
    .width('100%')
    .borderRadius('50%')
  }
}