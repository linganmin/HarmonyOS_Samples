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

import { bundleManager } from '@kit.AbilityKit'
import CommonConstants from '../common/CommonConstants';
import { AppInfoData } from '../model/AppInfoData';
import { AppInfoItem } from '../model/AppInfoItem';
import { InfoItem } from '../view/AppInfoComponent';

@Component
export struct GetAppInfo {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State pixelMap: PixelMap | null = null;
  @State appInfoData: Array<AppInfoItem> = new AppInfoData().getAppInfoItems();
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.get_appInfo_button').id);

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.pixelMap) {
            Image(this.pixelMap)
              .width(144)
              .height(144)
          } else {
            Row() {
              Text($r('app.string.image_text'))
            }
            .justifyContent(FlexAlign.Center)
            .width(144)
            .height(144)
            .backgroundColor(Color.White)
            .borderRadius(32)
          }

          Text($r('app.string.image_desc'))
            .fontWeight(500)
            .fontSize(16)
            .height(21)
            .margin({ top: 12 })
        }
        .padding({ top: 16, bottom: 12 })

        Column() {
          ForEach(this.appInfoData, (item: AppInfoItem, i: number) => {
            InfoItem({ item: item });
            if (i < this.appInfoData.length - 1) {
              Divider()
                .width(CommonConstants.FULL_PARENT)
                .strokeWidth(0.5)
                .color(Color.Black)
                .opacity(0.15)
            }
          }, (item: AppInfoItem, i: number) => item.itemValue + i.toString())
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
            this.GetBundleInfo();
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

  GetBundleInfo() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    // Obtain application information.
    bundleManager.getBundleInfoForSelf(bundleFlags, (err, data) => {
      if (err) {
        return;
      }
      let labelId = data.appInfo.labelResource.id;
      let iconResource = data.appInfo.iconResource.id;
      // Parse the picture PixelMap through the iconResource.
      this.pixelMap = this.getUIContext().getHostContext()!.resourceManager.getDrawableDescriptor(iconResource).getPixelMap();

      // Parse a string through the resource ID.
      let labelStr = this.getUIContext().getHostContext()!.resourceManager.getStringSync(labelId);
      // Obtain information of string type.
      this.appInfoData[0].itemValue = labelStr;
      this.appInfoData[1].itemValue = data.name;
      this.appInfoData[2].itemValue = data.versionName;
      this.appInfoData[3].itemValue = data.versionCode.toString();
    })
  }
}
