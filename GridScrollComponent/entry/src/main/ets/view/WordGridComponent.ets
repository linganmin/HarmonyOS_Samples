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

// [Start setup_view_manager]
// [Start set_data_and_render_grid]
import { GridManager, NodeItem, RecyclerView } from "@hadss/scroll_components";
// [StartExclude setup_view_manager]
import WordGridViewModel from "../viewModel/WordGridViewModel";
import WordViewModel from "../viewModel/WordViewModel";
// [StartExclude set_data_and_render_grid]
// [Start define_same_item]
import WordCell from "./WordCellComponent";

/**
 * define item template.
 *
 * @param data data of node
 */
@Builder
function buildWordCell(data: WordCellData) {
  WordCell({ word: data.word })
}
// [EndExclude setup_view_manager]
// [EndExclude set_data_and_render_grid]

@Component
export default struct WordGridComponent {
  // [StartExclude define_same_item]
  gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: 'word', context: this.getUIContext() });
  // [StartExclude setup_view_manager]
  viewModel: WordGridViewModel = new WordGridViewModel(this.gridViewManager);

  // [EndExclude define_same_item]
  // [Start init_grid]
  // [Start adaptive_column]
  // [Start set_highest]
  aboutToAppear(): void {
    // [StartExclude define_same_item]
    // [StartExclude set_data_and_render_grid]
    // [StartExclude adaptive_column]
    this.gridViewManager.setViewStyle()
      .alignItems(GridItemAlignment.STRETCH);
    // [StartExclude set_highest]
    // [EndExclude adaptive_column]
    this.gridViewManager.setViewStyle()
      .columnsTemplate('repeat(auto-fill, 70)')
      .columnsGap(5)
      .rowsGap(5);
    // [StartExclude adaptive_column]
    // [StartExclude init_grid]
    this.gridViewManager.setViewStyle()
      .width('90%')
      .height(500)
      .border({ color: Color.Black, width: 1 });

    this.gridViewManager.setItemViewStyle((gridItem) => {
      gridItem()
        .backgroundColor('#0A59F7');
    });
    // [EndExclude set_data_and_render_grid]
    // [EndExclude define_same_item]
    // associates the builder with the identifier 'word'.
    this.gridViewManager.registerNodeItem('word', wrapBuilder(buildWordCell));
    // [StartExclude define_same_item]
    this.viewModel.loadData();
    // [EndExclude define_same_item]
    // [EndExclude init_grid]
    // [EndExclude adaptive_column]
    // [EndExclude set_highest]
  }
  // [End set_highest]
  // [End adaptive_column]
  // [End init_grid]
  // [StartExclude define_same_item]

  build() {
    Column() {
      // place the grid in a column.
      RecyclerView({
        viewManager: this.gridViewManager
      })
    }
    .width('100%')
  }
  // [EndExclude setup_view_manager]
  // [EndExclude define_same_item]
}
// [End set_data_and_render_grid]

class GridViewManager extends GridManager {
  onWillCreateItem(index: number, data: WordViewModel) {
    // get node based on identifier 'word' from recycle pool.
    let node: NodeItem<WordCellData> | null = this.dequeueReusableNodeByType('word');
    node.setData({ word: data })
    return node;
  }
}
// [End define_same_item]
// [End setup_view_manager]

export interface WordCellData {
  word: WordViewModel;
}