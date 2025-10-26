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

import { common2D, drawing } from '@kit.ArkGraphics2D';
import { NodeController, FrameNode, RenderNode, DrawContext, UIContext } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { DrawPosition, DrawState, Constants } from '../common/Constants';

/**
 * Drawing brush.
 */
let pathABrush: drawing.Brush;
let pathCBrush: drawing.Brush;

/**
 * Drawing path.
 */
let pathA: drawing.Path;
let pathC: drawing.Path;

/**
 * Coordinate point.
 */
export class MyPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

/**
 * Path point.
 */
let pointA: MyPoint = new MyPoint(-1, -1);
let pointB: MyPoint = new MyPoint(0, 0);
let pointC: MyPoint = new MyPoint(0, 0);
let pointD: MyPoint = new MyPoint(0, 0);
let pointE: MyPoint = new MyPoint(0, 0);
let pointF: MyPoint = new MyPoint(0, 0);
let pointG: MyPoint = new MyPoint(0, 0);
let pointH: MyPoint = new MyPoint(0, 0);
let pointJ: MyPoint = new MyPoint(0, 0);
let pointK: MyPoint = new MyPoint(0, 0);
let pointI: MyPoint = new MyPoint(0, 0);

/**
 * Shadow drawing auxiliary value.
 */
let lPathAShadowDis: number = 0;
let rPathAShadowDis: number = 0;

export class MyNodeController extends NodeController {
  private rootNode: FrameNode | null = null;

  /**
   * Callback when creating a NodeContainer bound to an instance, returning a node mounted to the NodeContainer.
   *
   * @param uiContext UI context.
   * @returns FrameNode object.
   */
  makeNode(uiContext: UIContext): FrameNode {
    this.rootNode = new FrameNode(uiContext);
    const renderNode = this.rootNode.getRenderNode();
    let viewWidth: number = AppStorage.get('windowWidth') as number;
    let viewHeight: number = AppStorage.get('windowHeight') as number;
    if (renderNode !== null) {
      renderNode.frame = {
        x: 0,
        y: 0,
        width: uiContext.px2vp(viewWidth),
        height: uiContext.px2vp(viewHeight)
      };
      renderNode.pivot = { x: 50, y: 50 };
    }
    return this.rootNode;
  }

  /**
   * Add self drawing rendering nodes.
   *
   * @param node Rendering nodes.
   */
  addNode(node: RenderNode): void {
    if (this.rootNode === null) {
      return;
    }
    const renderNode = this.rootNode.getRenderNode();
    if (renderNode !== null) {
      renderNode.appendChild(node);
    }
  }

  /**
   * Clear up sub nodes.
   */
  clearNodes(): void {
    if (this.rootNode === null) {
      return;
    }
    const renderNode = this.rootNode.getRenderNode();
    if (renderNode !== null) {
      renderNode.clearChildren();
    }
  }
}

// [Start emulation_3_b]
// [Start emulation_3_c]
// [Start emulation_3_d]
// [Start emulation_3_e]
// entry/src/main/ets/viewmodel/PageNodeController.ets
export class RectRenderNode extends RenderNode {
  // [StartExclude emulation_3_b]
  // [StartExclude emulation_3_c]
  // [StartExclude emulation_3_d]
  // [StartExclude emulation_3_e]
  /**
   * Execute drawing.
   *
   * @param context Graphic drawing context.
   */
  // [EndExclude emulation_3_b]
  // [EndExclude emulation_3_c]
  // [EndExclude emulation_3_d]
  // [EndExclude emulation_3_e]
  draw(context: DrawContext): void {
    const canvas = context.canvas;

    // [StartExclude emulation_3_c]
    // [StartExclude emulation_3_d]
    // [StartExclude emulation_3_e]
    // Initialize data.
    init();
    // [StartExclude emulation_3_b]
    // [EndExclude emulation_3_c]
    // Draw the shadow shown on the next page.
    drawPathBShadow(canvas);
    // [StartExclude emulation_3_c]
    // [EndExclude emulation_3_d]
    // Draw the back area for flipping pages.
    drawPathC(canvas);
    // [StartExclude emulation_3_d]
    // [EndExclude emulation_3_e]
    // Retrieve the cropped area of the current page.
    getPathA();

    // Draw the current page area.
    drawPathAContent(canvas);
    // [EndExclude emulation_3_b]
    // [EndExclude emulation_3_c]
    // [EndExclude emulation_3_d]
  }
}
// [StartExclude emulation_3_b]
// [StartExclude emulation_3_c]
// [StartExclude emulation_3_d]

/**
 * Retrieve the cropped area of the current page.
 */
function getPathA(): void {
  if (canIUse('SystemCapability.Graphics.Drawing')) {
    let viewWidth: number = AppStorage.get('windowWidth') as number;
    let viewHeight: number = AppStorage.get('windowHeight') as number;
    // Point F is located in the upper right corner, calculate pathA.
    if (pointF.x === viewWidth && pointF.y === 0) {
      pathA.reset();
      pathA.lineTo(pointC.x, pointC.y);
      pathA.quadTo(pointE.x, pointE.y, pointB.x, pointB.y);
      pathA.lineTo(pointA.x, pointA.y);
      pathA.lineTo(pointK.x, pointK.y);
      pathA.quadTo(pointH.x, pointH.y, pointJ.x, pointJ.y);
      pathA.lineTo(viewWidth, viewHeight);
      pathA.lineTo(0, viewHeight);
      pathA.close();
    }
    // Point F is located in the bottom right corner, calculate pathA.
    if (pointF.x === viewWidth && pointF.y === viewHeight) {
      pathA.reset();
      pathA.lineTo(0, viewHeight);
      pathA.lineTo(pointC.x, pointC.y);
      pathA.quadTo(pointE.x, pointE.y, pointB.x, pointB.y);
      pathA.lineTo(pointA.x, pointA.y);
      pathA.lineTo(pointK.x, pointK.y);
      pathA.quadTo(pointH.x, pointH.y, pointJ.x, pointJ.y);
      pathA.lineTo(viewWidth, 0);
      pathA.close();
    }
  }
}
// [StartExclude emulation_3_e]
/**
 * Initialize the brush and path.
 */
function initBrushAndPath(): void {
  if (canIUse('SystemCapability.Graphics.Drawing')) {
    // Init brush color.
    pathABrush = new drawing.Brush();
    pathABrush.setColor({
      alpha: 255,
      red: 255,
      green: 235,
      blue: 195
    });
    pathCBrush = new drawing.Brush();
    pathCBrush.setColor({
      alpha: 120,
      red: 186,
      green: 172,
      blue: 145
    });

    // Init path.
    pathA = new drawing.Path();
    pathC = new drawing.Path();
  }
}
// [EndExclude emulation_3_b]
/**
 * Initialize data.
 */
function init(): void {
  // [StartExclude emulation_3_b]
  initBrushAndPath();
  // [EndExclude emulation_3_b]
  // Obtain touch points.
  let x: number = AppStorage.get('positionX') as number;
  let y: number = AppStorage.get('positionY') as number;
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;
  pointA = new MyPoint(x, y);
  // [StartExclude emulation_3_b]
  if (x === -1 && y === -1) {
    return;
  }
  // [EndExclude emulation_3_b]
  let touchPoint = new MyPoint(x, y);
  let drawState: number = AppStorage.get('drawState') as number;
  let drawStartPosition: number = AppStorage.get('drawPosition') as number;

  // Determine the area where sliding begins.
  if (DrawPosition.DP_TOP === drawStartPosition) {
    // The touch point is at the top.
    pointF = new MyPoint(viewWidth, 0);
    if (drawState !== DrawState.DS_RELEASE) {
      calcPointAByTouchPoint(touchPoint);
    }
  } else if (DrawPosition.DP_BOTTOM === drawStartPosition) {
    // The touch point is below.
    pointF = new MyPoint(viewWidth, viewHeight);
    if (drawState !== DrawState.DS_RELEASE) {
      calcPointAByTouchPoint(touchPoint);
    }
  } else {
    // The touch point is in the middle.
    pointA.y = viewHeight - 1;
    pointF.x = viewWidth;
    pointF.y = viewHeight;
  }
  // Saves the y-coordinate of point A.
  AppStorage.setOrCreate<number>('flipPositionY', pointA.y);

  // Calculate all path points.
  calcPointsXY();
}

/**
 * Calculate the y-coordinate of point A based on the touch point.
 * @param touchPoint Touch point.
 */
function calcPointAByTouchPoint(touchPoint: MyPoint): void {
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;
  let r = Constants.SIXTY_PERCENT * viewWidth;
  pointA.x = touchPoint.x;

  // Reset the y value and restrict the region where the y value is located.
  if (pointF.y === viewHeight) {
    let tmpY = viewHeight - Math.abs(Math.sqrt(Math.pow(r, 2) - Math.pow(touchPoint.x - (viewWidth - r), 2)))
    pointA.y = touchPoint.y >= tmpY ? touchPoint.y : tmpY;
  } else {
    let tmpY = Math.abs(Math.sqrt(Math.pow(r, 2) - Math.pow(touchPoint.x - (viewWidth - r), 2)))
    pointA.y = touchPoint.y >= tmpY ? tmpY : touchPoint.y;
  }
}

/**
 * Calculate the coordinates of each path point.
 */
function calcPointsXY(): void {
  pointG.x = (pointA.x + pointF.x) / 2;
  pointG.y = (pointA.y + pointF.y) / 2;

  pointE.x = pointG.x - (pointF.y - pointG.y) * (pointF.y - pointG.y) / (pointF.x - pointG.x);
  pointE.y = pointF.y;

  pointH.x = pointF.x;
  pointH.y = pointG.y - (pointF.x - pointG.x) * (pointF.x - pointG.x) / (pointF.y - pointG.y);

  pointC.x = pointE.x - (pointF.x - pointE.x) / 2;
  pointC.y = pointF.y;

  pointJ.x = pointF.x;
  pointJ.y = pointH.y - (pointF.y - pointH.y) / 2;

  pointB = getIntersectionPoint(pointA, pointE, pointC, pointJ);
  pointK = getIntersectionPoint(pointA, pointH, pointC, pointJ);

  pointD.x = (pointC.x + 2 * pointE.x + pointB.x) / 4;
  pointD.y = (2 * pointE.y + pointC.y + pointB.y) / 4;

  pointI.x = (pointJ.x + 2 * pointH.x + pointK.x) / 4;
  pointI.y = (2 * pointH.y + pointJ.y + pointK.y) / 4;

  //Calculate the distance from point d to line ae and use it to draw shadows.
  let lA: number = pointA.y - pointE.y;
  let lB: number = pointE.x - pointA.x;
  let lC: number = pointA.x * pointE.y - pointE.x * pointA.y;
  lPathAShadowDis = Math.abs((lA * pointD.x + lB * pointD.y + lC) / Math.hypot(lA, lB));

  // Calculate the distance from point i to ah and use it to draw shadows.
  let rA: number = pointA.y - pointH.y;
  let rB: number = pointH.x - pointA.x;
  let rC: number = pointA.x * pointH.y - pointH.x * pointA.y;
  rPathAShadowDis = Math.abs((rA * pointI.x + rB * pointI.y + rC) / Math.hypot(rA, rB));

  // Check if the drawing area is still in the window. If it is not in the window, the drawing ends.
  if (!checkDrawingAreaInWindow()) {
    AppStorage.setOrCreate('isFinished', true);
  }
}
// [End emulation_3_b]
/**
 * Checks if the drawing area is within the window.
 * @returns isIn
 */
function checkDrawingAreaInWindow(): boolean {
  let viewHeight: number = AppStorage.get('windowHeight') as number;
  let k = (pointD.y - pointI.y) / (pointD.x - pointI.x);
  let b = (pointD.y - k * pointD.x);
  if ((pointF.y === 0 && b > viewHeight) || (pointF.y !== 0 && b < 0)) {
    return false;
  }
  return true;
}

/**
 * Calculates the coordinates of the point where two line segments intersect.
 * @param lineOne_My_pointOne line one point one
 * @param lineOne_My_pointTwo line one point two
 * @param lineTwo_My_pointOne line two point one
 * @param lineTwo_My_pointTwo line two point two
 * @return point point
 */
function getIntersectionPoint(
  lineOne_My_pointOne: MyPoint,
  lineOne_My_pointTwo: MyPoint,
  lineTwo_My_pointOne: MyPoint,
  lineTwo_My_pointTwo: MyPoint
): MyPoint {
  let x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, x4: number, y4: number;
  x1 = lineOne_My_pointOne.x;
  y1 = lineOne_My_pointOne.y;
  x2 = lineOne_My_pointTwo.x;
  y2 = lineOne_My_pointTwo.y;
  x3 = lineTwo_My_pointOne.x;
  y3 = lineTwo_My_pointOne.y;
  x4 = lineTwo_My_pointTwo.x;
  y4 = lineTwo_My_pointTwo.y;
  let pointX: number =
    ((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1)) /
      ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
  let pointY: number =
    ((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4)) /
      ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));
  return new MyPoint(pointX, pointY);
}

// [EndExclude emulation_3_d]
/**
 * Draw the back area for flipping pages.
 *
 * @param canvas canvas
 */
function drawPathC(canvas: drawing.Canvas): void {
  if (canIUse('SystemCapability.Graphics.Drawing')) {
    canvas.attachBrush(pathABrush);
    pathC.reset();
    pathC.moveTo(pointI.x, pointI.y);
    pathC.lineTo(pointD.x, pointD.y);
    pathC.lineTo(pointB.x, pointB.y);
    pathC.lineTo(pointA.x, pointA.y);
    pathC.lineTo(pointK.x, pointK.y);
    pathC.close();
    canvas.drawPath(pathC);

    // Draw the content on the back.
    canvas.save();
    canvas.clipPath(pathC);

    // Set the inversion and rotation matrices.
    let eh = Math.hypot(pointF.x - pointE.x, pointH.y - pointF.y);
    let sin0 = (pointF.x - pointE.x) / eh;
    let cos0 = (pointH.y - pointF.y) / eh;
    let value: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0, 1.0];
    value[0] = -(1 - 2 * sin0 * sin0);
    value[1] = 2 * sin0 * cos0;
    value[3] = 2 * sin0 * cos0;
    value[4] = 1 - 2 * sin0 * sin0;

    let matrix = new drawing.Matrix();
    matrix.reset();
    matrix.setMatrix(value);
    matrix.preTranslate(-pointE.x, -pointE.y);
    matrix.postTranslate(pointE.x, pointE.y);
    canvas.concatMatrix(matrix);

    // Draw the current page on the back.
    let pagePixelMap: image.PixelMap = AppStorage.get('pagePixelMap') as image.PixelMap;
    let viewWidth: number = AppStorage.get('windowWidth') as number;
    let viewHeight: number = AppStorage.get('windowHeight') as number;
    let verts: Array<number> = [0, 0, viewWidth, 0, 0, viewHeight, viewWidth, viewHeight];
    canvas.drawPixelMapMesh(pagePixelMap, 1, 1, verts, 0, null, 0);
    canvas.restore();

    // Change the color on the back.
    canvas.detachBrush();
    canvas.attachBrush(pathCBrush);
    canvas.drawPath(pathC);
    canvas.detachBrush();

    // Draw shadows in the back area.
    canvas.save();
    canvas.clipPath(pathC);
    drawPathCShadow(canvas);
    canvas.restore();
  }
}
// [End emulation_3_d]
// [EndExclude emulation_3_e]

/**
 * Draw the current page area.
 *
 * @param canvas canvas
 */
function drawPathAContent(canvas: drawing.Canvas): void {
  if (canIUse('SystemCapability.Graphics.Drawing')) {
    canvas.attachBrush(pathABrush);

    canvas.save();
    canvas.clipPath(pathA);

    // Obtain a screenshot pixelMap for displaying the current page.
    let pagePixelMap: image.PixelMap = AppStorage.get('pagePixelMap') as image.PixelMap;
    let viewWidth: number = AppStorage.get('windowWidth') as number;
    let viewHeight: number = AppStorage.get('windowHeight') as number;
    let verts: Array<number> = [0, 0, viewWidth, 0, 0, viewHeight, viewWidth, viewHeight];
    // Execute drawing.
    canvas.drawPixelMapMesh(pagePixelMap, 1, 1, verts, 0, null, 0);
    canvas.restore();

    // Draw the shadow of the current page.
    if (AppStorage.get('drawPosition') === DrawPosition.DP_MIDDLE) {
      drawPathAHorizontalShadow(canvas);
    } else {
      drawPathALeftShadow(canvas);
      drawPathARightShadow(canvas);
    }
  }
}
// [EndExclude emulation_3_c]
// [End emulation_3_e]
/**
 * Draw the shadow shown on the next page.
 *
 * @param canvas canvas
 */
function drawPathBShadow(canvas: drawing.Canvas) {
  canvas.save()
  // Gradient color array.
  let deepColor: number = 0xff111111;
  let lightColor: number = 0x00111111;
  let gradientColors: number[] = [deepColor, lightColor];
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;

  // The distance from A to F.
  let aToF = Math.hypot((pointA.x - pointF.x), (pointA.y - pointF.y));
  // The distance from A to F.
  let viewDiagonalLength = Math.hypot(viewWidth, viewHeight);

  let left: number = 0;
  let right: number = 0;
  let top: number = pointC.y;
  let bottom: number = viewDiagonalLength + pointC.y;

  if (pointF.x === viewWidth && pointF.y === 0) {
    // The F point is located in the upper right corner.
    left = pointC.x;
    right = pointC.x + aToF / 4;
  } else {
    left = pointC.x - aToF / 4;
    right = pointC.x;
  }

  // Calculate the rotation angle between two points (calculated in radians and converted into angles).
  let deltaX: number = pointH.y - pointF.y;
  let deltaY: number = pointE.x - pointF.x;
  let radians: number = Math.atan2(deltaY, deltaX);
  // Convert radians to angles.
  let rotateDegrees: number = radians * 180 / Math.PI;

  let startPt: common2D.Point = { x: pointF.y === 0 ? right : left, y: top };
  let endPt: common2D.Point = { x: pointF.y === 0 ? left : right, y: top };
  let shaderEffect = drawing.ShaderEffect.createLinearGradient(endPt, startPt, gradientColors, drawing.TileMode.MIRROR);

  // Perform rotation.
  canvas.rotate(rotateDegrees, pointC.x, pointC.y);

  // Draw shadows.
  let rect: common2D.Rect = {
    left: left,
    top: top,
    right: right,
    bottom: bottom
  };
  drawShadow(canvas, shaderEffect, rect);
}
// [StartExclude emulation_3_c]
/**
 * Draw shadows in the back page area.
 *
 * @param canvas canvas
 */
function drawPathCShadow(canvas: drawing.Canvas) {
  // Gradient color array.
  let deepColor: number = 0x88111111;
  let lightColor: number = 0x00111111;
  let gradientColors: number[] = [lightColor, deepColor];
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;

  let deepOffset: number = 1; // The offset value of the dark end.
  // Diagonal length.
  let viewDiagonalLength = Math.hypot(viewWidth, viewHeight);

  // Width of shadow area.
  let midPointCE: number = (pointC.x + pointE.x) / 2;
  let midPointJH: number = (pointJ.y + pointH.y) / 2;
  let minDisToControlPoint = Math.min(Math.abs(midPointCE - pointE.x), Math.abs(midPointJH - pointH.y));

  let left: number = 0;
  let right: number = 0;
  let top: number = pointC.y;
  let bottom: number = viewDiagonalLength + pointC.y;

  if (pointF.x === viewWidth && pointF.y === 0) {
    // The F point is located in the upper right corner.
    left = pointC.x - deepOffset;
    right = pointC.x + minDisToControlPoint;
  } else {
    left = pointC.x - minDisToControlPoint;
    right = pointC.x + deepOffset;
  }

  // Calculate the rotation angle between two points (calculated in radians and converted into angles).
  let deltaX: number = pointH.y - pointF.y;
  let deltaY: number = pointE.x - pointF.x;
  let radians: number = Math.atan2(deltaY, deltaX);
  // Convert radians to angles.
  let rotateDegrees: number = radians * 180 / Math.PI;

  let startPt: common2D.Point = { x: pointF.y === 0 ? right : left, y: top };
  let endPt: common2D.Point = { x: pointF.y === 0 ? left : right, y: top };
  let shaderEffect = drawing.ShaderEffect.createLinearGradient(endPt, startPt, gradientColors, drawing.TileMode.MIRROR);

  // Perform rotation.
  canvas.rotate(rotateDegrees, pointC.x, pointC.y);

  // Draw shadows.
  let rect: common2D.Rect = {
    left: left,
    top: top,
    right: right,
    bottom: bottom
  };
  drawShadow(canvas, shaderEffect, rect);
}

/**
 * Draw a shadow on the left side of the current page.
 *
 * @param canvas canvas
 */
function drawPathALeftShadow(canvas: drawing.Canvas) {
  canvas.save();
  // Gradient color array.
  let deepColor: number = 0x88111111;
  let lightColor: number = 0x00111111;
  let gradientColors: number[] = [lightColor, deepColor];
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;

  let left: number = 0;
  let right: number = 0;
  let top: number = pointE.y;
  let bottom = pointE.y + viewHeight;

  if (pointF.x === viewWidth && pointF.y === 0) {
    // The F point is located in the upper right corner.
    left = pointE.x - lPathAShadowDis / 2;
    right = pointE.x;
  } else {
    left = pointE.x;
    right = pointE.x + lPathAShadowDis / 2;
  }

  //Calculate the rotation angle between two points (calculated in radians and converted into angles).
  let deltaX: number = pointA.y - pointE.y;
  let deltaY: number = pointE.x - pointA.x;
  let radians: number = Math.atan2(deltaY, deltaX);
  // Convert radians to angles.
  let rotateDegrees: number = radians * 180 / Math.PI;

  let startPt: common2D.Point = { x: pointF.y === viewHeight ? left : right, y: top };
  let endPt: common2D.Point = { x: pointF.y === viewHeight ? right : left, y: top };
  let shaderEffect = drawing.ShaderEffect.createLinearGradient(endPt, startPt, gradientColors, drawing.TileMode.MIRROR);

  // Crop to preserve the necessary drawing area.
  let tmpPath = new drawing.Path();
  tmpPath.moveTo(pointA.x - Math.max(rPathAShadowDis, lPathAShadowDis) / 2, pointA.y);
  tmpPath.lineTo(pointD.x, pointD.y);
  tmpPath.lineTo(pointE.x, pointE.y);
  tmpPath.lineTo(pointA.x, pointA.y);
  tmpPath.close();
  canvas.clipPath(pathA);
  canvas.clipPath(tmpPath, drawing.ClipOp.INTERSECT);

  // Perform rotation.
  canvas.rotate(rotateDegrees, pointE.x, pointE.y);

  // Draw shadows.
  let rect: common2D.Rect = {
    left: left,
    top: top,
    right: right,
    bottom: bottom
  };
  drawShadow(canvas, shaderEffect, rect);
}

/**
 * Draw a shadow on the right side of the current page.
 *
 * @param canvas canvas
 */
function drawPathARightShadow(canvas: drawing.Canvas) {
  canvas.save();
  canvas.clipPath(pathA);
  // Gradient color array.
  let deepColor: number = 0x88111111;
  let lightColor: number = 0x00111111;
  let gradientColors: number[] = [deepColor, lightColor, lightColor, lightColor];
  let viewWidth: number = AppStorage.get('windowWidth') as number;
  let viewHeight: number = AppStorage.get('windowHeight') as number;

  // Diagonal length.
  let viewDiagonalLength = Math.hypot(viewWidth, viewHeight);
  let left: number = pointH.x;
  let right: number = pointH.x + viewDiagonalLength * 10;
  let top: number = 0;
  let bottom = 0;

  if (pointF.x === viewWidth && pointF.y === 0) {
    // The F point is located in the upper right corner.
    top = pointH.y - rPathAShadowDis / 2;
    bottom = pointH.y;
  } else {
    top = pointH.y;
    bottom = pointH.y + rPathAShadowDis / 2;
  }

  // Calculate the rotation angle between two points (calculated in radians and converted into angles).
  let deltaX: number = pointA.x - pointH.x;
  let deltaY: number = pointA.y - pointH.y;
  let radians: number = Math.atan2(deltaY, deltaX);
  // Convert radians to angles.
  let rotateDegrees: number = radians * 180 / Math.PI;

  let startPt: common2D.Point = { x: left, y: pointF.y === viewHeight ? bottom : top };
  let endPt: common2D.Point = { x: left, y: pointF.y === viewHeight ? top : bottom };
  let shaderEffect = drawing.ShaderEffect.createLinearGradient(endPt, startPt, gradientColors, drawing.TileMode.MIRROR);

  // Crop to preserve the necessary drawing area.
  let tmpPath = new drawing.Path();
  tmpPath.moveTo(pointA.x - Math.max(rPathAShadowDis, lPathAShadowDis) / 2, pointA.y);
  tmpPath.lineTo(pointH.x, pointH.y);
  tmpPath.lineTo(pointA.x, pointA.y);
  tmpPath.close();
  canvas.clipPath(pathA);
  canvas.clipPath(tmpPath, drawing.ClipOp.INTERSECT);

  // Perform rotation.
  canvas.rotate(rotateDegrees, pointH.x, pointH.y);

  // Draw shadows.
  let rect: common2D.Rect = {
    left: left,
    top: top,
    right: right,
    bottom: bottom
  };
  drawShadow(canvas, shaderEffect, rect);
}

/**
 * Horizontal sliding shadow drawing.
 *
 * @param canvas canvas
 */
function drawPathAHorizontalShadow(canvas: drawing.Canvas): void {
  canvas.save();
  // Gradient color array.
  let deepColor: number = 0x88111111;
  let lightColor: number = 0x00111111;
  let gradientColors: number[] = [lightColor, deepColor];
  let viewHeight: number = AppStorage.get('windowHeight') as number;

  // The maximum width of the shadow rectangle.
  let maxShadowWidth: number = 30;
  let left: number = pointA.x - Math.min(maxShadowWidth, (rPathAShadowDis / 2));
  let right: number = pointA.x + 70;
  let top: number = 0;
  let bottom: number = viewHeight;

  // Crop to preserve the current page area.
  canvas.clipPath(pathA);

  let startPt: common2D.Point = { x: right, y: top };
  let endPt: common2D.Point = { x: left, y: top };
  let shaderEffect = drawing.ShaderEffect.createLinearGradient(endPt, startPt, gradientColors, drawing.TileMode.MIRROR);

  // Draw shadows.
  let rect: common2D.Rect = {
    left: left,
    top: top,
    right: right,
    bottom: bottom
  };
  drawShadow(canvas, shaderEffect, rect);
}
// [EndExclude emulation_3_c]
/**
 * Draw shaded areas.
 *
 * @param canvas canvas
 * @param shaderEffect shader effect
 * @param rect rect
 */
function drawShadow(canvas: drawing.Canvas, shaderEffect: drawing.ShaderEffect, rect: common2D.Rect) {
  let tmpBrush = new drawing.Brush();
  tmpBrush.setShaderEffect(shaderEffect);
  canvas.attachBrush(tmpBrush);
  canvas.drawRect(rect.left, rect.top, rect.right, rect.bottom);
  canvas.detachBrush();
  canvas.restore();
}
// [End emulation_3_c]