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
import CommonUtils from '../common/CommonUtils';

@Entry
@Component
struct Index {
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  uiContext: UIContext | undefined = undefined;

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
  }

  build() {
    Navigation(this.pageInfo) {
      Column() {
        Column() {
          Text($r('app.string.carKit_api_label'))
            .fontSize(30)
            .fontWeight(700)
            .textAlign(TextAlign.Start)
        }
        .margin({ top: this.uiContext?.px2vp(189), left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56) })
        .height(this.uiContext?.px2vp(280))

        Column({ space: this.uiContext?.px2vp(42) }) {
          Row() {
            Button($r('app.string.navigation_information'))
              .layoutWeight(1)
              .fontSize(CommonUtils.getButtonFontSize(this.uiContext))
              .onClick(() => {
                this.pageInfo.pushPathByName('NavInfoServicePage', null)
              })
              .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56) })
          }

          Row() {
            Button($r('app.string.mobility_service'))
              .layoutWeight(1)
              .fontSize(CommonUtils.getButtonFontSize(this.uiContext))
              .onClick(() => {
                this.pageInfo.pushPathByName('TravelServicePage', null)
              })
              .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56) })
          }
        }.position({ bottom: this.uiContext?.px2vp(56) })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .height('100%')
  }
}