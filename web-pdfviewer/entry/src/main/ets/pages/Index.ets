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
import { CommonConstants } from '../constants/CommonConstants';

@Entry
@Component
struct Index {
  // Set the local loading progress. The initial value of the progress bar is 0.
  @State localProgressValue: number = CommonConstants.INIT_NUM;
  // The local progress bar is hidden during record loading. The record is loaded by default when the page is displayed.
  @State isHiddenLocalProgress: Boolean = true;
  // Sets the network loading progress. The initial value of the progress bar is 0.
  @State remoteProgressValue: number = CommonConstants.INIT_NUM;
  // The network loading progress bar is hidden, and the page is loaded by default.
  @State isHiddenRemoteProgress: Boolean = true;
  //Initial position of the selected tabs component.
  @State tabsIndex: number = CommonConstants.INIT_NUM;
  controller: webview.WebviewController = new webview.WebviewController();
  tabsController: TabsController = new TabsController();

  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        // Preview a local PDF file.
        TabContent() {
          Column() {
            if (this.isHiddenLocalProgress) {
              Progress({
                value: CommonConstants.START_VALUE,
                total: CommonConstants.TOTAL_VALUE,
                type: ProgressType.Linear
              })
                .width(CommonConstants.FULL_PERCENT)
                .height($r('app.integer.progress_height'))
                .value(this.localProgressValue)
                .color(Color.Green)
            }
            Web({ src: CommonConstants.RESOURCE_URL, controller: this.controller })
              .onProgressChange((event) => {
                if (event) {
                  this.localProgressValue = event.newProgress;
                  if (this.localProgressValue >= CommonConstants.TOTAL_VALUE) {
                    this.isHiddenLocalProgress = false;
                  }
                }
              })
              .horizontalScrollBarAccess(true)
              .domStorageAccess(true)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
        .tabBar(
          SubTabBarStyle.of($r('app.string.tab_index_one_title'))
            .indicator({ color: $r('app.color.ohos_id_color_emphasize') })
            .labelStyle({
              overflow: TextOverflow.Clip,
              minFontSize: $r('app.integer.min_font_size'),
              maxFontSize: $r('app.integer.max_font_size'),
              font: { size: $r('app.integer.font_size') }
            })
        )

        // Preview network PDF files.
        TabContent() {
          Column() {
            if (this.isHiddenRemoteProgress) {
              Progress({
                value: CommonConstants.START_VALUE,
                total: CommonConstants.TOTAL_VALUE,
                type: ProgressType.Linear
              })
                .width(CommonConstants.FULL_PERCENT)
                .height($r('app.integer.progress_height'))
                .value(this.remoteProgressValue)
                .color(Color.Green)
            }
            Web({
              src: CommonConstants.REMOTE_URL,
              controller: this.controller
            })
              .onProgressChange((event) => {
                if (event) {
                  this.remoteProgressValue = event.newProgress;
                  if (this.remoteProgressValue >= CommonConstants.TOTAL_VALUE) {
                    this.isHiddenRemoteProgress = false;
                  }
                }
              })
              .horizontalScrollBarAccess(true)
              .domStorageAccess(true)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
        .tabBar(
          SubTabBarStyle.of($r('app.string.tab_index_two_title'))
            .indicator({ color: $r('app.color.ohos_id_color_emphasize') })
            .labelStyle({
              overflow: TextOverflow.Clip,
              minFontSize: $r('app.integer.min_font_size'),
              maxFontSize: $r('app.integer.max_font_size'),
              font: { size: $r('app.integer.font_size') }
            })
        )
      }
      .barBackgroundColor(Color.White)
      .barWidth(CommonConstants.FULL_PERCENT)
      .scrollable(false)
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: $r('app.integer.home_margin_top') })
  }
}