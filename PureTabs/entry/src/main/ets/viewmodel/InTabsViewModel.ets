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

import ContentItemViewModel from "./ContentItemViewModel";
import InTabsModel from "../model/InTabsModel";

@Observed
class ContentItemArray extends Array<ContentItemViewModel> {
}

@Observed
export default class InTabsViewModel {
  private inTabsModel: InTabsModel = new InTabsModel();
  contentItems: ContentItemArray = new ContentItemArray();

  async loadContentData(ctx: Context) {
    await this.inTabsModel.loadContentItems(ctx);

    let tempItems: ContentItemArray = [];
    for (let item of this.inTabsModel.contentItems) {
      let contentItemViewModel = new ContentItemViewModel();
      contentItemViewModel.updateContentItem(item);
      tempItems.push(contentItemViewModel);
    }
    this.contentItems = tempItems;
  }
}
