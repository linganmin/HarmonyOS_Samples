/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { GetAppInfo } from './GetAppInfo';
import { GetSignatureInfo } from './GetSignatureInfo';
import { NativeGetAppInfo } from './NativeGetAppInfo';
import CommonConstants from '../common/CommonConstants';

@Entry
@Component
struct MainPage {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === CommonConstants.GET_APP_INFO_PAGE) {
      GetAppInfo();
    } else if (name === CommonConstants.GET_SIGNATURE_INFO_PAGE) {
      GetSignatureInfo();
    } else if (name === CommonConstants.NATIVE_GET_APP_INFO_PAGE) {
      NativeGetAppInfo();
    } else {
      MainPage();
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Text($r('app.string.title_desc'))
          .width(CommonConstants.FULL_PARENT)
          .height(56)
          .fontSize(30)
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 64 })

        Blank();

        Button($r('app.string.get_appInfo_button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(500)
          .fontSize(16)
          .margin({ top: 12 })
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstants.GET_APP_INFO_PAGE });
          })

        Button($r('app.string.get_appSignatureInfo_button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(500)
          .fontSize(16)
          .margin({ top: 12 })
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstants.GET_SIGNATURE_INFO_PAGE });
          })

        Button($r('app.string.native_get_appInfo_button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(500)
          .fontSize(16)
          .margin({ top: 12 })
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstants.NATIVE_GET_APP_INFO_PAGE });
          })
      }
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.FULL_PARENT)
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.background_color'))
    .navDestination(this.PageMap)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
