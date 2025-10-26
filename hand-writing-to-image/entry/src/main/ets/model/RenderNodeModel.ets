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

import { DrawContext, FrameNode, NodeController, RenderNode, Size } from '@kit.ArkUI';
import { common2D, drawing } from '@kit.ArkGraphics2D';

/**
 * MyRenderNode class, initialize brush and draw path.
 */
export class MyRenderNode extends RenderNode {
  path: drawing.Path = new drawing.Path();
  draw(context: DrawContext): void {
    const canvas = context.canvas;
    const pen = new drawing.Pen();
    pen.setAntiAlias(true);
    const pen_color: common2D.Color = {
      alpha: 0xFF,
      red: 0x00,
      green: 0x00,
      blue: 0x00
    };
    pen.setColor(pen_color);
    pen.setDither(true);
    pen.setStrokeWidth(5);
    canvas.attachPen(pen);
    canvas.drawPath(this.path);
  }
}

/**
 * NodeController subclass MyNodeController.
 */
export class MyNodeController extends NodeController {
  private rootNode: FrameNode | null = null;
  rootRenderNode: RenderNode | null = null;
  width: number = 0;
  height: number = 0;

  makeNode(uiContext: UIContext): FrameNode {
    this.rootNode = new FrameNode(uiContext);
    if (this.rootNode !== null) {
      this.rootRenderNode = this.rootNode.getRenderNode();
    }
    return this.rootNode;
  }

  aboutToResize(size: Size): void {
    this.width = size.width;
    this.height = size.height;
    if (this.rootRenderNode !== null) {
      this.rootRenderNode.backgroundColor = 0XFFFFFFFF;
      this.rootRenderNode.frame = {
        x: 0,
        y: 0,
        width: this.width,
        height: this.height
      };
    }
  }
}