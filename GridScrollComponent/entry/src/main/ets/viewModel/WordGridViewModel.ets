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

import { GridManager } from "@hadss/scroll_components";
import WordModel from "../model/WordModel";
import WordViewModel from "./WordViewModel";

// [Start set_data_and_render_grid]
@Observed
export default class WordGridViewModel {
  @Track data: WordViewModel[] = [];
  gridViewManager?: GridManager;
  // [StartExclude set_data_and_render_grid]

  constructor(gridViewManager: GridManager) {
    this.gridViewManager = gridViewManager;
  }
  // [EndExclude set_data_and_render_grid]

  async loadData() {
    // simulated request data.
    for (let index = 0; index < 15; index++) {
      let viewModel: WordViewModel = new WordViewModel();
      // [StartExclude set_data_and_render_grid]
      let model: WordModel = new WordModel();
      model.value = `N ${index}`;
      viewModel.updateModel(model);
      // [EndExclude set_data_and_render_grid]
      this.data.push(viewModel);
    }
    this.gridViewManager?.setDataSource(this.data);
  }
}
// [End set_data_and_render_grid]