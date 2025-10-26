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

import { window } from '@kit.ArkUI';

@Builder
export function TransparentVideoBuilder() {
  TransparentVideo()
}

// [Start TransparentVideo_start]
@Entry
@Component
struct TransparentVideo {
  // [StartExclude TransparentVideo_start]
  pathStack: NavPathStack = new NavPathStack();
  mainWindow: window.Window = AppStorage.get('mainWindow') as window.Window;
  // [EndExclude TransparentVideo_start]
  build() {
    // [StartExclude TransparentVideo_start]
    NavDestination() {
      // [EndExclude TransparentVideo_start]
      RelativeContainer() {
        // Bottom UI component
        Image($r('app.media.watermark'))
          .width(200)
          .height(80)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        // Video Layer
        Video({
          src: $r('app.media.test_video')
        })
          .height('100%')
          .width('100%')
          .loop(true)
          .autoPlay(true)
          .controls(false)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .opacity(0.7) // Set the transparency of the video layer
      }
      .height('100%')
      .width('100%')
    }
    // [StartExclude TransparentVideo_start]
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onWillShow(() => {
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps);
    })
    .onWillHide(() => {
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: '#000000'
      };
      this.mainWindow.setWindowSystemBarProperties(sysBarProps);
    })
  }
  // [EndExclude TransparentVideo_start]
}
// [End TransparentVideo_start]