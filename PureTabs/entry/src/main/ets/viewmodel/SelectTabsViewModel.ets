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

import TabItemViewModel from "./TabItemViewModel";
import SelectTabsModel from "../model/SelectTabsModel";

// [Start select_tabs_1]
@Observed
class TabItemArray extends Array<TabItemViewModel> {
}

@Observed
export default class SelectTabsViewModel {
  allTabs: TabItemArray = new TabItemArray();
  selectedTabs: TabItemArray = new TabItemArray();
  // [StartExclude select_tabs_1]
  private selectTabsModel: SelectTabsModel = new SelectTabsModel();
  // [EndExclude select_tabs_1]

  async loadTabs(ctx: Context) {
    // [StartExclude select_tabs_1]
    await this.selectTabsModel.loadAllTabs(ctx);

    let tempTabs: TabItemViewModel[] = [];
    for (let tab of this.selectTabsModel.allTabs) {
      let tabItemViewModel = new TabItemViewModel();
      tabItemViewModel.updateTab(tab);
      tempTabs.push(tabItemViewModel);
    }
    this.allTabs = tempTabs;

    this.updateSelectedTabs();
    // [EndExclude select_tabs_1]
  }

  // apply changes to the selected tabs
  updateSelectedTabs() {
    let tempTabs: TabItemViewModel[] = [];
    for (let tab of this.allTabs) {
      if (tab.isChecked) {
        tempTabs.push(tab);
      }
    }
    this.selectedTabs = tempTabs;
  }
}
// [End select_tabs_1]