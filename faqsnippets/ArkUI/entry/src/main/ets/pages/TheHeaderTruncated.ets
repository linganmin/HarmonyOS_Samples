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
* FAQ:如何解决Web页面输入框拉起键盘后，页面头部被截断的问题
*/

// [Start sub_window_page]
// Sub-window page layout
import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';

@Entry
@Component
export struct SubWindowPage {
  @State webViewVisibility: Visibility = Visibility.Visible;
  private pageWidth = 320;
  private pageHeight = 500;
  private controller: webview.WebviewController = new webview.WebviewController();
  @State flexAlign: FlexAlign = FlexAlign.Center;
  @State screenHeight: number | string = '100%';

  aboutToAppear() {
    window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
      // Monitor keyboard pop-up and collapse
      currentWindow.on('avoidAreaChange', async data => {
        let property = currentWindow.getWindowProperties();
        let avoidArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
        this.screenHeight = this.getUIContext().px2vp(property.windowRect.height - avoidArea.bottomRect.height);
      });
    })
  }

  build() {
    Stack() {
      Column() {
        Web({ src: $rawfile('index.html'), controller: this.controller })
          .javaScriptAccess(true)
          .fileAccess(false)
          .zoomAccess(false)
          .domStorageAccess(true)
          .onlineImageAccess(true)
          .horizontalScrollBarAccess(false)
          .verticalScrollBarAccess(false)
          .cacheMode(CacheMode.Online)
          .width(this.pageWidth)
          .height(this.pageHeight)
          .border({ radius: 6 })
          .visibility(this.webViewVisibility)
          .backgroundColor(Color.Pink)
      }
      .justifyContent(this.flexAlign)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(this.screenHeight)
    .backgroundColor('#999955')
    .alignContent(Alignment.Center)
  }
}
// [End sub_window_page]