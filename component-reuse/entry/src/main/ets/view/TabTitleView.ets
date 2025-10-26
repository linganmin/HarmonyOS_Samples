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

import { ChipSize, ChipGroup, ChipGroupItemOptions, } from '@kit.ArkUI';

@Component
export struct TabTitleView {
  @Prop selectedIndex: number;
  @State titleOptions: ChipGroupItemOptions[] = [];
  titles: string[] = [];
  selectListener: ((selectedIndex: number) => void) = () => {
  };

  aboutToAppear(): void {
    for (let i = 0; i < this.titles.length; i++) {
      const opt: ChipGroupItemOptions = { label: { text: this.titles[i] } };
      this.titleOptions.push(opt);
    }
  }

  build() {
    Column() {
      ChipGroup({
        items: this.titleOptions,
        itemStyle: {
          size: ChipSize.NORMAL,
          backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
          fontColor: $r('sys.color.ohos_id_color_text_primary'),
          selectedBackgroundColor: $r('sys.color.ohos_id_color_emphasize'),
          selectedFontColor: $r('sys.color.ohos_id_color_text_primary_contrary'),
        },
        selectedIndexes: [this.selectedIndex],
        multiple: false,
        chipGroupSpace: { itemSpace: 10 },
        chipGroupPadding: { top: 10, bottom: 10 },
        onChange: (activatedChipsIndex: Array<number>) => {
          this.selectListener(activatedChipsIndex[0]);
        }
      })
    }
  }
}
