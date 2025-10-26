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

import testNapi from 'libentry.so';
import CommonConstants from '../common/CommonConstants';
import { AppInfoItem } from '../model/AppInfoItem';
import { NativeAppInfoData } from '../model/NativeAppInfoData';
import { InfoItem } from '../view/AppInfoComponent';

@Component
export struct NativeGetAppInfo {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State nativeAppInfoData: Array<AppInfoItem> = new NativeAppInfoData().getNativeAppInfoItems();
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.native_get_appInfo_button').id);

  build() {
    NavDestination() {
      Column() {
        Column() {
          ForEach(this.nativeAppInfoData, (item: AppInfoItem, i: number) => {
            InfoItem({ item: item });
            if (i < this.nativeAppInfoData.length - 1) {
              Divider()
                .width(CommonConstants.FULL_PARENT)
                .strokeWidth(0.5)
                .color(Color.Black)
                .opacity(0.15)
            }
          }, (item: AppInfoItem) => item.itemTitle.toString())
        }
        .backgroundColor(Color.White)
        .margin({ bottom: 16, top: 8 })
        .padding({ left: 12, right: 12 })
        .borderRadius(16)

        Blank();

        Button($r('app.string.get_info_button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(500)
          .fontSize(16)
          .margin({ top: 12 })
          .onClick(() => {
            // Call the native interface and return application information.
            let appInfo = testNapi.getCurrentAppInfo();
            this.nativeAppInfoData[0].itemValue = appInfo.bundleName;
            this.nativeAppInfoData[1].itemValue = appInfo.appId;
            this.nativeAppInfoData[2].itemValue = appInfo.fingerprint;
            this.nativeAppInfoData[3].itemValue = appInfo.appIdentifier;
          })
      }
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.FULL_PARENT)
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .backgroundColor($r('app.color.background_color'))
    .title(this.title)
  }
}