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

import WordViewModel from "../viewModel/WordViewModel";
import { WordCellData } from "./WordGridComponent";

// [Start show_data]
// item component
@Component
export default struct WordCell {
  @State word: WordViewModel = new WordViewModel();

  aboutToReuse(params: Record<string, ESObject>) {
    let input = params as WordCellData;
    this.word = input.word;
  }

  build() {
    // [StartExclude show_data]
    if (this.word.value === 'N 6') {
      Text(this.word.value)
        .height(120)
        .backgroundColor(Color.Gray)
    } else {
      // [EndExclude show_data]
      // define a text component that displays data in a cell after receiving it.
      Text(this.word.value)
        .height(80)
      // [StartExclude show_data]
    }
    // [EndExclude show_data]
  }
}
// [End show_data]