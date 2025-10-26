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

import { MenuList } from '@ohos/menuitems';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @StorageProp('windowWidth') windowWidth: number = 300;
  @StorageProp('isSplitMode') isSplitMode: boolean = false;
  @StorageLink('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State title: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear() {
    try {
      this.title = this.context.resourceManager.getStringSync($r('app.string.device_management').id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'xxx', `getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        MenuList({ menuList: $r('app.strarray.device_management_list') })
      }
      .padding(16)
    }
    .title(this.title)
    .mode(this.isSplitMode ? NavigationMode.Split : NavigationMode.Stack)
    .navBarWidth(0.4 * this.windowWidth)
    .titleMode(NavigationTitleMode.Full)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.list_background'))
  }
}