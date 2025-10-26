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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BuilderNode, FrameNode, NodeController, Size } from '@kit.ArkUI';
import { VideoNode } from './VideoNode';

interface Params {
  videoSrc: string;
  xComponentId: string;
  isPlaying: boolean;
}

@Builder
function buttonBuilder(params: Params) {
  VideoNode({ videoSrc: params.videoSrc, xComponentId: params.xComponentId, isPlaying: params.isPlaying })
}

// [Start MyNodeController_start]
export class MyNodeController extends NodeController {
  // [StartExclude MyNodeController_start]
  private buttonNode: BuilderNode<[Params]> | null = null;
  private wrapBuilder: WrappedBuilder<[Params]> = wrapBuilder(buttonBuilder);
  private videoSrc: string;
  private xComponentId: string;
  private isPlaying?: boolean = false;

  constructor(videoSrc: string, xComponentId: string, isPlaying: boolean | undefined = false) {
    super();
    this.videoSrc = videoSrc;
    this.xComponentId = xComponentId;
    this.isPlaying = isPlaying;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.buttonNode === null) {
      this.buttonNode = new BuilderNode(uiContext);
      this.buttonNode.build(this.wrapBuilder,
        { videoSrc: this.videoSrc, xComponentId: this.xComponentId, isPlaying: this.isPlaying })
    }
    return this.buttonNode!.getFrameNode()!;
  }


  getNode(): BuilderNode<[Params]> | null {
    return this.buttonNode;
  }

  setNode(node: BuilderNode<[Params]> | null) {
    this.buttonNode = node;
    this.rebuild();
  }

  aboutToResize(size: Size) {
    hilog.info(0x0000, 'TAG', 'aboutToResize width : ' + size.width + ' height : ' + size.height);
  }

  aboutToAppear() {
    hilog.info(0x0000, 'TAG', 'aboutToAppear');
  }

  aboutToDisappear() {
    hilog.info(0x0000, 'TAG', 'aboutToDisappear');
  }

  onTouchEvent(_event: TouchEvent) {
    hilog.info(0x0000, 'TAG', 'onTouchEvent');
  }

  init(uiContext: UIContext) {
    this.buttonNode = new BuilderNode(uiContext);
    this.buttonNode.build(this.wrapBuilder,
      { videoSrc: this.videoSrc, xComponentId: this.xComponentId, isPlaying: this.isPlaying });
  }

  update(isPlaying: boolean) {
    if (this.buttonNode !== null) {
      this.buttonNode.update({ isPlaying });
    }
  }

  // [EndExclude MyNodeController_start]
}

// [End MyNodeController_start]

let instances: Record<string, MyNodeController | undefined> = {};

export const createMyNode =
  (uiContext: UIContext, videoSrc: string, xComponentId: string, isPlaying: boolean | undefined = false) => {
    const myNode = new MyNodeController(videoSrc, xComponentId, isPlaying);
    myNode.init(uiContext);
    instances[xComponentId] = myNode;
  };

export const getMyNode = (xComponentId: string): MyNodeController | undefined => {
  return instances[xComponentId];
};

export const updateMyNode = (isPlaying: boolean, xComponentId: string) => {
  instances[xComponentId]?.update(isPlaying);
};