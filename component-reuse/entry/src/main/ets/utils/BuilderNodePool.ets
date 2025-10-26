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

import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { HashMap, LinkedList } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// [Start prebuild1]
// [Start node1]
export class NodeItem extends NodeController {
  // [StartExclude prebuild1]
  public builder: WrappedBuilder<ESObject> | null = null;
  public node: BuilderNode<ESObject> | null = null;
  public data: ESObject = {};
  public type: string = '';
  public id: number = 0;

  aboutToDisappear(): void {
    // recycle node into cache pool when UI disappear
    NodePool.getInstance().recycleNode(this.type, this);
  }

  update(data: ESObject) {
    this.data = data;
    this.node?.reuse(data);
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    // build new node or update node in the cache
    if (!this.node) {
      this.node = new BuilderNode(uiContext);
      this.node.build(this.builder, this.data);
    } else {
      this.update(this.data);
    }
    return this.node.getFrameNode();
  }
  // [EndExclude prebuild1]

  // [StartExclude node1]
  prebuild(uiContext: UIContext) {
    this.node = new BuilderNode(uiContext);
    this.node.build(this.builder, this.data);
  }
  // [EndExclude node1]
}
// [End node1]

// [Start node2]
export class NodePool {
  // [StartExclude prebuild1]
  private static instance: NodePool;
  private idGen: number;
  private nodePool: HashMap<string, LinkedList<NodeItem>>;

  private constructor() {
    this.nodePool = new HashMap();
    this.idGen = 0;
  }

  // single instance mode, managing the cache pool
  public static getInstance() {
    if (!NodePool.instance) {
      NodePool.instance = new NodePool();
    }
    return NodePool.instance;
  }

  public getNextId(): number {
    this.idGen += 1;
    return this.idGen;
  }

  public getNode(type: string, item: ESObject,
    builder: WrappedBuilder<ESObject>): NodeItem | undefined {
    let nodeItem: NodeItem | undefined = undefined;
    try {
      // get the cached node based on type
      if (this.nodePool.get(type)) {
        for (let i = 0; i < this.nodePool.get(type)?.length; i++) {
          let tmpItem: NodeItem | undefined = this.nodePool.get(type)?.get(i);
          // if the parent node is null, it means the node is reusable, so get it out
          if (!tmpItem.node?.getFrameNode()?.getParent()) {
            nodeItem = tmpItem;
            this.nodePool.get(type)?.removeByIndex(i);
            break;
          }
        }
      }
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(DOMAIN, 'testTag', `failed code=${err.code}, message=${err.message}`);
    }

    if (!nodeItem) {
      // No valid reusable node found, so create new one
      nodeItem = new NodeItem();
      nodeItem.builder = builder;
      nodeItem.type = type;
      nodeItem.data.item = item;
    } else {
      // update cached node
      nodeItem.data.item = item;
    }
    return nodeItem;
  }

  // cache the node based on type
  public recycleNode(type: string, node: NodeItem) {
    try {
      let nodeArray: LinkedList<NodeItem> = this.nodePool.get(type);
      if (!nodeArray) {
        nodeArray = new LinkedList();
        this.nodePool.set(type, nodeArray);
      }
      // reset data
      node.data.item = {};
      nodeArray.add(node);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(DOMAIN, 'testTag', `failed code=${err.code}, message=${err.message}`);
    }
  }
  // [EndExclude prebuild1]

  // [StartExclude node2]
  public preBuild(type: string, item: ESObject, builder: WrappedBuilder<ESObject>, uiContext: UIContext) {
    if (type) {
      let nodeItem: NodeItem | undefined = new NodeItem();
      nodeItem.builder = builder;
      nodeItem.data.item = item;
      nodeItem.type = type;
      nodeItem.prebuild(uiContext);
      this.recycleNode(type, nodeItem);
    }
  }
  // [EndExclude node2]
}
// [End node2]
// [End prebuild1]