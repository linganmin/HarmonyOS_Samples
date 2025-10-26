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

// [Start quick_start_3_vm]
@Observed
export class SameItemViewModel {
  @Track dataArray: BlogData[] = [];
  myListManager: ListManager;
  // [StartExclude quick_start_3_vm]
  private NetworkTime: number = 200;

  constructor(myListManager: ListManager) {
    this.myListManager = myListManager;
  }

  // [EndExclude quick_start_3_vm]
  loadData() {
    generateRandomBlogData(300, false).then((dataArray: BlogData[]) => {
      this.dataArray = dataArray;
      this.myListManager.setDataSource(dataArray);
    });
  }
  // [StartExclude quick_start_3_vm]

  loadDataMore() {
    setTimeout(() => {
      generateRandomBlogData().then((data: BlogData[]) => {
        this.myListManager.nodeAdapter.pushData(data);
      });
    }, this.NetworkTime);
  }

  deleteDataRequest(_data: BlogData, callBack?: (isSuccess: boolean) => void): void {
    // The simulated deleteData was successful
    setTimeout(() => {
      if (callBack) {
        callBack(true);
      }
    }, this.NetworkTime);
  }

  deleteData(data: BlogData) {
    let index = this.dataArray.indexOf(data);
    if (index !== -1) {
      this.myListManager.nodeAdapter.deleteData(index);
    }
  }

  collectionData(_data: BlogData, callBack?: (isSuccess: boolean) => void): void {
    // The simulated collection was successful
    setTimeout(() => {
      if (callBack) {
        callBack(true);
      }
    }, this.NetworkTime);
  }
  // [EndExclude quick_start_3_vm]
}
// [End quick_start_3_vm]

@Concurrent
async function generateRandomBlogData(count?: number, contentCanNull?: boolean): Promise<BlogData[]> {
  const module = await import('../model/mock');
  return module.generateRandomBlogData(count ?? 300, true, contentCanNull ?? false);
}