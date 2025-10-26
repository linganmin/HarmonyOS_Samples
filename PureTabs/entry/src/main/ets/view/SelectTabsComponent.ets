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

import { Constants } from "../common/constant/Constants";
import SelectTabsViewModel from "../viewmodel/SelectTabsViewModel"
import TabItemViewModel from "../viewmodel/TabItemViewModel";

// [Start select_tabs_5]
@Component
export default struct SelectTabsComponent {
  @State checkedChange: boolean = false;
  @Link selectTabsViewModel: SelectTabsViewModel;

  build() {
    Grid() {
      ForEach(this.selectTabsViewModel.allTabs, (tab: TabItemViewModel) => {
        GridItem() {
          Row() {
            Toggle({ type: ToggleType.Button, isOn: tab.isChecked }) {
              // [StartExclude select_tabs_5]
              if (this.checkedChange) {
                Text(tab.name)
                  .fontColor(tab.isChecked ? Color.White : $r('app.color.in_tab_bar_text_normal_color'))
                  .fontSize(14)
              } else {
                Text(tab.name)
                  .fontColor(tab.isChecked ? Color.White : $r('app.color.in_tab_bar_text_normal_color'))
                  .fontSize(14)
              }
              // [EndExclude select_tabs_5]
            }
            // [StartExclude select_tabs_5]
            .width($r('app.integer.in_tab_bar_width'))
            .borderRadius(20)
            .height(40)
            .margin({
              left: 4,
              right: 4,
              top: 10,
              bottom: 10
            })
            .padding({ left: 12, right: 12 })
            .selectedColor($r('app.color.in_tab_bar_background_active_color'))
            // [EndExclude select_tabs_5]
            .onChange((isOn: boolean) => {
              tab.isChecked = isOn;
              this.checkedChange = !this.checkedChange;
            })
          }
        }
      }, (tab: TabItemViewModel, index: number) => index + '_' + JSON.stringify(tab))
    }
    .columnsTemplate(('1fr 1fr 1fr 1fr') as string)
    .height(Constants.FULL_HEIGHT)
  }
}
// [End select_tabs_5]