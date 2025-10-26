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

import { ListManager } from '@hadss/scroll_components';
import { BlogData } from "../model/types";

// [Start Pull_Refresh_VM]
// [Start Load_More_VM]
@Observed
export class DifferentItemViewModel {
  // [StartExclude Load_More_VM]
  @Track dataArray: BlogData[] = [];
  myListManager: ListManager;
  // [StartExclude Pull_Refresh_VM]
  private NetworkTime: number = 200;
  // [EndExclude Load_More_VM]
  private isLoadingMore: boolean = false;
  // [StartExclude Load_More_VM]

  constructor(myListManager: ListManager, dataArray: BlogData[]) {
    this.myListManager = myListManager;
    this.dataArray = dataArray;
  }

  // [EndExclude Pull_Refresh_VM]
  loadData(callBack?: (isSuccess: boolean) => void): void {
    generateRandomBlogData().then((data: BlogData[]) => {
      this.dataArray = data;
      this.myListManager.setDataSource(data);
      if (callBack) {
        callBack(true);
      }
    });
  }
  // [StartExclude Pull_Refresh_VM]
  // [EndExclude Load_More_VM]
  loadDataMore(callBack?: (isSuccess: boolean) => void): void {
    if (!this.isLoadingMore) {
      this.isLoadingMore = true;
      setTimeout(() => {
        generateRandomBlogData().then((data: BlogData[]) => {
          this.myListManager.nodeAdapter.pushData(data);
          this.isLoadingMore = false;
          if (callBack) {
            callBack(true);
          }
        })
      }, this.NetworkTime);
    }
  }
  // [EndExclude Pull_Refresh_VM]
}

// [End Pull_Refresh_VM]
// [End Load_More_VM]

@Concurrent
async function generateRandomBlogData(count?: number): Promise<BlogData[]> {
  const module = await import('../model/mock');
  return module.generateRandomBlogData(count ?? 20, true, false);
}