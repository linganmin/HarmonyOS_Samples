/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { webview } from '@kit.ArkWeb';
import { Logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const EXAMPLE_URL = 'https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide';
const WEB_ID = 'WebPage';
const TAG = 'WebSnapshot';

@Entry
@Component
struct WebSnapshotWebTag {
  @State h5Width: number = 0;
  @State h5Height: number = 0;
  @State longPixelMap: PixelMap | undefined = undefined;
  private webviewController: webview.WebviewController = new webview.WebviewController();

  // [Start init_web_snapshot]
  aboutToAppear(): void {
    try {
      webview.WebviewController.initializeWebEngine();
      webview.WebviewController.enableWholeWebPageDrawing();
      webview.WebviewController.prepareForPageLoad(EXAMPLE_URL, true, 2);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `web snapshot init err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
  // [End init_web_snapshot]

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.one_click_snapshot'))
          .width('100%')
          .margin({ bottom: 12 })
          .onClick(async () => {
            this.longPixelMap = undefined;
            await this.getWebSize();
            this.webSnapshot();
          })

        Stack() {
          if (this.longPixelMap) {
            Scroll() {
              Image(this.longPixelMap)
                .width('50%')
            }
            .zIndex(2)
          }

          Web({
            src: EXAMPLE_URL,
            controller: this.webviewController
          })
            .backgroundColor(Color.White)
            .width('100%')
            .id(WEB_ID)
        }
        .width('100%')
        .layoutWeight(1)
        .borderRadius(12)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
    }
    .title($r('app.string.title_web_snapshot'))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: AppStorage.get<number>('statusBarHeight') ?? 0 })
  }

  // [Start web_snapshot]
  async webSnapshot() {
    try {
      this.webviewController.webPageSnapshot({ id: WEB_ID, size: { width: this.h5Width, height: this.h5Height } },
        async (error, result) => {
          if (result) {
            this.longPixelMap = result.imagePixelMap;
          }
        });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `webSnapshot err, errCode: ${err.code}, error mesage: ${err.message}`);
    }
  }
  // [End web_snapshot]

  // [Start get_web_size]
  async getWebSize() {
    const SCRIPT = '[document.documentElement.scrollWidth, document.documentElement.scrollHeight]';
    try {
      this.webviewController.runJavaScriptExt(SCRIPT).then((result) => {
        if (result.getType() === webview.JsMessageType.ARRAY) {
          this.h5Width = (result.getArray() as number[])[0];
          this.h5Height = (result.getArray() as number[])[1];
          Logger.info(TAG, `h5Width is ${this.h5Width}, h5Height is ${this.h5Height}`);
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `getWebSize exception, errCode: ${error.code}, error mesage: ${error.message}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getWebSize failed, errCode: ${err.code}, error mesage: ${err.message}`);
    }
  }
  // [End get_web_size]
}
