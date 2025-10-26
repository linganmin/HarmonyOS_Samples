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
import { generateRandomImages } from "../model/mock";
import WorkModel from "../model/WorkModel";
import WorkViewModel from "./WorkViewModel";

// [Start refresh]
// [Start load_more]
// [Start drag]
@Observed
export default class WorkGridViewModel {
  // [StartExclude refresh]
  // [StartExclude load_more]
  // [StartExclude drag]
  @Track data: WorkViewModel[] = [];
  @Track worksCount: number = 72;
  // [EndExclude refresh]
  @Track isRefresh: boolean = false;
  // [StartExclude refresh]
  @Track refreshOffset: number = 0;
  @Track refreshState: RefreshStatus = RefreshStatus.Inactive;
  // [EndExclude load_more]
  @Track isLoading = false;
  // [EndExclude refresh]
  // [EndExclude drag]
  gridViewManager?: GridManager;

  // [StartExclude drag]
  // [StartExclude load_more]
  constructor(gridViewManager: GridManager) {
    this.gridViewManager = gridViewManager;
  }

  loadData() {
    // [StartExclude refresh]
    let lastLength = this.data.length;
    for (let index = 0; index < 20; index++) {
      let model = this.generateData();
      this.data.push(model);
    }
    // [EndExclude refresh]
    // refresh data source
    this.gridViewManager?.nodeAdapter.deleteData(0, lastLength);
    this.gridViewManager?.setDataSource(this.data);
  }

  /**
   * refresh display data
   */
  refreshData() {
    setTimeout(() => {
      this.loadData();
      this.isRefresh = false;
    }, 1000);
  }
  // [StartExclude refresh]

  // [EndExclude load_more]
  /**
   * mock load more data when reach end
   */
  loadMore() {
    if (this.worksCount <= this.data.length) {
      return;
    }
    this.isLoading = true;

    setTimeout(() => {
      if (this.worksCount > this.data.length) {
        for (let index = 0; index < 20; index++) {
          if (this.data.length + index < this.worksCount) {
            this.gridViewManager?.nodeAdapter.pushData([this.generateData()]);
            this.isLoading = false;
          }
        }
      }
      this.isLoading = false;
    }, 500);
  }

  // [StartExclude load_more]
  /**
   * get data by index
   *
   * @param index search index
   * @returns search result
   */
  getItemData(index: number): WorkViewModel {
    return this.data[index];
  }

  // [EndExclude drag]
  /**
   * move work index
   *
   * @param fromIndex source index
   * @param toIndex target index
   */
  move(fromIndex: number, toIndex: number) {
    if (toIndex >= this.data.length) {
      return;
    }
    this.gridViewManager?.nodeAdapter.moveData(fromIndex, toIndex);
  }
  // [StartExclude drag]

  // [EndExclude load_more]
  /**
   * generate mock Work
   *
   * @returns work data
   */
  generateData(): WorkViewModel {
    // [StartExclude load_more]
    let work: WorkModel = new WorkModel();
    let random: number = Math.random();
    if (random < 0.3) {
      work.type = 'picture';
    } else {
      work.type = 'video';
    }

    work.coverImage = generateRandomImages()[0];
    work.likeCount = 100 + Math.floor(random * 1000);

    let viewModel = new WorkViewModel();
    viewModel.updateModel(work);
    return viewModel;
    // [EndExclude load_more]
  }
  // [EndExclude refresh]
  // [EndExclude drag]
}
// [End drag]
// [End refresh]
// [End load_more]