/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { ViewItem } from '../data/ViewItem';
import { NodeItem, NodePool } from '../utils/BuilderNodePool';

@Builder
export function flowItemBuilder(data: ESObject) {
  SubFlowItem({
    data: data.data,
    itemColor: data.itemColor
  })
}

// 自定义组件复用池瀑布流子组件
@Component
export struct FlowItemNode {
  @State type: string = '';
  @State data: ViewItem = new ViewItem();
  @State itemHeight: number = 0;
  @State itemColor: Color = 0;
  @State builder: WrappedBuilder<ESObject> | null = null;
  private nodeItem: NodeItem = new NodeItem();

  aboutToAppear(): void {
    this.nodeItem = NodePool.getInstance().getNode(this.type, this.data, this.itemColor, this.builder!)!;
  }

  aboutToReuse(params: ESObject): void {
    this.nodeItem.node?.reuse(params);
  }

  build() {
    NodeContainer(this.nodeItem)
  }
}

@Component
export struct SubFlowItem {
  @Prop data: ViewItem;
  @Prop itemColor: Color = 0;

  aboutToReuse(params: ESObject): void {
    this.data = params.data;
    this.itemColor = params.itemColor;
  }

  build() {
    Column() {
      Image(this.data?.image)
        .width('100%')
        .borderRadius({
          topLeft: 10,
          topRight: 10
        })
      Text(this.data?.name)
        .fontSize(14)
        .fontColor(Color.Black)
        .margin({
          top: 10
        })
      Text(this.data?.des)
        .fontSize(12)
        .fontColor(Color.Grey)
    }
    .borderRadius(10)
    .backgroundColor(this.itemColor)
  }
}