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

import { webview } from '@kit.ArkWeb';
import { UIContext, NodeController, BuilderNode, FrameNode } from '@kit.ArkUI';
import { Constants } from '../common/Constants';

class Data {
  url: string = Constants.WEB_URL;
  controller: WebviewController = new webview.WebviewController();
}

@Builder
function WebBuilder(data: Data) {
  Column() {
    Web({ src: data.url, controller: data.controller })
      .width($r('app.string.full_height_width'))
      .height($r('app.string.full_height_width'))
      .domStorageAccess(true)
  }
}

let wrap = wrapBuilder<Data[]>(WebBuilder);

export class MyNodeController extends NodeController {
  private rootNode: BuilderNode<Data[]> | null = null;

  makeNode(_uiContext: UIContext): FrameNode | null {
    if (this.rootNode !== null) {
      return this.rootNode.getFrameNode();
    }
    return null;
  }

  initWeb(url: string, uiContext: UIContext, control: WebviewController) {
    if (this.rootNode != null) {
      return;
    }
    this.rootNode = new BuilderNode(uiContext);
    this.rootNode.build(wrap, { url: url, controller: control });
  }
}

let NodeMap: Map<string, MyNodeController | undefined> = new Map();

let controllerMap: Map<string, WebviewController | undefined> = new Map();

export const createNWeb = (url: string, uiContext: UIContext) => {
  let baseNode = new MyNodeController();
  let controller = new webview.WebviewController();
  baseNode.initWeb(url, uiContext, controller);
  controllerMap.set(url, controller)
  NodeMap.set(url, baseNode);
}

export const getNWeb = (url: string): MyNodeController | undefined => {
  return NodeMap.get(url);
}