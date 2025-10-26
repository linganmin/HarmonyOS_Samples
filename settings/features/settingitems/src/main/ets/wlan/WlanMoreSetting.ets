/**
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

// [Start wlan_more_setting_item]
import { SubItemArrow } from '../components/SubItemArrow'
import { SubItemToggle } from '../components/SubItemToggle'
import { ItemGroup } from '../components/ItemGroup'
import { ItemDescription } from '../components/ItemDescription'
import { Logger } from '@ohos/common/Index'

const TAG = "WlanMoreSetting"

@Component
export struct WlanMoreSettingItem {
  @LocalStorageLink('selectedLabel') selectedLabel: string = '';
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    SubItemArrow({ title: $r('app.string.moreWlanSettings') })
      .onClick(() => {
        this.pathInfos.pushPath({ name: 'WlanMoreSetting' });
        this.selectedLabel = 'WLAN';
      })
  }
}

@Builder
export function WlanMoreSettingBuilder() {
  WlanMoreSetting();
}

@Component
export struct WlanMoreSetting {

  private getSettingTitle(): string {
    let title = "";
    try {
      title = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.moreWlanSettings').id)
    } catch(err) {
      if (err.code) {
        Logger.error(TAG, `Failed to get setting title. Cause: ${JSON.stringify(err)}`);
      }
    }
    return title;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          ItemGroup() {
            SubItemArrow({
              title: $r('app.string.wlanPlus'),
              tag: $r('app.string.enabled')
            })
          }

          ItemDescription({ description: $r('app.string.wlanPlusTip') })
            .margin({
              top: 8,
              bottom: 24,
              left: 12,
              right: 12
            })

          ItemGroup() {
            SubItemArrow({ title: $r('app.string.wlanDirect') })
          }

          Blank().height(12)

          ItemGroup() {
            SubItemToggle({ title: $r('app.string.wlanSecurityCheck') })
          }

          ItemDescription({ description: $r('app.string.wlanSecurityCheckTip') })
            .margin({
              top: 8,
              bottom: 24,
              left: 12,
              right: 12
            })

          ItemGroup() {
            SubItemArrow({ title: $r('app.string.savedWlan') })
            Divider()
              .strokeWidth('1px')
              .color($r('sys.color.ohos_id_color_list_separator'))
              .margin({ left: 12, right: 8 })
            SubItemArrow({ title: $r('app.string.installCertificates') })
          }
        }
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .padding({ left: 12, right: 12 })
      }
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .title(this.getSettingTitle())
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
// [End wlan_more_setting_item]