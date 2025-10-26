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

import { ItemData } from '../model/ItemData';
import { NodeItem, NodePool } from '../utils/BuilderNodePool';

// [Start node3]
// The list item placeholder component with NodeContainer
@Component
export struct DiffListItemNode {
  @State type: string = '';
  @State item: ItemData = new ItemData('', 0);
  @State itemHeight: number = 0;
  @State builder: WrappedBuilder<ESObject> | null = null;
  private nodeItem: NodeItem = new NodeItem();

  aboutToAppear(): void {
    this.nodeItem = NodePool.getInstance().getNode(this.type, this.item, this.builder!)!;
  }

  aboutToRecycle(): void {
    this.nodeItem?.node?.recycle();
  }

  aboutToReuse(params: ESObject): void {
    this.nodeItem?.node?.reuse(params);
  }

  build() {
    NodeContainer(this.nodeItem)
  }
}
// [End node3]
