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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function VideoWithBlurBuilder() {
  VideoWithBlur()
}

// [Start VideoWithBlur_start]
@Entry
@Component
struct VideoWithBlur {
  // [StartExclude VideoWithBlur_start]
  pathStack: NavPathStack = new NavPathStack();
  mainWindow: window.Window = AppStorage.get('mainWindow') as window.Window;

  // [EndExclude VideoWithBlur_start]
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
            // The return button has a blurry effect
            Image($r('app.media.chevron_left'))
              .padding(12)
              .width(40)
              .height(40)
              .borderRadius('50%')
              .fillColor('rgba(255, 255, 255, 0.9)')
              .backgroundColor('rgba(0, 0, 0, 0.1)')
              .backdropBlur(40) // Set this component background blur
              .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
              // [StartExclude VideoWithBlur_start]
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
            // [EndExclude VideoWithBlur_start]
          }
          // [StartExclude VideoWithBlur_start]
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
            .id('review')
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
          // [EndExclude VideoWithBlur_start]
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
    // [StartExclude VideoWithBlur_start]
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onWillShow(() => {
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps).catch((err: BusinessError) => {
        hilog.error(0x0000, 'VideoWithBlur',
          `onWillShow setWindowSystemBarProperties failed, error code=${err.code}, message=${err.message}`);
      });
    })
    .onWillHide(() => {
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#000000'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps).catch((err: BusinessError) => {
        hilog.error(0x0000, 'VideoWithBlur',
          `onWillHide setWindowSystemBarProperties failed, error code=${err.code}, message=${err.message}`);
      });
    })
  }

  // [EndExclude VideoWithBlur_start]
}

// [End VideoWithBlur_start]
