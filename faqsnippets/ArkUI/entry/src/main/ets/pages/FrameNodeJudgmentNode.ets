/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ: FrameNode的isAttached接口是否可以判断FrameNode节点出现在屏幕上?
*/

// [Start frame_node_judgment_node]
import { FrameNode, NodeController, UIContext } from '@kit.ArkUI';

class MyNodeController extends NodeController {
  rootNode: FrameNode | null = null;
  node1: FrameNode | null = null;
  node2: FrameNode | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    this.rootNode = new FrameNode(uiContext);
    this.node1 = new FrameNode(uiContext);
    this.node1.commonAttribute.id('node1'); // Set id
    this.node2 = new FrameNode(uiContext);
    this.node2.commonAttribute.id('node2'); // Set id
    this.rootNode.appendChild(this.node1); // Node1 on the main tree, node2 not on the main tree.
    return this.rootNode;
  }
}

@Entry
@Component
struct Index {
  myNodeController: MyNodeController = new MyNodeController();

  build() {
    Column() {
      NodeContainer(this.myNodeController)
      Button('Click')
        .onClick(() => {
          // If the node cannot be obtained through getAttachedFrameNodeById, it indicates that the node has not been mounted to the main tree.
          console.info(`node1 is attached to main tree: ${(this.getUIContext().getAttachedFrameNodeById('node1') !==
            null)}`);
          console.info(`node2 is attached to main tree: ${(this.getUIContext().getAttachedFrameNodeById('node2') !==
            null)}`);
        })
    }
  }
}

// [End frame_node_judgment_node]