/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

// [Start home_page]
import { Logger } from '@ohos/common/Index';
import { Nfc, SettingList, WlanMoreSetting } from '@ohos/settingItems';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let storage: LocalStorage | undefined = uiContext!.getSharedLocalStorage();
const TAG = "homePage"

@Entry(storage)
@Component
struct Index {
  @LocalStorageProp('currentBreakpoint') curBp: string = 'sm';
  @LocalStorageProp('windowWidth') windowWidth: number = 300;
  @LocalStorageProp('isSplitMode') isSplitMode: boolean = false;
  @Provide('pathInfos') pathStack: NavPathStack = new NavPathStack();
  @State itemTitle: string = '';

  aboutToAppear() {
    try {
      this.itemTitle = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.settings').id)
    } catch (err) {
      if (err.code) {
        Logger.error(TAG, `Failed to get item name. Cause: ${JSON.stringify(err)}`);
        return;
      }
    }
  }

  build() {
    Navigation(this.pathStack) {
      SettingList()
    }
    .title(this.itemTitle)
    .mode(this.curBp !== 'sm' ? NavigationMode.Split : NavigationMode.Stack)
    .navBarWidth(0.4 * this.windowWidth)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
// [End home_page]