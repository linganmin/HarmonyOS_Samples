/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { getString, getStringArray } from '@ohos/common';
import { MainItem } from '../components/MainItem';

@Component
export struct MenuList {
  @StorageLink('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State menuListData: Array<string> = [];
  public menuList?: Resource = undefined;

  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r("app.color.divider"))
      .margin({
        left: 16,
        right: 16
      })
  }

  build() {
    List() {
      ListItem() {
        Column() {
          ForEach(this.menuListData, (item: string, index: number) => {
            if (index > 0) {
              this.CustomDivider();
            }
            MainItem({
              title: item
            })
              .onClick(() => {
                if (item === getString(this.getUIContext(), $r('app.string.battery_info'))) {
                  this.pageStack.pushPathByName('BatteryInfo', null, null);
                } else if (item === getString(this.getUIContext(), $r('app.string.running_lock'))) {
                  this.pageStack.pushPathByName('RunningLockManager', null, null);
                } else if (item === getString(this.getUIContext(), $r('app.string.power_manager'))) {
                  this.pageStack.pushPathByName('PowerManager', null, null);
                } else if (item === getString(this.getUIContext(), $r('app.string.settings'))) {
                  this.pageStack.pushPathByName('SettingsManager', null, null);
                } else if (item === getString(this.getUIContext(), $r('app.string.thermal'))) {
                  this.pageStack.pushPathByName('Thermal', null, null);
                } else if (item === getString(this.getUIContext(), $r('app.string.usb_manager'))) {
                  this.pageStack.pushPathByName('UsbManager', null, null);
                }
              })

          }, (item: string) => JSON.stringify(item))
        }
      }
    }
    .borderRadius(20)
    .width('100%')
    .scrollBar(BarState.Off)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  aboutToAppear() {
    this.getData();
  }

  getData = async () => {
    if (this.menuList) {
      this.menuListData = await getStringArray(this.getUIContext(), this.menuList);
    }
  }
}