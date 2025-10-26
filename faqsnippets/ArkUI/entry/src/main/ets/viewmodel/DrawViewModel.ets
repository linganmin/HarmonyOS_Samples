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
* FAQ:如何实现马赛克效果
*/

// [Start draw_view_model]
export class DrawPathPointModel {
  x: number = 0;
  y: number = 0;
}

export enum DrawPathType {
  pen = 0, // Brush
  pattern // Mosaic
}

// Configure the brush
export class DrawPathModel {
  public pathType: DrawPathType = DrawPathType.pen;
  public color: string = '#ED1B1B';
  public lineWidth: number = 8;
  public img: ImageBitmap = new ImageBitmap('Images/startIcon.png');
}

@Observed
export class DrawViewModel {
  public settings: RenderingContextSettings = new RenderingContextSettings(true);
  public context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  public drawModel: DrawPathModel = new DrawPathModel();
  public canvasHeight: number = 0;
  public canvasWidth: number = 0;
  private pattern: CanvasPattern | null = null;
  private points: DrawPathPointModel[] = [];
  // Draw a path
  private drawPath = new Path2D();

  constructor() {
    this.pattern = this.context.createPattern(this.drawModel.img, 'repeat');
  }

  moveStart(x: number, y: number) {
    this.points.push({ x: x, y: y });
    this.drawPath.moveTo(x, y);
    this.drawCurrentPathModel();
  }

  moveUpdate(x: number, y: number) {
    let lastPoint = this.points[this.points.length - 1];
    this.points.push({ x: x, y: y });
    this.drawPath.quadraticCurveTo((x + lastPoint.x) / 2, (y + lastPoint.y) / 2, x, y);
    this.drawCurrentPathModel();
  }

  moveEnd() {
    this.points = [];
    this.drawPath = new Path2D();
  }

  clearPath() {
    this.points = [];
    this.drawPath = new Path2D();
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  canvasAreaChange(area: Area) {
    this.canvasHeight = area.height as number;
    this.canvasWidth = area.width as number;
  }

  private drawCurrentPathModel() {
    this.context.globalCompositeOperation = 'source-over';
    this.context.lineWidth = this.drawModel.lineWidth;
    if (this.drawModel.pathType == DrawPathType.pen) {
      this.context.strokeStyle = this.drawModel.color;
    } else {
      if (this.pattern) {
        this.context.strokeStyle = this.pattern;
      }
    }
    this.context.lineJoin = 'round';
    this.context.stroke(this.drawPath);
  }
}
// [End draw_view_model]