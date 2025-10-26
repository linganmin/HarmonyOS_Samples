/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { NodeController, BuilderNode, FrameNode } from '@kit.ArkUI';
import * as Const from '../constant/CommonConstants';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

class Data {
  url: string = `${Const.URL}/?filename=${(uiContext?.getHostContext() as Context).resourceManager.getStringSync($r('app.string.fileName').id)}`;
  controller: WebviewController = new webview.WebviewController();
}

export interface Config {
  url: string,
  localPath: string, // local resource path
  options: webview.CacheOptions
}

@Builder
function WebBuilder(data: Data) {
  Web({ src: data.url, controller: data.controller })
}

let wrap = wrapBuilder<Data[]>(WebBuilder);

export class myNodeController extends NodeController {
  private rootnode: BuilderNode<Data[]> | null = null;
  private root: FrameNode | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootnode != null) {
      const parent = this.rootnode.getFrameNode()?.getParent();
      if (parent) {
        parent.removeChild(this.rootnode.getFrameNode());
        this.root = null;
      }
      this.root = new FrameNode(uiContext);
      this.root.appendChild(this.rootnode.getFrameNode());

      return this.root;
    }

    return null;
  }

  initWeb(url: string, uiContext: UIContext, control: WebviewController) {
    if (this.rootnode != null) {
      return;
    }
    this.rootnode = new BuilderNode(uiContext);
    this.rootnode.build(wrap, { url: url, controller: control });
  }
}

let NodeMap: Map<string, myNodeController | undefined> = new Map();
let controllerMap: Map<string, WebviewController | undefined> = new Map();

export const createNWeb = (url: string, uiContext: UIContext) => {
  let baseNode = new myNodeController();
  let controller = new webview.WebviewController();
  baseNode.initWeb(url, uiContext, controller);
  controllerMap.set(url, controller);
  NodeMap.set(url, baseNode);
}

export const getNWeb = (url: string): myNodeController | undefined => {
  return NodeMap.get(url);
}