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

import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { HashMap, HashSet } from '@kit.ArkTS';
import { ViewItem } from '../data/ViewItem';

// [Start builder_node_pool]
// 继承NodeController，创建可以复用的子组件
export class NodeItem extends NodeController {
  // [StartExclude builder_node_pool]
  public builder: WrappedBuilder<ESObject> | null = null;
  public node: BuilderNode<ESObject> | null = null;
  public data: ESObject = {};
  // Sub component type, when reused, the corresponding sub component will be searched for and used based on the type
  public type: string = '';
  public id: number = 0;

  aboutToDisappear(): void {
    // Recycle components to the reuse pool when the page is destroyed
    NodePool.getInstance().recycleNode(this.type, this);
  }

  update(data: ESObject) {
    this.data = data;
    this.node?.reuse(data);
  }

  // Create nodes
  makeNode(uiContext: UIContext): FrameNode | null {
    if (!this.node) {
      this.node = new BuilderNode(uiContext);
      this.node.build(this.builder, this.data);
    } else {
      this.update(this.data);
    }
    return this.node.getFrameNode();
  }

  // [EndExclude builder_node_pool]


  // [StartExclude builder_node_pool]
  prebuild(uiContext: UIContext) {
    this.node = new BuilderNode(uiContext);
    this.node.build(this.builder, this.data);
  }
}

// Global Component Reuse Pool
export class NodePool {
  // [StartExclude builder_node_pool]
  private static instance: NodePool;
  private idGen: number;
  private nodePool: HashMap<string, Array<NodeItem>>;

  private constructor() {
    this.nodePool = new HashMap();
    this.idGen = 0;
  }

  // Using singleton mode for global management of component reuse pool
  public static getInstance() {
    if (!NodePool.instance) {
      NodePool.instance = new NodePool();
    }
    return NodePool.instance;
  }

  // Get component ID
  public getNextId(): number {
    this.idGen += 1;
    return this.idGen;
  }

  // Retrieve sub components based on type, reuse them directly if available, and create new sub components if not available
  public getNode(type: string, item: ESObject, itemColor: Color,
    builder: WrappedBuilder<ESObject>): NodeItem | undefined {
    let nodeItem: NodeItem | undefined = this.nodePool.get(type)?.pop();
    if (!nodeItem) {
      nodeItem = new NodeItem();
      nodeItem.builder = builder;
      nodeItem.data.data = item;
      nodeItem.type = type;
      nodeItem.data.itemColor = itemColor;
    } else {
      nodeItem.data.data = item;
      nodeItem.data.itemColor = itemColor;
    }
    return nodeItem;
  }

  // [EndExclude builder_node_pool]

  public preBuild(type: string, item: ESObject, builder: WrappedBuilder<ESObject>, uiContext: UIContext) {
    if (type) {
      let nodeItem: NodeItem | undefined = new NodeItem();
      nodeItem.builder = builder;
      nodeItem.data.data = item;
      nodeItem.type = type;
      // Pre created components
      nodeItem.prebuild(uiContext);
      // Recycle pre created components into the reuse pool for future reuse
      this.recycleNode(type, nodeItem);
    }
  }

  // [StartExclude builder_node_pool]

  // Recycle sub components into the reuse pool
  public recycleNode(type: string, node: NodeItem) {
    let nodeArray: Array<NodeItem> = this.nodePool.get(type);
    if (!nodeArray) {
      nodeArray = new Array<NodeItem>();
      this.nodePool.set(type, nodeArray);
    }
    nodeArray.push(node);
  }

  // [EndExclude builder_node_pool]
}

// [End builder_node_pool]