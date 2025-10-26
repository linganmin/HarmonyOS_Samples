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

import { LengthMetrics, LengthUnit, window } from '@kit.ArkUI';

@Builder
export function NormalVideoBuilder() {
  NormalVideo()
}

// [Start NormalVideo_start]
@Component
struct NormalVideo {
  // [StartExclude NormalVideo_start]
  pathStack: NavPathStack = new NavPathStack();
  mainWindow: window.Window = AppStorage.get('mainWindow') as window.Window;
  // [EndExclude NormalVideo_start]
  build() {
    NavDestination() {
      Stack() {
        // Video Layer
        Video({
          src: $r('app.media.test_video')
        })
          .height('100%')
          .width('100%')
          .loop(true)
          .autoPlay(true)
          .controls(false)

        RelativeContainer() {
          Row() {
            // The return button does not have a blur effect
            Image($r('app.media.chevron_left'))
              .padding(12)
              .width(40)
              .height(40)
              .borderRadius('50%')
              .fillColor('rgba(255, 255, 255, 0.9)')
              .backgroundColor('rgba(0, 0, 0, 0.1)')
                // [StartExclude NormalVideo_start]
              .onClick(() => {
                this.pathStack.pop();
              })

            Text($r('app.string.title'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .lineHeight(26)
              .padding({ left: 8 })
              .fontColor('rgba(255, 255, 255, 0.9)')
            // [EndExclude NormalVideo_start]
          }
          // [StartExclude NormalVideo_start]
          .width('100%')
          .height(56)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })

          Column({ space: 8 }) {
            Text() {
              Span($r('app.string.user_name'))
                .fontColor('rgba(255, 255, 255, 0.9)')
                .fontWeight(FontWeight.Medium)
              Span($r('app.string.date'))
                .fontColor('rgba(255, 255, 255, 0.6)')
                .fontWeight(FontWeight.Regular)
                .fontSize(12)
                .baselineOffset(new LengthMetrics(2, LengthUnit.VP))
            }
            .align(Alignment.Center)
            .lineHeight(21)

            Text($r('app.string.topic'))
              .fontColor('rgba(255, 255, 255, 0.9)')
              .fontWeight(FontWeight.Regular)
              .fontSize(14)
          }
          .width('100%')
          .alignRules({
            bottom: { anchor: 'review', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .margin({ bottom: 13 })
          .alignItems(HorizontalAlign.Start)


          TextInput({ placeholder: $r('app.string.review') })
            .id('normal_video_review')
            .type(InputType.Normal)
            .width('100%')
            .height(39)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .placeholderFont({
              size: 16,
              weight: 400
            })
            .placeholderColor('rgba(255, 255, 255, 0.6)')
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
          // [EndExclude NormalVideo_start]
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: 36,
          bottom: 44
        })
      }
      .width('100%')
      .height('100%')
    }
    // [StartExclude NormalVideo_start]
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onWillShow(()=>{
      let sysBarProps:window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps);
    })
    .onWillHide(()=>{
      let sysBarProps:window.SystemBarProperties = {
        statusBarContentColor: '#000000'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps);
    })
  }
  // [EndExclude NormalVideo_start]
}
// [End NormalVideo_start]