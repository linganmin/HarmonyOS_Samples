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
 *
 */

import { DiffListItemNode } from './DiffListItemNode';
import { ItemData } from '../model/ItemData';
import { genMockItemData } from '../common/MockData';
import { listItemBuilder } from './DiffListItemView';
import { ItemDataSource } from '../model/ItemDataSource';

const REUSE_VIEW_TYPE_ITEM: string = 'reuse_type_';

// [Start node5]
// wrapBuilder the list item view component
export const listItemWrapper: WrappedBuilder<ESObject> = wrapBuilder<ESObject>(listItemBuilder);

// The list component in the swiper
@Component
export struct TabContentView {
  // [StartExclude node5]
  minSize: number = 80;
  maxSize: number = 180;
  fontSize: number = 24;
  @State index: number = 0;
  dataSource: ItemDataSource = new ItemDataSource();

  aboutToAppear(): void {
    this.dataSource.addItems(genMockItemData(1000));
  }

  fillNewData(item: ItemData) {
    this.dataSource.addLastItem(item);
  }
  // [EndExclude node5]

  build() {
    List() {
      LazyForEach(this.dataSource, (item: ItemData) => {
        DiffListItemNode({
          type: REUSE_VIEW_TYPE_ITEM,
          item: item,
          builder: listItemWrapper
        })
      }, (item: ItemData) => item.id.toString())
    }
    // [StartExclude node5]
    .padding({ bottom: 24 })
    .contentEndOffset(24)
    .width('100%')
    .height('100%')
    .cachedCount(1)
    .id("id_custom_reusable_pool_list")
    // [EndExclude node5]
  }
}
// [End node5]