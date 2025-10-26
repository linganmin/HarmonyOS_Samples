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

import { GridManager, NodeItem, RecyclerView } from "@hadss/scroll_components";
import NumberGridViewModel from "../viewModel/NumberGridViewModel";
import NumberViewModel from "../viewModel/NumberViewModel";
import { NumberCell } from "./NumberCellComponent";

@Component
export struct NumberGridComponent {
  gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: "number", context: this.getUIContext() })
  showNumbers: NumberGridViewModel = new NumberGridViewModel(this.gridViewManager);

  // [Start adaptive]
  aboutToAppear() {
    this.gridViewManager.setViewStyle()
      .width("90%")
      .columnsGap(10)
      .rowsGap(5)
      .maxCount(10)
      .minCount(2)
      .cellLength(0)
      .border({ color: Color.Black, width: 1 });

    // [StartExclude adaptive]
    this.gridViewManager.setItemViewStyle((gridItem) => {
      gridItem()
        .backgroundColor('#0A59F7');
    });

    this.gridViewManager.registerNodeItem('number', wrapBuilder(buildNumber))

    this.showNumbers.loadNumbers();
    // [EndExclude adaptive]
  }
  // [End adaptive]

  build() {
    Column() {
      RecyclerView({
        viewManager: this.gridViewManager
      })
    }
    .width('100%')
  }
}

@Builder
function buildNumber(data: NumberCellData) {
  NumberCell({ data: data.data })
}

class GridViewManager extends GridManager {
  onWillCreateItem(index: number, data: NumberViewModel) {
    let node: NodeItem<NumberCellData> | null = this.dequeueReusableNodeByType('number');
    node.setData({ data: data })
    return node;
  }
}

export interface NumberCellData {
  data: NumberViewModel;
}