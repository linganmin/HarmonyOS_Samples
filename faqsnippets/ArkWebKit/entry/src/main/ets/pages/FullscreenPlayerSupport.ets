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
* FAQ:如何适配网页内播放器全屏
*/

// [Start FullscreenPlayerSupport]
import { mediaquery, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebPlayerFullScreen {
  @State color: string = '#DB7093';
  @State text: string = 'Portrait';
  @State portraitFunc: mediaquery.MediaQueryResult | void | null = null;
  // Full-screen exit processor, used to control the exit in full-screen state
  handler: FullScreenExitHandler | null = null;
  // The condition is met when the device is in landscape mode
  listener: mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(orientation: landscape)');
  controller: webview.WebviewController = new webview.WebviewController();

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    // If the device is in landscape mode, change the corresponding page layout
    if (mediaQueryResult.matches as boolean) {
      this.color = '#FFD700';
      this.text = 'Landscape';
    } else {
      this.color = '#DB7093';
      this.text = 'Portrait';
    }
  }

  aboutToAppear() {
    // Bind the current application instance
    // Bind callback function
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPortrait(mediaQueryResult);
    });
  }

  // Change the horizontal and vertical screen status function of the device
  private changeOrientation(isLandscape: boolean) {
    // Retrieve contextual information for UIAbility instances
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // Call this interface to manually change the device's horizontal and vertical screen status
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT);
    });
  }

  build() {
    Column() {
      Web({ src: 'https://developer.huawei.com/consumer/cn/design/', controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onFullScreenEnter((event) => {
          this.handler = event.handler;
          this.changeOrientation(true);
        })
        .onFullScreenExit(() => {
          if (this.handler) {
            this.handler.exitFullScreen();
            this.changeOrientation(false);
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}
// [End FullscreenPlayerSupport]