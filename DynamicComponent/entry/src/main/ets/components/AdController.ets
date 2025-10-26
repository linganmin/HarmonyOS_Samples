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

import { UIContext, NodeController, BuilderNode, FrameNode } from '@kit.ArkUI';
import { AdParams } from '../model/AdParams';
import { adBuilder } from './AdBuilder';

// Saves the NodeController required for creating the Map.
export let nodeMap: Map<string, AdNodeController | undefined> = new Map();

// [Start AdNodeController_start]
export class AdNodeController extends NodeController {
  private rootNode: FrameNode | null = null;
  private adNode: BuilderNode<[AdParams]> | null = null;
  private isRemove: boolean = false;
  private uiContext ?: UIContext;

  makeNode(): FrameNode | null {
    if (this.isRemove) {
      return null;
    }
    if (this.rootNode != null) {
      return this.rootNode;
    }
    return null;
  }

  // This function is user-defined and can be used as an initialization function.
  // Initialize BuilderNode through UIContext, and then initialize the content
  // in @Builder through the build interface in BuilderNode.
  initAd(uiContext: UIContext, id: string, adType: string) {
    this.uiContext = uiContext;
    // uiContext is required for creating a node.
    this.rootNode = new FrameNode(this.uiContext);
    // uiContext is required for creating a node.
    this.adNode = new BuilderNode(this.uiContext);
    this.adNode.build(wrapBuilder(adBuilder), { id: id, isVideo: adType === 'video' });
    this.rootNode.getRenderNode()?.appendChild(this.adNode.getFrameNode()?.getRenderNode());
  }

  remove() {
    this.isRemove = true;
  }
}
// [End AdNodeController_start]

// [Start getAdNodeController_start]
// Customizing the Interface for Obtaining the NodeController
export const getAdNodeController = (uiContext: UIContext, id: string): AdNodeController | undefined => {
  let baseNode = new AdNodeController();
  nodeMap.set(id, baseNode);
  baseNode.initAd(uiContext, id, queryAdById(id));
  return nodeMap.get(id);
}

function queryAdById(id: string): string {
  if (Number(id) % 2 === 0) {
    return 'pic';
  } else {
    return 'video';
  }
}
// [End getAdNodeController_start]