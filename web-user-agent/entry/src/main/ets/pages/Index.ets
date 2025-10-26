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

import { webview } from '@kit.ArkWeb';
import Logger from '../utils/Logger';

const FULL_PERCENT: string = '100%';
const COMMON_SPACE: number = 12;
const TAG: string = '[IndexPage]';
@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  @State customUserAgent: string = '';
  @State userAgent: string = '';

  aboutToAppear(): void {
    webview.once('webInited', () => {
      try {
        this.userAgent = this.controller.getUserAgent();
      } catch (error) {
        Logger.error(TAG, `get init UserAgent Error: ${JSON.stringify(error)}`);
      }
    })
  }

  build() {
    Column() {
      Web({ src: $rawfile("Index.html"), controller: this.controller })
        .width(FULL_PERCENT)
        .layoutWeight(1)
      Column({ space: COMMON_SPACE }) {
        Text($r('app.string.user_agent', this.customUserAgent))
          .width(FULL_PERCENT)
        Text($r('app.string.default_agent', this.userAgent))
          .width(FULL_PERCENT)
        Button($r('app.string.set_agent'))
          .onClick(() => {
            try {
              let userAgent = this.customUserAgent.length > 0 ? this.customUserAgent : this.userAgent;
              this.controller.setCustomUserAgent(userAgent + ' test');
            } catch (error) {
              Logger.error(TAG, `setCustomUserAgent Error: ${JSON.stringify(error)}`);
            }
          })
        Button($r('app.string.get_agent'))
          .onClick(() => {
            try {
              this.customUserAgent = this.controller.getCustomUserAgent();
              Logger.info(TAG, 'getCustomUserAgent Success, userAgent: ' + this.userAgent);
            } catch (error) {
              Logger.error(TAG, `getCustomUserAgent Error: ${JSON.stringify(error)}`);
            }
          })
        Button($r('app.string.get_default_agent'))
          .onClick(() => {
            try {
              this.userAgent = this.controller.getUserAgent();
              Logger.info(TAG, 'getUserAgent Success, userAgent: ' + this.userAgent);
            } catch (error) {
              Logger.error(TAG, `getUserAgent Error: ${JSON.stringify(error)}`);
            }
          })
        Button($r('app.string.refresh'))
          .onClick(() => {
            this.controller.refresh();
          })
      }
      .width(FULL_PERCENT)
      .padding($r('app.float.padding'))
      .backgroundColor($r('app.color.common_bg'))
    }
    .width(FULL_PERCENT)
    .height(FULL_PERCENT)
  }
}