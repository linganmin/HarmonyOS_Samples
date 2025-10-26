/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import { MainItem } from '../components/MainItem';
import { SubItemArrow } from '../components/SubItemArrow';
import { ItemGroup } from '../components/ItemGroup';
import { Logger } from '@ohos/common/Index';

const TAG = "MoreConnectionsItem"

@Component
export struct MoreConnectionsItem {
  @LocalStorageLink('selectedLabel') selectedLabel: string = '';
  @LocalStorageProp('currentBreakpoint') curBp: string = 'sm';
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      MainItem({
        title: $r("app.string.moreConnectionsTab"),
        icon: $r('app.media.ic_settings_more_connections'),
        label: 'MORE_CONNECTIONS'
      })
      .onClick(() => {
        this.pathInfos.pushPath({ name: 'MoreConnections'});
        this.selectedLabel = 'MORE_CONNECTIONS';
      })
    }
  }
}

@Builder
export function MoreConnectionsBuilder() {
  MoreConnections();
}

@Component
export struct MoreConnections {
  @State itemTitle: string = '';
  @LocalStorageLink('selectedLabel') selectedLabel: string = '';
  @Consume('pathInfos') pathInfos: NavPathStack;

  aboutToAppear() {
    try {
      this.itemTitle =
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.moreConnectionsTab').id);
    } catch (err) {
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause: ${JSON.stringify(err)}`);
        return;
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        ItemGroup() {
          SubItemArrow({
            title: $r('app.string.NFC'),
            tag: $r('app.string.disabled')
          })
            .onClick(() => {
              this.pathInfos.pushPath({ name: 'Nfc' });
              this.selectedLabel = 'MORE_CONNECTIONS';
            })
        }
      }
      .padding({ left: 12, right: 12 })
    }
    .title(this.itemTitle)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}