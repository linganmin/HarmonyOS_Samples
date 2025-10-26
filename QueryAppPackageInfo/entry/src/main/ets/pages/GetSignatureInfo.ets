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

import { bundleManager } from '@kit.AbilityKit';
import CommonConstants from '../common/CommonConstants';
import { AppInfoItem } from '../model/AppInfoItem';
import { AppSignatureInfoData } from '../model/AppSignatureInfoData';
import { InfoItem } from '../view/AppInfoComponent';

@Component
export struct GetSignatureInfo {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State signatureInfoData: Array<AppInfoItem> = new AppSignatureInfoData().getSignatureInfoItems();
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.get_appSignatureInfo_button').id);

  build() {
    NavDestination() {
      Column() {
        Column() {
          ForEach(this.signatureInfoData, (item: AppInfoItem, i: number) => {
            InfoItem({ item: item });
            if (i < this.signatureInfoData.length - 1) {
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
            this.GetBundleSignatureInfo();
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

  GetBundleSignatureInfo() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
    // Obtain application signature information.
    bundleManager.getBundleInfoForSelf(bundleFlags, (err, data) => {
      if (err) {
        return;
      }
      // Obtain information of string type.
      this.signatureInfoData[0].itemValue = data.signatureInfo.appId;
      this.signatureInfoData[1].itemValue = data.signatureInfo.fingerprint;
      this.signatureInfoData[2].itemValue = data.signatureInfo.appIdentifier;
    })
  }
}
